// Wires the user-supplied generated logo (logo_source.png, 1024x1024) into the
// launcher-icon / splash / in-app mark pipeline.
const sharp = require("sharp");
const path = require("path");

const base = path.resolve(__dirname, "..", "..", "assets", "brand");
const src = path.join(base, "logo_source.png");

(async () => {
  // iOS/legacy icon: flatten any transparency onto the dark brand backdrop.
  await sharp(src)
    .flatten({ background: "#0B0C0E" })
    .resize(1024, 1024)
    .png()
    .toFile(path.join(base, "icon_1024.png"));

  // Adaptive foreground + in-app mark keep the full badge.
  await sharp(src).resize(1024, 1024).png().toFile(path.join(base, "icon_foreground_1024.png"));
  await sharp(src).resize(1024, 1024).png().toFile(path.join(base, "siyyarte_mark.png"));

  console.log("done");
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
