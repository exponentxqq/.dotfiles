import { test } from "node:test";
import assert from "node:assert/strict";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, readlinkSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { quote } from "../src/shell.ts";

const CLI = "/home/xuqinqin/develop/dotfiles/tools/skctl/src/cli.ts";

function cli(store: string, args: string): string {
  return execSync(`node ${CLI} --store ${quote(store)} ${args}`, { stdio: "pipe" }).toString();
}

test("cli install + list + disable + enable + uninstall", () => {
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

test("cli doctor and migrate", () => {
  const agentsLink = "/home/xuqinqin/.agents/skills";
  const orig = existsSync(agentsLink) ? readlinkSync(agentsLink) : null;
  const srcDir = mkdtempSync(join(tmpdir(), "skctl-src-"));
  mkdirSync(join(srcDir, "self-skill"));
  writeFileSync(join(srcDir, "self-skill", "SKILL.md"), "---\nname: self-skill\ndescription: d\n---\n");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  rmSync(agentsLink, { force: true });
  symlinkSync(join(store, "skills"), agentsLink);
  try {
    const out = cli(store, `migrate ${quote(srcDir)}`);
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
