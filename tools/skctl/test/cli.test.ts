import { test } from "node:test";
import assert from "node:assert/strict";
import { execSync } from "node:child_process";
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readlinkSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { quote } from "./helpers.ts";

const CLI = "/home/xuqinqin/develop/dotfiles/tools/skctl/src/cli.ts";

function cli(store: string, args: string): string {
  return execSync(`node ${CLI} --store ${quote(store)} ${args}`, { stdio: "pipe" }).toString();
}

void test("cli install + list + disable + enable + uninstall", () => {
  const src = mkdtempSync(join(tmpdir(), "skctl-src-"));
  writeFileSync(join(src, "SKILL.md"), "---\nname: demo\ndescription: demo skill\n---\n");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  try {
    const out = cli(store, `install ${quote(src)}`);
    assert.match(out, /installed: demo/);
    const list = cli(store, "list");
    assert.match(list, /demo/);
    cli(store, "disable demo");
    const listAll = cli(store, "list --all");
    assert.match(listAll, /disabled/);
    cli(store, "enable demo");
    const list2 = cli(store, "list");
    assert.match(list2, /enabled/);
    const info = cli(store, "info demo");
    assert.match(info, /demo skill/);
    cli(store, "uninstall demo -y");
    assert.throws(() => cli(store, "info demo"), /not installed/);
  } finally {
    rmSync(src, { recursive: true, force: true });
    rmSync(store, { recursive: true, force: true });
  }
});

void test("cli uninstall confirms via piped stdin", () => {
  const src = mkdtempSync(join(tmpdir(), "skctl-src-"));
  writeFileSync(join(src, "SKILL.md"), "---\nname: demo\ndescription: demo skill\n---\n");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  try {
    cli(store, `install ${quote(src)}`);
    const out = execSync(`node ${CLI} --store ${quote(store)} uninstall demo`, {
      stdio: "pipe",
      input: "y\n",
    }).toString();
    assert.match(out, /uninstalled: demo/);
  } finally {
    rmSync(src, { recursive: true, force: true });
    rmSync(store, { recursive: true, force: true });
  }
});

void test("cli list hides description by default, shows indented with --desc", () => {
  const src = mkdtempSync(join(tmpdir(), "skctl-src-"));
  writeFileSync(join(src, "SKILL.md"), "---\nname: demo\ndescription: demo skill\n---\n");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  try {
    cli(store, `install ${quote(src)}`);
    const list = cli(store, "list");
    assert.doesNotMatch(list, /demo skill/);
    const listDesc = cli(store, "list --desc");
    assert.match(listDesc, /demo skill/);
    assert.match(listDesc, /\n {10}demo skill/);
  } finally {
    rmSync(src, { recursive: true, force: true });
    rmSync(store, { recursive: true, force: true });
  }
});

void test("cli list --path shows real skill dir", () => {
  const src = mkdtempSync(join(tmpdir(), "skctl-src-"));
  writeFileSync(join(src, "SKILL.md"), "---\nname: demo\ndescription: demo skill\n---\n");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  try {
    cli(store, `install ${quote(src)}`);
    const list = cli(store, "list");
    assert.ok(!list.includes(src));
    const listPath = cli(store, "list --path");
    assert.ok(listPath.includes(`\n          ${src}`));
  } finally {
    rmSync(src, { recursive: true, force: true });
    rmSync(store, { recursive: true, force: true });
  }
});

void test("cli colors output with FORCE_COLOR, plain when piped", () => {
  const src = mkdtempSync(join(tmpdir(), "skctl-src-"));
  writeFileSync(join(src, "SKILL.md"), "---\nname: demo\ndescription: demo skill\n---\n");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  try {
    cli(store, `install ${quote(src)}`);
    const plain = cli(store, "list");
    assert.ok(!plain.includes("\x1b["));
    const colored = execSync(`node ${CLI} --store ${quote(store)} list`, {
      stdio: "pipe",
      env: { ...process.env, FORCE_COLOR: "1" },
    }).toString();
    assert.ok(colored.includes("\x1b[32m"));
    assert.ok(colored.includes("\x1b[1m"));
  } finally {
    rmSync(src, { recursive: true, force: true });
    rmSync(store, { recursive: true, force: true });
  }
});

void test("cli list tolerates skill dir without SKILL.md", () => {
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  try {
    mkdirSync(join(store, "skills", "broken-skill"), { recursive: true });
    const out = cli(store, "list");
    assert.match(out, /broken-skill/);
  } finally {
    rmSync(store, { recursive: true, force: true });
  }
});

void test("cli doctor and migrate", () => {
  const agentsLink = "/home/xuqinqin/.agents/skills";
  const orig = existsSync(agentsLink) ? readlinkSync(agentsLink) : null;
  const srcDir = mkdtempSync(join(tmpdir(), "skctl-src-"));
  mkdirSync(join(srcDir, "self-skill"));
  writeFileSync(
    join(srcDir, "self-skill", "SKILL.md"),
    "---\nname: self-skill\ndescription: d\n---\n",
  );
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  try {
    rmSync(agentsLink, { force: true });
    symlinkSync(join(store, "skills"), agentsLink);
    const out = cli(store, `migrate ${quote(srcDir)} --local-only`);
    assert.match(out, /migrated \(local\): self-skill/);
    const doc = cli(store, "doctor");
    assert.match(doc, /all ok/);
  } finally {
    rmSync(srcDir, { recursive: true, force: true });
    rmSync(store, { recursive: true, force: true });
    if (orig !== null) {
      rmSync(agentsLink, { force: true });
      symlinkSync(orig, agentsLink);
    } else {
      rmSync(agentsLink, { force: true });
    }
  }
});
