import {
  existsSync,
  lstatSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  readlinkSync,
  rmSync,
  symlinkSync,
} from "node:fs";
import { dirname, join } from "node:path";
import { loadRegistry } from "./registry.ts";
import { parseFrontmatter } from "./validate.ts";
import { storePaths, USER_HOME } from "./paths.ts";

export function doctor(
  store: string,
  agentsLink: string = join(USER_HOME, ".agents", "skills"),
): string[] {
  const report: string[] = [];
  const p = storePaths(store);

  const linkOk =
    existsSync(agentsLink) &&
    lstatSync(agentsLink).isSymbolicLink() &&
    readlinkSync(agentsLink) === p.skills;
  if (!linkOk) {
    mkdirSync(dirname(agentsLink), { recursive: true });
    rmSync(agentsLink, { recursive: true, force: true });
    symlinkSync(p.skills, agentsLink);
    report.push("fixed: ~/.agents/skills symlink");
  }

  const registry = loadRegistry(p.registry);
  for (const name of Object.keys(registry.skills)) {
    const inSkills = existsSync(join(p.skills, name));
    const inDisabled = existsSync(join(p.disabled, name));
    if (!inSkills && !inDisabled) {
      report.push(`orphan: ${name} (in registry, dir missing)`);
    }
  }

  for (const dir of [p.skills, p.disabled]) {
    if (!existsSync(dir)) continue;
    for (const name of readdirSync(dir)) {
      const entry = join(dir, name);
      const st = lstatSync(entry);
      if (!st.isDirectory() && !st.isSymbolicLink()) continue;
      const rec = registry.skills[name];
      if (rec?.source.type === "local" && rec.source.path && !existsSync(rec.source.path)) {
        report.push(`broken: ${name} (local source missing: ${rec.source.path})`);
        continue;
      }
      let fm: ReturnType<typeof parseFrontmatter>;
      try {
        fm = parseFrontmatter(readFileSync(join(entry, "SKILL.md"), "utf8"));
      } catch {
        fm = null;
      }
      if (!fm) {
        report.push(`invalid: ${name} (bad frontmatter)`);
      } else if (fm.name !== name) {
        report.push(`invalid: ${name} (frontmatter name ${fm.name} != dir name)`);
      }
    }
  }

  const issues = report.filter((l) => !l.startsWith("fixed:")).length;
  report.push(issues === 0 ? "doctor done: all ok" : `doctor done: ${issues} issue(s)`);
  return report;
}
