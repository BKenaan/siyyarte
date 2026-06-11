// Rasterizes the brand SVGs to PNGs for launcher icons / splash.
// Run from functions/: node scripts/rasterize_icons.js  (needs `sharp`)
const sharp = require("sharp");
const path = require("path");

const base = path.resolve(__dirname, "..", "..", "assets", "brand");

async function render(svg, out, size) {
  await sharp(path.join(base, svg), { density: 384 })
    .resize(size, size)
    .png()
    .toFile(path.join(base, out));
  console.log("wrote", out, `${size}x${size}`);
}

(async () => {
  await render("siyyarte_icon_full.svg", "icon_1024.png", 1024);
  await render("siyyarte_icon_fg.svg", "icon_foreground_1024.png", 1024);
  console.log("done");
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
