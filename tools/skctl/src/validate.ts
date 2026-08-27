export const NAME_RE = /^[a-z0-9]+(-[a-z0-9]+)*$/;

export function validateName(name: string): boolean {
  return name.length >= 1 && name.length <= 64 && NAME_RE.test(name);
}

export interface SkillFrontmatter {
  name: string;
  description: string;
  [key: string]: string;
}

export function parseFrontmatter(content: string): SkillFrontmatter | null {
  if (!content.startsWith("---")) return null;
  const end = content.indexOf("\n---", 3);
  if (end === -1) return null;
  const block = content.slice(3, end);
  const fm: Record<string, string> = {};
  for (const line of block.split("\n")) {
    const m = line.match(/^([a-zA-Z0-9_-]+):\s*(.*)$/);
    if (!m) continue;
    let value = m[2].trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    fm[m[1]] = value;
  }
  if (!fm.name || !fm.description) return null;
  return fm as SkillFrontmatter;
}