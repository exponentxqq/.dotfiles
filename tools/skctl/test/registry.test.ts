import { test } from "node:test";
import assert from "node:assert/strict";
import { existsSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { loadRegistry, saveRegistry } from "../src/registry.ts";

test("loadRegistry returns empty for missing file", () => {
  const dir = mkdtempSync(join(tmpdir(), "skctl-"));
  assert.deepEqual(loadRegistry(join(dir, "nope.json")), { skills: {} });
  rmSync(dir, { recursive: true, force: true });
});

test("saveRegistry then loadRegistry round-trips", () => {
  const dir = mkdtempSync(join(tmpdir(), "skctl-"));
  const path = join(dir, "registry.json");
  const reg = {
    skills: {
      pdf: {
        source: { type: "git" as const, url: "https://github.com/anthropics/skills", subdir: "skills/pdf" },
        installedCommit: "abc1234",
        installedAt: "2026-08-27T00:00:00.000Z",
      },
    },
  };
  saveRegistry(path, reg);
  assert.ok(existsSync(path));
  assert.deepEqual(loadRegistry(path), reg);
  rmSync(dir, { recursive: true, force: true });
});

test("loadRegistry returns empty for corrupt json", () => {
  const dir = mkdtempSync(join(tmpdir(), "skctl-"));
  const path = join(dir, "registry.json");
  writeFileSync(path, "not json");
  assert.deepEqual(loadRegistry(path), { skills: {} });
  rmSync(dir, { recursive: true, force: true });
});

test("saveRegistry creates nested parent dirs", () => {
  const dir = mkdtempSync(join(tmpdir(), "skctl-"));
  const path = join(dir, "a", "b", "registry.json");
  saveRegistry(path, { skills: {} });
  assert.ok(existsSync(path));
  rmSync(dir, { recursive: true, force: true });
});