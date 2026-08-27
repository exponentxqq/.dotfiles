import { test } from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { DEFAULT_STORE, resolveStore, storePaths } from "../src/paths.ts";

test("resolveStore defaults to XDG path", () => {
  assert.equal(resolveStore(), DEFAULT_STORE);
});

test("resolveStore prefers --store flag", () => {
  assert.equal(resolveStore("/custom/store"), "/custom/store");
});

test("resolveStore reads config.json", () => {
  const dir = mkdtempSync(join(tmpdir(), "skctl-"));
  const cfg = join(dir, "config.json");
  writeFileSync(cfg, JSON.stringify({ store: "/custom/store" }));
  assert.equal(resolveStore(undefined, cfg), "/custom/store");
  rmSync(dir, { recursive: true, force: true });
});

test("resolveStore falls back on bad config", () => {
  const dir = mkdtempSync(join(tmpdir(), "skctl-"));
  const cfg = join(dir, "config.json");
  writeFileSync(cfg, "not json");
  assert.equal(resolveStore(undefined, cfg), DEFAULT_STORE);
  rmSync(dir, { recursive: true, force: true });
});

test("storePaths returns subpaths", () => {
  const p = storePaths("/s");
  assert.deepEqual(p, {
    store: "/s",
    skills: "/s/skills",
    disabled: "/s/skills-disabled",
    registry: "/s/registry.json",
  });
});