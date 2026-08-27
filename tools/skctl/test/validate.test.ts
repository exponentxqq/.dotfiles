import { test } from "node:test";
import assert from "node:assert/strict";
import { parseFrontmatter, validateName } from "../src/validate.ts";

test("validateName accepts valid names", () => {
  assert.equal(validateName("pdf"), true);
  assert.equal(validateName("architecture-diagram"), true);
  assert.equal(validateName("a1-b2"), true);
});

test("validateName rejects invalid names", () => {
  assert.equal(validateName("Pdf"), false);
  assert.equal(validateName("a--b"), false);
  assert.equal(validateName("-ab"), false);
  assert.equal(validateName("ab-"), false);
  assert.equal(validateName("a b"), false);
});

test("validateName enforces length limits", () => {
  assert.equal(validateName(""), false);
  assert.equal(validateName("a".repeat(65)), false);
  assert.equal(validateName("a".repeat(64)), true);
});

test("parseFrontmatter parses name and description", () => {
  const content = `---
name: pdf
description: 'Use this skill for PDF files'
license: MIT
---
# Body`;
  const fm = parseFrontmatter(content);
  assert.ok(fm);
  assert.equal(fm!.name, "pdf");
  assert.equal(fm!.description, "Use this skill for PDF files");
});

test("parseFrontmatter handles quoted description with colon", () => {
  const content = `---
name: pptx
description: "Use this skill: any time a .pptx file is involved"
---
# Body`;
  const fm = parseFrontmatter(content);
  assert.ok(fm);
  assert.equal(fm!.description, "Use this skill: any time a .pptx file is involved");
});

test("parseFrontmatter returns null for missing frontmatter", () => {
  assert.equal(parseFrontmatter("# no frontmatter"), null);
});

test("parseFrontmatter returns null without name or description", () => {
  assert.equal(parseFrontmatter("---\nname: x\n---\n"), null);
});

test("parseFrontmatter reads multi-line folded description", () => {
  const md = "---\nname: demo\ndescription: >-\n  line one\n  line two\n---\nbody";
  const fm = parseFrontmatter(md);
  assert.equal(fm?.description, "line one line two");
});