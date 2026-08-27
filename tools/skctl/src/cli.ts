#!/usr/bin/env node
import { readFileSync, readdirSync, readSync, renameSync, rmSync, lstatSync, existsSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import { parseArgs } from "node:util";
import { doctor } from "./doctor.ts";
import { installSkill } from "./install.ts";
import { migrate, migrateLocal, DEFAULT_DOTFILES_SKILLS } from "./migrate.ts";
import { resolveStore, storePaths } from "./paths.ts";
import { loadRegistry, saveRegistry } from "./registry.ts";
import { updateSkill } from "./update.ts";
import { parseFrontmatter } from "./validate.ts";

const USAGE = `skctl - skill manager

Usage: skctl <command> [options]

Commands:
  list [--all] [--desc] List skills (--desc shows descriptions)
  info <name>           Show skill details
  install <src> [--subdir DIR]   Install skill (git URL | zip URL | local dir)
  uninstall <name> [-y] Remove skill
  enable <name>         Enable skill
  disable <name>        Disable skill
  update [<name>...]    Update git-sourced skills
  doctor                Check and repair store
  migrate [dir] [--local-only]  Migrate from dotfiles/agent/skills (--local-only skips git installs)
  --help, -h            Show this help

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

function main() {
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
      console.error(`unknown command: ${cmd}`);
      console.error(USAGE);
      process.exit(1);
  }
}

function cmdList(args: string[], p: ReturnType<typeof storePaths>) {
  const all = args.includes("--all");
  const showDesc = args.includes("--desc");
  const registry = loadRegistry(p.registry);
  const rows: { name: string; enabled: boolean; source: string; desc: string }[] = [];
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
      rows.push({ name, enabled, source, desc });
    }
  }
  rows.sort((a, b) => a.name.localeCompare(b.name));
  for (const r of rows) {
    console.log(`${r.enabled ? "enabled " : "disabled"}  ${r.name.padEnd(24)} ${r.source.padEnd(8)}`);
    if (showDesc && r.desc) console.log(`          ${r.desc}`);
  }
}

function cmdInfo(args: string[], p: ReturnType<typeof storePaths>) {
  const name = args[0];
  if (!name) {
    console.error("usage: skctl info <name>");
    process.exit(1);
  }
  const registry = loadRegistry(p.registry);
  const rec = registry.skills[name];
  const dir = join(p.skills, name);
  const disabledDir = join(p.disabled, name);
  const actual = existsSync(dir) ? dir : existsSync(disabledDir) ? disabledDir : null;
  if (!actual) {
    console.error(`not installed: ${name}`);
    process.exit(1);
  }
  console.log(`name: ${name}`);
  console.log(`status: ${existsSync(dir) ? "enabled" : "disabled"}`);
  console.log(`source: ${JSON.stringify(rec?.source ?? null)}`);
  if (rec?.installedCommit) console.log(`commit: ${rec.installedCommit}`);
  if (rec?.installedAt) console.log(`installedAt: ${rec.installedAt}`);
  const skillMd = join(actual, "SKILL.md");
  if (existsSync(skillMd)) {
    const fm = parseFrontmatter(readFileSync(skillMd, "utf8"));
    if (fm) console.log(`description: ${fm.description}`);
  }
}

function cmdInstall(args: string[], p: ReturnType<typeof storePaths>) {
  const { values, positionals } = parseArgs({ args, options: { subdir: { type: "string" } }, allowPositionals: true });
  const src = positionals[0] as string | undefined;
  if (!src) {
    console.error("usage: skctl install <src> [--subdir DIR]");
    process.exit(1);
  }
  const name = installSkill({ src, subdir: values.subdir, store: p.store });
  console.log(`installed: ${name}`);
}

function cmdUninstall(args: string[], p: ReturnType<typeof storePaths>) {
  const name = args[0];
  const force = args.includes("-y");
  if (!name) {
    console.error("usage: skctl uninstall <name> [-y]");
    process.exit(1);
  }
  const registry = loadRegistry(p.registry);
  if (!registry.skills[name]) {
    console.error(`not installed: ${name}`);
    process.exit(1);
  }
  if (!force) {
    process.stdout.write(`remove ${name}? [y/N] `);
    const buf = Buffer.alloc(16);
    const n = readSync(0, buf, 0, 16, null);
    const answer = buf.subarray(0, n).toString().trim().toLowerCase();
    if (answer !== "y" && answer !== "yes") {
      console.log("aborted");
      return;
    }
  }
  rmSync(join(p.skills, name), { recursive: true, force: true });
  rmSync(join(p.disabled, name), { recursive: true, force: true });
  delete registry.skills[name];
  saveRegistry(p.registry, registry);
  console.log(`uninstalled: ${name}`);
}

function cmdEnable(args: string[], p: ReturnType<typeof storePaths>, enable: boolean) {
  const name = args[0];
  if (!name) {
    console.error(`usage: skctl ${enable ? "enable" : "disable"} <name>`);
    process.exit(1);
  }
  const from = enable ? p.disabled : p.skills;
  const to = enable ? p.skills : p.disabled;
  const src = join(from, name);
  if (!existsSync(src)) {
    console.error(`skill not ${enable ? "disabled" : "enabled"}: ${name}`);
    process.exit(1);
  }
  mkdirSync(to, { recursive: true });
  renameSync(src, join(to, name));
  console.log(`${enable ? "enabled" : "disabled"}: ${name}`);
}

function cmdUpdate(args: string[], p: ReturnType<typeof storePaths>) {
  const names = args.filter((a) => !a.startsWith("-"));
  const registry = loadRegistry(p.registry);
  const targets = names.length
    ? names
    : Object.keys(registry.skills).filter((n) => registry.skills[n].source.type === "git");
  for (const name of targets) {
    try {
      console.log(`${name}: ${updateSkill(name, p.store)}`);
    } catch (e) {
      console.error(`${name}: ${(e as Error).message}`);
    }
  }
}

function cmdDoctor(_args: string[], p: ReturnType<typeof storePaths>) {
  for (const line of doctor(p.store)) {
    console.log(line);
  }
}

function cmdMigrate(args: string[], p: ReturnType<typeof storePaths>) {
  const localOnly = args.includes("--local-only");
  const dir = args.find((a) => !a.startsWith("-"));
  const report = localOnly ? migrateLocal(dir ?? DEFAULT_DOTFILES_SKILLS, p.store) : migrate(p.store, dir);
  for (const line of report) console.log(line);
}

main();
