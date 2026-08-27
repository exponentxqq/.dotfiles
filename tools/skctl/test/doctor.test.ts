import { test } from "node:test";
import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, readlinkSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { doctor } from "../src/doctor.ts";
import { saveRegistry } from "../src/registry.ts";

void test("doctor creates missing agents symlink", () => {
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  mkdirSync(join(store, "skills"), { recursive: true });
  const link = join(store, "agents-link");
  const report = doctor(store, link);
  assert.equal(readlinkSync(link), join(store, "skills"));
  assert.ok(report.some((l) => l.includes("fixed")));
  rmSync(store, { recursive: true, force: true });
});

void test("doctor repairs wrong agents symlink", () => {
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  mkdirSync(join(store, "skills"), { recursive: true });
  const link = join(store, "agents-link");
  symlinkSync(join(store, "wrong"), link);
  doctor(store, link);
  assert.equal(readlinkSync(link), join(store, "skills"));
  rmSync(store, { recursive: true, force: true });
});

void test("doctor reports orphan registry entries", () => {
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  mkdirSync(join(store, "skills"), { recursive: true });
  saveRegistry(join(store, "registry.json"), {
    skills: { ghost: { source: { type: "local", path: "/x" }, installedAt: "t" } },
  });
  const report = doctor(store, join(store, "link"));
  assert.ok(report.some((l) => l.includes("orphan: ghost")));
  rmSync(store, { recursive: true, force: true });
});

void test("doctor reports broken local symlink target", () => {
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  mkdirSync(join(store, "skills"), { recursive: true });
  const missing = join(store, "missing-src");
  symlinkSync(missing, join(store, "skills", "broken-skill"));
  saveRegistry(join(store, "registry.json"), {
    skills: { "broken-skill": { source: { type: "local", path: missing }, installedAt: "t" } },
  });
  const report = doctor(store, join(store, "link"));
  assert.ok(report.some((l) => l.includes("broken: broken-skill")));
  rmSync(store, { recursive: true, force: true });
});

void test("doctor reports frontmatter name mismatch", () => {
  const store = mkdtempSync(join(tmpdir(), "skctl-store-"));
  mkdirSync(join(store, "skills", "mismatch"), { recursive: true });
  writeFileSync(
    join(store, "skills", "mismatch", "SKILL.md"),
    "---\nname: other\ndescription: d\n---\n",
  );
  const report = doctor(store, join(store, "link"));
  assert.ok(report.some((l) => l.includes("invalid: mismatch")));
  rmSync(store, { recursive: true, force: true });
});
