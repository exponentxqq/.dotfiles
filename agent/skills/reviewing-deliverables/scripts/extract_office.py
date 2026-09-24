#!/usr/bin/env python3
"""零依赖 Office 文档文本提取(docx / xlsx / pptx)。

仅使用 Python 标准库(zipfile + xml.etree.ElementTree),不需要安装
python-docx / openpyxl / python-pptx。

用法:
    python3 extract_office.py <文件或目录> [更多路径...]

目录会递归查找所有 .docx/.xlsx/.pptx 文件。输出为纯文本,
每个文件前有 "===== FILE: 路径 =====" 分隔标记。
"""

import os
import sys
import zipfile
from xml.etree import ElementTree as ET

NS = {
    "w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
    "a": "http://schemas.openxmlformats.org/drawingml/2006/main",
    "x": "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    "pr": "http://schemas.openxmlformats.org/package/2006/relationships",
    "dc": "http://purl.org/dc/elements/1.1/",
    "cp": "http://schemas.openxmlformats.org/package/2006/metadata/core-properties",
    "ep": "http://schemas.openxmlformats.org/officeDocument/2006/extended-properties",
}

OFFICE_EXTS = {".docx", ".xlsx", ".pptx"}

PROPS = [
    ("docProps/core.xml", "{%s}creator" % NS["dc"], "作者"),
    ("docProps/core.xml", "{%s}lastModifiedBy" % NS["cp"], "最后修改者"),
    ("docProps/core.xml", "{%s}title" % NS["dc"], "标题"),
    ("docProps/core.xml", "{%s}created" % NS["dc"], "创建时间"),
    ("docProps/core.xml", "{%s}modified" % NS["dc"], "修改时间"),
    ("docProps/app.xml", "{%s}Company" % NS["ep"], "公司"),
    ("docProps/app.xml", "{%s}Manager" % NS["ep"], "经理"),
    ("docProps/app.xml", "{%s}Template" % NS["ep"], "模板"),
]


def _texts(root, path):
    return [el.text for el in root.iter(path) if el.text]


def extract_props(zf):
    """提取文档属性(作者/公司/模板等),用于元数据泄露检查。"""
    cache = {}
    pairs = []
    for part, tag, label in PROPS:
        if part not in cache:
            if part not in zf.namelist():
                cache[part] = None
            else:
                try:
                    cache[part] = ET.fromstring(zf.read(part))
                except ET.ParseError:
                    cache[part] = None
        root = cache[part]
        if root is None:
            continue
        el = root.find(tag)
        if el is not None and el.text and el.text.strip():
            pairs.append("%s=%s" % (label, el.text.strip()))
    return " | ".join(pairs)


def extract_comments(zf, part, ns):
    if part not in zf.namelist():
        return []
    try:
        root = ET.fromstring(zf.read(part))
    except ET.ParseError:
        return []
    lines = []
    for p in root.iter("{%s}p" % ns):
        text = "".join(t for t in _texts(p, "{%s}t" % ns) if t)
        if text.strip():
            lines.append(text)
    return lines


def extract_docx(zf):
    lines = []
    for name in sorted(zf.namelist()):
        if (
            name == "word/document.xml"
            or (name.startswith("word/header") or name.startswith("word/footer"))
            and name.endswith(".xml")
        ):
            try:
                root = ET.fromstring(zf.read(name))
            except ET.ParseError:
                continue
            for p in root.iter("{%s}p" % NS["w"]):
                text = "".join(t for t in _texts(p, "{%s}t" % NS["w"]) if t)
                if text.strip():
                    lines.append(text)
    return "\n".join(lines)


def extract_pptx(zf):
    slides = sorted(
        (
            n
            for n in zf.namelist()
            if n.startswith("ppt/slides/slide") and n.endswith(".xml")
        ),
        key=lambda n: int("".join(c for c in n.split("/")[-1] if c.isdigit()) or 0),
    )
    lines = []
    for name in slides:
        try:
            root = ET.fromstring(zf.read(name))
        except ET.ParseError:
            continue
        lines.append("--- %s ---" % name.split("/")[-1])
        text = "\n".join(t for t in _texts(root, "{%s}t" % NS["a"]) if t)
        if text:
            lines.append(text)
    return "\n".join(lines)


