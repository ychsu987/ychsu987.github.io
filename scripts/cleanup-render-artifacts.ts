// Post-render cleanup for quarto render / quarto publish.
// Removes source-tree leftovers after output has been copied to _site/.

const outputDirRel = (Deno.env.get("QUARTO_PROJECT_OUTPUT_DIR") ?? "_site")
  .replace(/\\/g, "/");
const outputDirName = outputDirRel.split("/").filter(Boolean).pop() ?? "_site";

const skipDirs = new Set([
  ".git",
  ".quarto",
  "_freeze",
  "_extensions",
  "_site",
  outputDirName,
  "AILT9015",
  "docs",
  "node_modules",
  "scripts",
]);

let removedDirs = 0;
let removedFiles = 0;

function join(parent: string, name: string): string {
  return `${parent}/${name}`.replace(/\\/g, "/").replace(/\/+/g, "/");
}

async function removePath(path: string): Promise<void> {
  await Deno.remove(path, { recursive: true });
}

async function walk(dir: string): Promise<void> {
  for await (const entry of Deno.readDir(dir)) {
    const path = join(dir, entry.name);
    if (entry.isDirectory) {
      if (skipDirs.has(entry.name)) {
        continue;
      }
      if (entry.name.endsWith("_files")) {
        await removePath(path);
        removedDirs += 1;
        console.log(`Removed ${path}`);
        continue;
      }
      await walk(path);
      continue;
    }
    if (entry.name.endsWith(".quarto_ipynb")) {
      await removePath(path);
      removedFiles += 1;
      console.log(`Removed ${path}`);
    }
  }
}

async function removeIfExists(path: string): Promise<void> {
  try {
    await removePath(path);
    console.log(`Removed ${path}`);
  } catch (error) {
    if (!(error instanceof Deno.errors.NotFound)) {
      throw error;
    }
  }
}

await walk(".");
await removeIfExists(join(outputDirRel, "_freeze"));
await removeIfExists(join(outputDirRel, "site_output"));

console.log(
  `Cleanup finished: ${removedDirs} *_files director${removedDirs === 1 ? "y" : "ies"}, ${removedFiles} .quarto_ipynb file${removedFiles === 1 ? "" : "s"}.`,
);
