import { test } from "node:test";
import assert from "node:assert/strict";
import { execSync, spawn } from "node:child_process";
import {
  existsSync, mkdirSync, mkdtempSync, readlinkSync, rmSync, writeFileSync,
} from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { findSkillDir, installSkill } from "../src/install.ts";
import { loadRegistry } from "../src/registry.ts";
import { quote } from "../src/shell.ts";

function git(repo: string, cmd: string) {
  execSync(`git -C ${quote(repo)} ${cmd}`, { stdio: "pipe" });
}

function makeRepo(): string {
  const repo = mkdtempSync(join(tmpdir(), "skctl-repo-"));
  git(repo, "init -q");
  git(repo, "config user.email t@t");
  git(repo, "config user.name t");
  return repo;
}

test("findSkillDir detects root SKILL.md", () => {
  const dir = mkdtempSync(join(tmpdir(), "skctl-"));
  writeFileSync(join(dir, "SKILL.md"), "---\nname: x\ndescription: d\n---\n");
  assert.equal(findSkillDir(dir), dir);
  rmSync(dir, { recursive: true, force: true });
});

test("findSkillDir detects single subdir", () => {
  const dir = mkdtempSync(join(tmpdir(), "skctl-"));
  mkdirSync(join(dir, "sub"));
  writeFileSync(join(dir, "sub", "SKILL.md"), "---\nname: x\ndescription: d\n---\n");
  assert.equal(findSkillDir(dir), join(dir, "sub"));
  rmSync(dir, { recursive: true, force: true });
});

test("findSkillDir returns null for multiple candidates", () => {
  const dir = mkdtempSync(join(tmpdir(), "skctl-"));
  mkdirSync(join(dir, "a"));
  mkdirSync(join(dir, "b"));
  writeFileSync(join(dir, "a", "SKILL.md"), "---\nname: a\ndescription: d\n---\n");
  writeFileSync(join(dir, "b", "SKILL.md"), "---\nname: b\ndescription: d\n---\n");
  assert.equal(findSkillDir(dir), null);
  rmSync(dir, { recursive: true, force: true });
});

test("installSkill installs from git repo subdir", () => {
  const repo = makeRepo();
  mkdirSync(join(repo, "my-skill"));
  writeFileSync(join(repo, "my-skill", "SKILL.md"), "---\nname: my-skill\ndescription: test skill\n---\n# body\n");
  git(repo, "add -A");
  git(repo, "commit -qm init");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  const name = installSkill({ src: `file://${repo}`, store });
  assert.equal(name, "my-skill");
  assert.ok(existsSync(join(store, "skills", "my-skill", "SKILL.md")));
  const reg = loadRegistry(join(store, "registry.json"));
  assert.equal(reg.skills["my-skill"].source.type, "git");
  assert.ok(reg.skills["my-skill"].installedCommit);
  rmSync(repo, { recursive: true, force: true });
  rmSync(store, { recursive: true, force: true });
});

test("installSkill creates symlink for local source", () => {
  const src = mkdtempSync(join(tmpdir(), "skctl-src-"));
  writeFileSync(join(src, "SKILL.md"), "---\nname: local-skill\ndescription: d\n---\n");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  const name = installSkill({ src, store });
  assert.equal(name, "local-skill");
  assert.equal(readlinkSync(join(store, "skills", "local-skill")), src);
  rmSync(src, { recursive: true, force: true });
  rmSync(store, { recursive: true, force: true });
});

test("installSkill errors on duplicate", () => {
  const src = mkdtempSync(join(tmpdir(), "skctl-src-"));
  writeFileSync(join(src, "SKILL.md"), "---\nname: dup\ndescription: d\n---\n");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  installSkill({ src, store });
  assert.throws(() => installSkill({ src, store }), /already installed/);
  rmSync(src, { recursive: true, force: true });
  rmSync(store, { recursive: true, force: true });
});

test("installSkill skips existing with ifExists=skip", () => {
  const src = mkdtempSync(join(tmpdir(), "skctl-src-"));
  writeFileSync(join(src, "SKILL.md"), "---\nname: skipme\ndescription: d\n---\n");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  installSkill({ src, store });
  const name = installSkill({ src, store, ifExists: "skip" });
  assert.equal(name, "skipme");
  rmSync(src, { recursive: true, force: true });
  rmSync(store, { recursive: true, force: true });
});

test("installSkill installs from zip URL", async () => {
  const srcDir = mkdtempSync(join(tmpdir(), "skctl-zipsrc-"));
  mkdirSync(join(srcDir, "zip-skill"));
  writeFileSync(join(srcDir, "zip-skill", "SKILL.md"), "---\nname: zip-skill\ndescription: d\n---\n");
  const zipPath = join(srcDir, "skill.zip");
  execSync(`python3 -m zipfile -c ${quote(zipPath)} ${quote(join(srcDir, "zip-skill"))}`, { stdio: "pipe" });
  const server = spawn(process.execPath, [
    "-e",
    `const { createServer } = require("node:http");
const { readFileSync } = require("node:fs");
const s = createServer((req, res) => res.end(readFileSync(process.argv[1])));
s.listen(0, "127.0.0.1", () => console.log(s.address().port));`,
    zipPath,
  ]);
  const port = await new Promise<number>((resolve, reject) => {
    let buf = "";
    server.stdout.on("data", (d) => {
      buf += d.toString();
      const m = buf.match(/\d+/);
      if (m) resolve(Number(m[0]));
    });
    server.once("error", reject);
  });
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  const url = `http://127.0.0.1:${port}/skill.zip`;
  try {
    const name = installSkill({ src: url, store });
    assert.equal(name, "zip-skill");
    assert.ok(existsSync(join(store, "skills", "zip-skill", "SKILL.md")));
    const reg = loadRegistry(join(store, "registry.json"));
    assert.equal(reg.skills["zip-skill"].source.type, "local");
    assert.equal(reg.skills["zip-skill"].source.url, url);
  } finally {
    server.kill();
    rmSync(srcDir, { recursive: true, force: true });
    rmSync(store, { recursive: true, force: true });
  }
});