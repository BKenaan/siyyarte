// Builds the Siyyarte icon from the Tahoe photo:
//  - de-badges the grille (covers the bowtie with matching slats)
//  - places the car on the dark brand background
//  - adds a red maintenance wrench (lower-right)
const sharp = require("sharp");
const path = require("path");

const base = path.resolve(__dirname, "..", "..", "assets", "brand");
const src = path.join(base, "tahoe_source.png");

const svgBuf = (s) => Buffer.from(s);

// Dark charcoal brand gradient, full bleed.
const bg = `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024">
  <defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#262A2E"/><stop offset="1" stop-color="#0B0C0E"/>
  </linearGradient></defs>
  <rect width="1024" height="1024" fill="url(#g)"/></svg>`;

// Grille patch that hides the bowtie (dark with horizontal slats).
const patch = `<svg xmlns="http://www.w3.org/2000/svg" width="112" height="56">
  <rect width="112" height="56" fill="#0c0b0a"/>
  <g stroke="#6b655d" stroke-width="1.6">
    <line x1="0" y1="5" x2="112" y2="5"/><line x1="0" y1="13" x2="112" y2="13"/>
    <line x1="0" y1="21" x2="112" y2="21"/><line x1="0" y1="29" x2="112" y2="29"/>
    <line x1="0" y1="37" x2="112" y2="37"/><line x1="0" y1="45" x2="112" y2="45"/>
    <line x1="0" y1="52" x2="112" y2="52"/>
  </g></svg>`;

// Red combination wrench.
const wrench = `<svg xmlns="http://www.w3.org/2000/svg" width="360" height="360" viewBox="0 0 360 360">
  <defs><linearGradient id="wr" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#FF5347"/><stop offset="1" stop-color="#C0140B"/>
  </linearGradient></defs>
  <g transform="translate(180 180) rotate(-35)">
    <rect x="-74" y="-16" width="150" height="32" rx="16" fill="url(#wr)"/>
    <circle cx="-80" cy="0" r="31" fill="none" stroke="url(#wr)" stroke-width="16"/>
    <path d="M74 -31 A 31 31 0 1 0 74 31" fill="none" stroke="url(#wr)" stroke-width="16"/>
  </g></svg>`;

(async () => {
  const car = await sharp(src).trim().toBuffer(); // 705x441
  const carW = 860;
  const scale = carW / 705;
  const carH = Math.round(441 * scale);
  const carLeft = Math.round((1024 - carW) / 2);
  const carTop = Math.round((1024 - carH) / 2);

  const carScaled = await sharp(car).resize(carW, carH).png().toBuffer();
  const patchPng = await sharp(svgBuf(patch)).png().toBuffer();
  const wrenchPng = await sharp(svgBuf(wrench)).png().toBuffer();

  // Bowtie centre in car-local coords ≈ (190,200).
  const patchLeft = Math.round(carLeft + 190 * scale - 56);
  const patchTop = Math.round(carTop + 200 * scale - 28);
  const wrenchLeft = 1024 - 360 + 20;
  const wrenchTop = 1024 - 360 + 16;

  const carLayer = { input: carScaled, left: carLeft, top: carTop };
  const patchLayer = { input: patchPng, left: patchLeft, top: patchTop };
  const wrenchLayer = { input: wrenchPng, left: wrenchLeft, top: wrenchTop };

  // Full icon (dark bg).
  await sharp(svgBuf(bg))
    .composite([carLayer, patchLayer, wrenchLayer])
    .png()
    .toFile(path.join(base, "icon_1024.png"));

  // Transparent content (car de-badged + wrench) for adaptive fg + in-app mark.
  const content = await sharp({
    create: { width: 1024, height: 1024, channels: 4, background: { r: 0, g: 0, b: 0, alpha: 0 } },
  })
    .composite([carLayer, patchLayer, wrenchLayer])
    .png()
    .toBuffer();

  await sharp(content).toFile(path.join(base, "siyyarte_mark.png"));

  const fg = await sharp(content).resize(780, 780, { fit: "inside" }).png().toBuffer();
  await sharp({
    create: { width: 1024, height: 1024, channels: 4, background: { r: 0, g: 0, b: 0, alpha: 0 } },
  })
    .composite([{ input: fg, gravity: "center" }])
    .png()
    .toFile(path.join(base, "icon_foreground_1024.png"));

  console.log("done");
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
