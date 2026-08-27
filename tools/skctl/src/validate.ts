export const NAME_RE = /^[a-z0-9]+(-[a-z0-9]+)*$/;

export function validateName(name: string): boolean {
  return name.length >= 1 && name.length <= 64 && NAME_RE.test(name);
}

export interface SkillFrontmatter {
  name: string;
  description: string;
  [key: string]: string;
}

import matter from "gray-matter";

export function parseFrontmatter(content: string): SkillFrontmatter | null {
  const { data } = matter(content);
  if (typeof data.name !== "string" || typeof data.description !== "string") return null;
  return { ...data, name: data.name, description: data.description } as SkillFrontmatter;
}