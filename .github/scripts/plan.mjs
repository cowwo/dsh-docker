// 把 npm 的 dist-tags（latest / next …）反解成「版本 → 要打的通道标签」矩阵。
// 输出给 GitHub Actions 的 matrix 使用：{ "include": [ { "version": "…", "channels": "latest" } ] }
import { execFileSync } from "node:child_process";
import { appendFileSync } from "node:fs";

const PKG = process.env.PKG || "@deepseek-ai/dsh";
const CHANNELS = (process.env.CHANNELS || "latest").split(/\s+/).filter(Boolean);
const INPUT = (process.env.INPUT_VERSION || "").trim();

const distTags = JSON.parse(
  execFileSync("npm", ["view", PKG, "dist-tags", "--json"], { encoding: "utf8" }),
);

// 同一个版本可能被多个通道指向 → 合并成一行，一次构建打多个标签
const byVersion = new Map();
if (INPUT) {
  byVersion.set(INPUT, CHANNELS.filter((c) => distTags[c] === INPUT));
} else {
  for (const c of CHANNELS) {
    const v = distTags[c];
    if (typeof v !== "string") continue;
    if (!byVersion.has(v)) byVersion.set(v, []);
    byVersion.get(v).push(c);
  }
}

const include = [...byVersion.entries()].map(([version, channels]) => ({
  version,
  channels: channels.join(" "),
}));

console.error("上游 dist-tags:", JSON.stringify(distTags));
for (const row of include) {
  console.error(`  ${row.version}  ←  ${row.channels || "(仅版本号)"}`);
}
if (include.length === 0) console.error("没有需要处理的版本");

const matrix = JSON.stringify({ include });
if (process.env.GITHUB_OUTPUT) {
  appendFileSync(process.env.GITHUB_OUTPUT, `matrix=${matrix}\n`);
  appendFileSync(process.env.GITHUB_OUTPUT, `count=${include.length}\n`);
} else {
  console.log(matrix);
}
