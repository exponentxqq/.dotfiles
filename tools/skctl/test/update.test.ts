import { test } from "node:test";
import assert from "node:assert/strict";
import { execSync } from "node:child_process";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { installSkill } from "../src/install.ts";
import { quote } from "../src/shell.ts";
import { updateSkill } from "../src/update.ts";

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

test("updateSkill reports up-to-date", () => {
  const repo = makeRepo();
  mkdirSync(join(repo, "my-skill"));
  writeFileSync(join(repo, "my-skill", "SKILL.md"), "---\nname: my-skill\ndescription: d\n---\n");
  git(repo, "add -A");
  git(repo, "commit -qm init");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  installSkill({ src: `file://${repo}`, store });
  assert.equal(updateSkill("my-skill", store), "up-to-date");
  rmSync(repo, { recursive: true, force: true });
  rmSync(store, { recursive: true, force: true });
});

test("updateSkill overwrites on new commit", () => {
  const repo = makeRepo();
  mkdirSync(join(repo, "my-skill"));
  writeFileSync(join(repo, "my-skill", "SKILL.md"), "---\nname: my-skill\ndescription: v1\n---\n");
  git(repo, "add -A");
  git(repo, "commit -qm init");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  installSkill({ src: `file://${repo}`, store });
  writeFileSync(join(repo, "my-skill", "SKILL.md"), "---\nname: my-skill\ndescription: v2\n---\n");
  git(repo, "add -A");
  git(repo, "commit -qm update");
  const result = updateSkill("my-skill", store);
  assert.match(result, /^updated:/);
  const content = readFileSync(join(store, "skills", "my-skill", "SKILL.md"), "utf8");
  assert.match(content, /v2/);
  rmSync(repo, { recursive: true, force: true });
  rmSync(store, { recursive: true, force: true });
});

test("updateSkill skips local source", () => {
  const src = mkdtempSync(join(tmpdir(), "skctl-src-"));
  writeFileSync(join(src, "SKILL.md"), "---\nname: ls\ndescription: d\n---\n");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  installSkill({ src, store });
  assert.equal(updateSkill("ls", store), "skipped (local source)");
  rmSync(src, { recursive: true, force: true });
  rmSync(store, { recursive: true, force: true });
});