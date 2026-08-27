#!/usr/bin/env node
import { readFileSync, readdirSync, readSync, renameSync, rmSync, lstatSync, existsSync, mkdirSync, realpathSync } from "node:fs";
import { join } from "node:path";
import { parseArgs } from "node:util";
import { doctor } from "./doctor.ts";
import { installSkill } from "./install.ts";
import { migrate, migrateLocal, DEFAULT_DOTFILES_SKILLS } from "./migrate.ts";
import { resolveStore, storePaths } from "./paths.ts";
import { loadRegistry, saveRegistry } from "./registry.ts";
import { updateSkill } from "./update.ts";
import { parseFrontmatter } from "./validate.ts";
import { makeColor } from "./color.ts";
import { confirm } from "@inquirer/prompts";

const colorEnabled = !!process.env.FORCE_COLOR || (!!process.stdout.isTTY && !process.env.NO_COLOR);
const c = makeColor(colorEnabled);

const USAGE = `skctl - skill manager

Usage: skctl <command> [options]

Commands:
  ${c.bold("list")} [--all] [--desc] [--path] List skills (--desc shows descriptions, --path shows real dirs)
  ${c.bold("info")} <name>           Show skill details
  ${c.bold("install")} <src> [--subdir DIR]   Install skill (git URL | zip URL | local dir)
  ${c.bold("uninstall")} <name> [-y] Remove skill
  ${c.bold("enable")} <name>         Enable skill
  ${c.bold("disable")} <name>        Disable skill
  ${c.bold("update")} [<name>...]    Update git-sourced skills
  ${c.bold("doctor")}                Check and repair store
  ${c.bold("migrate")} [dir] [--local-only]  Migrate from dotfiles/agent/skills (--local-only skips git installs)
  ${c.bold("--help")}, -h            Show this help

Global:
  --store <path>        Override store directory
`;

function extractStoreFlag(args: string[]): string | undefined {
  const i = args.indexOf("--store");
  if (i === -1) return undefined;
  const v = args[i + 1];
  args.splice(i, 2);
  return v;
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length === 0 || args[0] === "--help" || args[0] === "-h") {
    console.log(USAGE);
    return;
  }
  const store = resolveStore(extractStoreFlag(args));
  const cmd = args[0];
  const rest = args.slice(1);
  const p = storePaths(store);

  switch (cmd) {
    case "list": return cmdList(rest, p);
    case "info": return cmdInfo(rest, p);
    case "install": return cmdInstall(rest, p);
    case "uninstall": return cmdUninstall(rest, p);
    case "enable": return cmdEnable(rest, p, true);
    case "disable": return cmdEnable(rest, p, false);
    case "update": return cmdUpdate(rest, p);
    case "doctor": return cmdDoctor(rest, p);
    case "migrate": return cmdMigrate(rest, p);
    default:
      console.error(c.red(`unknown command: ${cmd}`));
      console.error(USAGE);
      process.exit(1);
  }
}

function cmdList(args: string[], p: ReturnType<typeof storePaths>) {
  const all = args.includes("--all");
  const showDesc = args.includes("--desc");
  const showPath = args.includes("--path");
  const registry = loadRegistry(p.registry);
  const rows: { name: string; enabled: boolean; source: string; desc: string; path: string }[] = [];
  for (const dir of [p.skills, p.disabled]) {
    if (!existsSync(dir)) continue;
    for (const name of readdirSync(dir)) {
      const skillDir = join(dir, name);
      const st = lstatSync(skillDir);
      if (!st.isDirectory() && !st.isSymbolicLink()) continue;
      const enabled = dir === p.skills;
      if (!all && !enabled) continue;
      const rec = registry.skills[name];
      const source = rec ? rec.source.type : "unknown";
      let desc = "";
      const skillMd = join(skillDir, "SKILL.md");
      if (existsSync(skillMd)) {
        const fm = parseFrontmatter(readFileSync(skillMd, "utf8"));
        if (fm) desc = fm.description;
      }
      let path = skillDir;
      try {
        path = realpathSync(skillDir);
      } catch {
        // broken symlink: keep unresolved path
      }
      rows.push({ name, enabled, source, desc, path });
    }
  }
  rows.sort((a, b) => a.name.localeCompare(b.name));
  for (const r of rows) {
    const status = r.enabled ? c.green("enabled ") : c.yellow("disabled");
    const srcCol = r.source === "git" ? c.magenta(r.source.padEnd(8)) : r.source === "local" ? c.cyan(r.source.padEnd(8)) : c.red(r.source.padEnd(8));
    console.log(`${status}  ${c.bold(r.name.padEnd(24))} ${srcCol}`);
    if (showPath) console.log(`          ${c.dim(r.path)}`);
    if (showDesc && r.desc) console.log(`          ${c.dim(r.desc)}`);
  }
}

