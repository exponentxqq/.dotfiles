import { test } from "node:test";
import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, readlinkSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { migrateLocal } from "../src/migrate.ts";

test("migrateLocal registers self-written skills as local symlinks", async () => {
  const srcDir = mkdtempSync(join(tmpdir(), "skctl-src-"));
  mkdirSync(join(srcDir, "my-skill"));
  writeFileSync(join(srcDir, "my-skill", "SKILL.md"), "---\nname: my-skill\ndescription: d\n---\n");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  const report = await migrateLocal(srcDir, store);
  assert.equal(report.length, 1);
  assert.equal(readlinkSync(join(store, "skills", "my-skill")), join(srcDir, "my-skill"));
  rmSync(srcDir, { recursive: true, force: true });
  rmSync(store, { recursive: true, force: true });
});

test("migrateLocal skips non-skill dirs and existing", async () => {
  const srcDir = mkdtempSync(join(tmpdir(), "skctl-src-"));
  mkdirSync(join(srcDir, "no-skill"));
  writeFileSync(join(srcDir, "no-skill", "README.md"), "not a skill");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  const report = await migrateLocal(srcDir, store);
  assert.equal(report.length, 0);
  rmSync(srcDir, { recursive: true, force: true });
  rmSync(store, { recursive: true, force: true });
});

test("migrateLocal skips skills already in registry", async () => {
  const srcDir = mkdtempSync(join(tmpdir(), "skctl-src-"));
  mkdirSync(join(srcDir, "my-skill"));
  writeFileSync(join(srcDir, "my-skill", "SKILL.md"), "---\nname: my-skill\ndescription: d\n---\n");
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  await migrateLocal(srcDir, store);
  const report = await migrateLocal(srcDir, store);
  assert.equal(report.length, 0);
  rmSync(srcDir, { recursive: true, force: true });
  rmSync(store, { recursive: true, force: true });
});