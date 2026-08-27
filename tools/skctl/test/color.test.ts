import { test } from "node:test";
import assert from "node:assert/strict";
import { makeColor } from "../src/color.ts";

test("makeColor(true) wraps text in ANSI codes", () => {
  const c = makeColor(true);
  assert.equal(c.green("ok"), "\x1b[32mok\x1b[0m");
  assert.equal(c.red("err"), "\x1b[31merr\x1b[0m");
  assert.equal(c.yellow("warn"), "\x1b[33mwarn\x1b[0m");
  assert.equal(c.bold("name"), "\x1b[1mname\x1b[0m");
  assert.equal(c.dim("muted"), "\x1b[2mmuted\x1b[0m");
  assert.equal(c.cyan("path"), "\x1b[36mpath\x1b[0m");
  assert.equal(c.magenta("git"), "\x1b[35mgit\x1b[0m");
});

test("makeColor(false) returns plain text", () => {
  const c = makeColor(false);
  assert.equal(c.green("ok"), "ok");
  assert.equal(c.red("err"), "err");
  assert.equal(c.bold("name"), "name");
  assert.equal(c.dim("muted"), "muted");
});