function cmdInfo(args: string[], p: ReturnType<typeof storePaths>) {
  const name = args[0];
  if (!name) {
    console.error(c.red("usage: skctl info <name>"));
    process.exit(1);
  }
  const registry = loadRegistry(p.registry);
  const rec = registry.skills[name];
  const dir = join(p.skills, name);
  const disabledDir = join(p.disabled, name);
  const actual = existsSync(dir) ? dir : existsSync(disabledDir) ? disabledDir : null;
  if (!actual) {
    console.error(c.red(`not installed: ${name}`));
    process.exit(1);
  }
  console.log(`name: ${c.bold(name)}`);
  console.log(`status: ${existsSync(dir) ? c.green("enabled") : c.yellow("disabled")}`);
  console.log(`source: ${JSON.stringify(rec?.source ?? null)}`);
  if (rec?.installedCommit) console.log(`commit: ${rec.installedCommit}`);
  if (rec?.installedAt) console.log(`installedAt: ${rec.installedAt}`);
  const skillMd = join(actual, "SKILL.md");
  if (existsSync(skillMd)) {
    const fm = parseFrontmatter(readFileSync(skillMd, "utf8"));
    if (fm) console.log(`description: ${fm.description}`);
  }
}

async function cmdInstall(args: string[], p: ReturnType<typeof storePaths>) {
  const { values, positionals } = parseArgs({ args, options: { subdir: { type: "string" } }, allowPositionals: true });
  const src = positionals[0] as string | undefined;
  if (!src) {
    console.error(c.red("usage: skctl install <src> [--subdir DIR]"));
    process.exit(1);
  }
  const name = await installSkill({ src, subdir: values.subdir, store: p.store });
  console.log(c.green(`installed: ${name}`));
}

async function cmdUninstall(args: string[], p: ReturnType<typeof storePaths>) {
  const name = args[0];
  const force = args.includes("-y");
  if (!name) {
    console.error(c.red("usage: skctl uninstall <name> [-y]"));
    process.exit(1);
  }
  const registry = loadRegistry(p.registry);
  if (!registry.skills[name]) {
    console.error(c.red(`not installed: ${name}`));
    process.exit(1);
  }
  if (!force) {
    let yes = false;
    if (process.stdin.isTTY) {
      yes = await confirm({ message: `remove ${name}?`, default: false });
    } else {
      process.stdout.write(`remove ${name}? [y/N] `);
      const buf = Buffer.alloc(16);
      const n = readSync(0, buf, 0, 16, null);
      const answer = buf.subarray(0, n).toString().trim().toLowerCase();
      yes = answer === "y" || answer === "yes";
    }
    if (!yes) {
      console.log("aborted");
      return;
    }
  }
  rmSync(join(p.skills, name), { recursive: true, force: true });
  rmSync(join(p.disabled, name), { recursive: true, force: true });
  delete registry.skills[name];
  saveRegistry(p.registry, registry);
  console.log(c.green(`uninstalled: ${name}`));
}

function cmdEnable(args: string[], p: ReturnType<typeof storePaths>, enable: boolean) {
  const name = args[0];
  if (!name) {
    console.error(c.red(`usage: skctl ${enable ? "enable" : "disable"} <name>`));
    process.exit(1);
  }
  const from = enable ? p.disabled : p.skills;
  const to = enable ? p.skills : p.disabled;
  const src = join(from, name);
  if (!existsSync(src)) {
    console.error(c.red(`skill not ${enable ? "disabled" : "enabled"}: ${name}`));
    process.exit(1);
  }
  mkdirSync(to, { recursive: true });
  renameSync(src, join(to, name));
  console.log(c.green(`${enable ? "enabled" : "disabled"}: ${name}`));
}

async function cmdUpdate(args: string[], p: ReturnType<typeof storePaths>) {
  const names = args.filter((a) => !a.startsWith("-"));
  const registry = loadRegistry(p.registry);
  const targets = names.length
    ? names
    : Object.keys(registry.skills).filter((n) => registry.skills[n].source.type === "git");
  for (const name of targets) {
    try {
      const result = await updateSkill(name, p.store);
      const line = result.startsWith("updated") ? c.green(`${name}: ${result}`) : c.dim(`${name}: ${result}`);
      console.log(line);
    } catch (e) {
      console.error(c.red(`${name}: ${(e as Error).message}`));
    }
  }
}

function cmdDoctor(_args: string[], p: ReturnType<typeof storePaths>) {
  for (const line of doctor(p.store)) {
    if (line.startsWith("broken:") || line.startsWith("orphan:") || line.startsWith("invalid:")) console.log(c.red(line));
    else if (line.startsWith("fixed:")) console.log(c.green(line));
    else console.log(line);
  }
}

async function cmdMigrate(args: string[], p: ReturnType<typeof storePaths>) {
  const localOnly = args.includes("--local-only");
  const dir = args.find((a) => !a.startsWith("-"));
  const report = localOnly ? await migrateLocal(dir ?? DEFAULT_DOTFILES_SKILLS, p.store) : await migrate(p.store, dir);
  for (const line of report) {
    if (line.startsWith("migrated") || line.startsWith("installed")) console.log(c.green(line));
    else if (line.startsWith("next:")) console.log(c.dim(line));
    else console.log(line);
  }
}

main().catch((e) => {
  console.error(c.red((e as Error).message));
  process.exit(1);
});