def extract_xlsx(zf):
    shared = []
    if "xl/sharedStrings.xml" in zf.namelist():
        root = ET.fromstring(zf.read("xl/sharedStrings.xml"))
        for si in root.iter("{%s}si" % NS["x"]):
            shared.append("".join(t for t in _texts(si, "{%s}t" % NS["x"]) if t))

    sheet_names = {}
    rels = {}
    if "xl/_rels/workbook.xml.rels" in zf.namelist():
        root = ET.fromstring(zf.read("xl/_rels/workbook.xml.rels"))
        for rel in root.iter("{%s}Relationship" % NS["pr"]):
            rels[rel.get("Id")] = rel.get("Target")
    if "xl/workbook.xml" in zf.namelist():
        root = ET.fromstring(zf.read("xl/workbook.xml"))
        for i, sheet in enumerate(root.iter("{%s}sheet" % NS["x"])):
            rid = sheet.get("{%s}id" % NS["r"])
            target = rels.get(rid, "")
            if target and not target.startswith("xl/"):
                target = "xl/" + target.lstrip("/")
            sheet_names[target or "xl/worksheets/sheet%d.xml" % (i + 1)] = sheet.get(
                "name"
            )

    lines = []
    for name in sorted(zf.namelist()):
        if not name.startswith("xl/worksheets/") or not name.endswith(".xml"):
            continue
        try:
            root = ET.fromstring(zf.read(name))
        except ET.ParseError:
            continue
        lines.append("--- %s ---" % sheet_names.get(name, name))
        for row in root.iter("{%s}row" % NS["x"]):
            cells = []
            for c in row.iter("{%s}c" % NS["x"]):
                v = c.find("{%s}v" % NS["x"])
                is_el = c.find("{%s}is" % NS["x"])
                if c.get("t") == "s" and v is not None and v.text is not None:
                    idx = int(v.text)
                    cells.append(shared[idx] if idx < len(shared) else "")
                elif is_el is not None:
                    cells.append(
                        "".join(t for t in _texts(is_el, "{%s}t" % NS["x"]) if t)
                    )
                elif v is not None and v.text:
                    cells.append(v.text)
            if any(cells):
                lines.append(" | ".join(cells))
    return "\n".join(lines)


def extract_file(path):
    try:
        zf = zipfile.ZipFile(path)
    except (zipfile.BadZipFile, OSError) as e:
        return "[无法读取: %s]" % e
    with zf:
        ext = os.path.splitext(path)[1].lower()
        try:
            out = []
            props = extract_props(zf)
            if props:
                out.append("[文档属性] " + props)
            if ext == ".docx":
                out.append(extract_docx(zf))
                comments = extract_comments(zf, "word/comments.xml", NS["w"])
                if comments:
                    out.append("[批注]\n" + "\n".join(comments))
            elif ext == ".pptx":
                out.append(extract_pptx(zf))
                notes = []
                for name in sorted(
                    n
                    for n in zf.namelist()
                    if n.startswith("ppt/notesSlides/notesSlide") and n.endswith(".xml")
                ):
                    notes.extend(extract_comments(zf, name, NS["a"]))
                if notes:
                    out.append("[演讲者备注]\n" + "\n".join(notes))
            elif ext == ".xlsx":
                out.append(extract_xlsx(zf))
                xcomments = []
                for name in sorted(
                    n
                    for n in zf.namelist()
                    if n.startswith("xl/comments") and n.endswith(".xml")
                ):
                    try:
                        root = ET.fromstring(zf.read(name))
                    except ET.ParseError:
                        continue
                    xcomments.extend(t for t in _texts(root, "{%s}t" % NS["x"]) if t)
                if xcomments:
                    out.append("[批注]\n" + "\n".join(xcomments))
            else:
                return "[不支持的格式: %s]" % ext
            return "\n".join(out).strip()
        except ET.ParseError as e:
            return "[XML 解析失败: %s]" % e


def collect(paths):
    files = []
    for p in paths:
        if os.path.isdir(p):
            for dirpath, _dirnames, filenames in os.walk(p):
                for fn in sorted(filenames):
                    if os.path.splitext(fn)[1].lower() in OFFICE_EXTS:
                        files.append(os.path.join(dirpath, fn))
        elif os.path.isfile(p):
            files.append(p)
        else:
            print("[路径不存在: %s]" % p, file=sys.stderr)
    return files


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 1
    files = collect(sys.argv[1:])
    if not files:
        print("未找到 Office 文件(docx/xlsx/pptx)")
        return 0
    for path in files:
        print("===== FILE: %s =====" % path)
        print(extract_file(path))
        print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
