#!/usr/bin/env node
// Renders the iOS App Store icon from the brand mark's own path data.
//
//   node tool/ios_app_icon.js                      writes the 1024 icon
//   node tool/ios_app_icon.js --compare <png>      checks the renderer against
//                                                  a Flutter-rendered PNG
//
// ## Why this is not test/store_assets_test.dart
//
// That test is how the Play assets are made, and it renders the real widgets,
// which is better. It cannot make this one, for two reasons:
//
// - **Apple refuses an icon with an alpha channel** (ITMS-90717), and Flutter's
//   PNG encoder always writes RGBA, even when every pixel is opaque. Stripping
//   the channel needs an image library this project does not depend on.
// - The machine the iOS work was done on has no Flutter SDK, and no Mac either,
//   so a renderer that needs only Node is one that can actually be run.
//
// ## It does not restate the mark
//
// The circles, paths, viewBox, colours and the 56 % mark fraction are all read
// out of `hh_brand.dart` and `hh_colors.dart` - the strings HhBrandMark hands to
// flutter_svg - so there is still one source for the brand. If those files are
// reshaped so that a pattern below no longer matches, this fails loudly rather
// than drawing something else.
//
// `--compare` exists to keep the claim honest: rendered at 512 it must match
// docs/store/icon-512.png, which the Flutter test produced from the widgets.
//
// The output is an 8-bit RGB PNG, square, full-bleed and without rounded
// corners: iOS applies its own mask, exactly as Play does.

'use strict';

const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');

const root = path.resolve(__dirname, '..');
const brand = fs.readFileSync(
  path.join(root, 'lib/src/core/design/hh_brand.dart'),
  'utf8',
);
const colours = fs.readFileSync(
  path.join(root, 'lib/src/core/design/hh_colors.dart'),
  'utf8',
);

function must(match, what) {
  if (!match) {
    throw new Error(`could not find ${what} - has hh_brand.dart changed shape?`);
  }
  return match;
}

/** A Dart string constant, with adjacent literals joined. */
function dartString(name) {
  const decl = must(
    new RegExp(`static const ${name} =([\\s\\S]*?);`).exec(brand),
    name,
  )[1];
  return [...decl.matchAll(/'([^']*)'/g)].map((m) => m[1]).join('');
}

function colour(name) {
  const hex = must(
    new RegExp(`static const ${name} = Color\\(0xFF([0-9A-Fa-f]{6})\\)`).exec(
      colours,
    ),
    `HhColors.${name}`,
  )[1];
  return [0, 2, 4].map((i) => parseInt(hex.slice(i, i + 2), 16));
}

const markFraction = Number(
  must(/static const markFraction = ([0-9.]+);/.exec(brand), 'markFraction')[1],
);
// The pair crop, as HhBrandMark writes it into the viewBox.
const viewBox = must(
  /isSolo \? '[^']+' : '([0-9.]+) ([0-9.]+) ([0-9.]+) ([0-9.]+)'/.exec(brand),
  'the pair viewBox',
)
  .slice(1)
  .map(Number);

const navy = colour('brand900');
const white = colour('white');
const turquoise = colour('accent500');

// ---------------------------------------------------------------- geometry --

/** `<circle cx cy r/>` as a closed polygon, in viewBox units. */
function circle(svg) {
  const [cx, cy, r] = ['cx', 'cy', 'r'].map((a) =>
    Number(must(new RegExp(`${a}="([0-9.]+)"`).exec(svg), a)[1]),
  );
  const points = [];
  const steps = 720;
  for (let i = 0; i < steps; i++) {
    const t = (i / steps) * 2 * Math.PI;
    points.push([cx + r * Math.cos(t), cy + r * Math.sin(t)]);
  }
  return points;
}

/** `<path d>` with absolute M, L, C and Z - all the mark uses. */
function pathPolygon(svg) {
  const d = must(/d="([^"]+)"/.exec(svg), 'path data')[1];
  const tokens = d.match(/[MLCZ]|-?[0-9]*\.?[0-9]+/g);
  const points = [];
  let i = 0;
  let command = null;
  const num = () => Number(tokens[i++]);
  while (i < tokens.length) {
    if (/[MLCZ]/.test(tokens[i])) command = tokens[i++];
    if (command === 'M' || command === 'L') {
      points.push([num(), num()]);
    } else if (command === 'C') {
      const [x0, y0] = points[points.length - 1];
      const x1 = num(), y1 = num(), x2 = num(), y2 = num(), x3 = num(), y3 = num();
      const steps = 96;
      for (let s = 1; s <= steps; s++) {
        const t = s / steps;
        const u = 1 - t;
        points.push([
          u * u * u * x0 + 3 * u * u * t * x1 + 3 * u * t * t * x2 + t * t * t * x3,
          u * u * u * y0 + 3 * u * u * t * y1 + 3 * u * t * t * y2 + t * t * t * y3,
        ]);
      }
    } else if (command === 'Z') {
      // Closing is implicit: every polygon below is treated as closed.
    } else {
      throw new Error(`unsupported path command near "${tokens[i]}"`);
    }
  }
  return points;
}

const left = [circle(dartString('_leftHead')), pathPolygon(dartString('_leftBody'))];
const right = [circle(dartString('_rightHead')), pathPolygon(dartString('_rightBody'))];

// ------------------------------------------------------------------ raster --

/**
 * Coverage, 0..1 per pixel, of a figure: its head and body painted one after
 * the other, as an SVG renderer paints two sibling elements.
 *
 * **Not** one path of two subpaths. The right body winds the other way from
 * the circle, so under the nonzero rule their overlap at the neck would cancel
 * to a hole - a visible notch the real mark does not have.
 */
function coverage(polygons, size, transform) {
  const out = new Float32Array(size * size);
  for (const polygon of polygons) {
    const own = polygonCoverage(polygon, size, transform);
    // Source-over of the same colour: what painting the second shape on top of
    // the first does to an antialiased edge.
    for (let p = 0; p < out.length; p++) out[p] += own[p] * (1 - out[p]);
  }
  return out;
}

/**
 * Coverage of one closed polygon under the nonzero rule.
 *
 * Scanline with 16 sub-rows per pixel and exact horizontal coverage, so edges
 * are antialiased without sampling every pixel sixteen times over.
 */
function polygonCoverage(polygon, size, transform) {
  const out = new Float32Array(size * size);
  const edges = [];
  const pts = polygon.map(transform);
  for (let k = 0; k < pts.length; k++) {
    const a = pts[k];
    const b = pts[(k + 1) % pts.length];
    if (a[1] !== b[1]) edges.push(a[1] < b[1] ? [a, b, 1] : [b, a, -1]);
  }

  const sub = 16;
  for (let row = 0; row < size; row++) {
    for (let s = 0; s < sub; s++) {
      const y = row + (s + 0.5) / sub;
      const crossings = [];
      for (const [a, b, dir] of edges) {
        if (y < a[1] || y >= b[1]) continue;
        crossings.push([a[0] + ((y - a[1]) / (b[1] - a[1])) * (b[0] - a[0]), dir]);
      }
      crossings.sort((p, q) => p[0] - q[0]);

      let winding = 0;
      for (let c = 0; c < crossings.length - 1; c++) {
        winding += crossings[c][1];
        if (winding === 0) continue;
        const x0 = Math.max(0, crossings[c][0]);
        const x1 = Math.min(size, crossings[c + 1][0]);
        if (x1 <= x0) continue;
        const base = row * size;
        const first = Math.floor(x0);
        const last = Math.floor(x1);
        if (first === last) {
          out[base + first] += (x1 - x0) / sub;
          continue;
        }
        out[base + first] += (first + 1 - x0) / sub;
        for (let x = first + 1; x < last && x < size; x++) out[base + x] += 1 / sub;
        if (last < size) out[base + last] += (x1 - last) / sub;
      }
    }
  }
  return out;
}

/** The icon as packed RGB rows. */
function render(size) {
  const [vx, vy, vw, vh] = viewBox;
  const markWidth = size * markFraction;
  const scale = markWidth / vw;
  const offsetX = (size - markWidth) / 2;
  const offsetY = (size - vh * scale) / 2;
  const transform = ([x, y]) => [(x - vx) * scale + offsetX, (y - vy) * scale + offsetY];

  const leftCover = coverage(left, size, transform);
  const rightCover = coverage(right, size, transform);

  const rgb = Buffer.alloc(size * size * 3);
  for (let p = 0; p < size * size; p++) {
    const l = Math.min(1, leftCover[p]);
    const r = Math.min(1, rightCover[p]);
    for (let ch = 0; ch < 3; ch++) {
      let v = navy[ch];
      v = v + (white[ch] - v) * l;
      v = v + (turquoise[ch] - v) * r;
      rgb[p * 3 + ch] = Math.round(v);
    }
  }
  return rgb;
}

// --------------------------------------------------------------------- png --

function chunk(type, data) {
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  const body = Buffer.concat([Buffer.from(type, 'ascii'), data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(zlib.crc32(body));
  return Buffer.concat([length, body, crc]);
}

function encodeRgbPng(rgb, size) {
  const header = Buffer.alloc(13);
  header.writeUInt32BE(size, 0);
  header.writeUInt32BE(size, 4);
  header[8] = 8; // bit depth
  header[9] = 2; // colour type 2: truecolour, **no alpha**
  const stride = size * 3;
  const raw = Buffer.alloc((stride + 1) * size);
  for (let y = 0; y < size; y++) {
    raw[y * (stride + 1)] = 0; // filter: none
    rgb.copy(raw, y * (stride + 1) + 1, y * stride, (y + 1) * stride);
  }
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', header),
    chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

/** Decodes an 8-bit, non-interlaced RGB or RGBA PNG into RGB. */
function decodePng(file) {
  const png = fs.readFileSync(file);
  let offset = 8;
  let width, height, channels;
  const idat = [];
  while (offset < png.length) {
    const length = png.readUInt32BE(offset);
    const type = png.toString('ascii', offset + 4, offset + 8);
    const data = png.subarray(offset + 8, offset + 8 + length);
    if (type === 'IHDR') {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      if (data[8] !== 8 || data[12] !== 0) throw new Error('unsupported PNG');
      channels = { 2: 3, 6: 4 }[data[9]];
      if (!channels) throw new Error('unsupported PNG colour type');
    } else if (type === 'IDAT') {
      idat.push(data);
    }
    offset += 12 + length;
  }
  const raw = zlib.inflateSync(Buffer.concat(idat));
  const stride = width * channels;
  const pixels = Buffer.alloc(stride * height);
  for (let y = 0; y < height; y++) {
    const filter = raw[y * (stride + 1)];
    for (let x = 0; x < stride; x++) {
      const value = raw[y * (stride + 1) + 1 + x];
      const a = x >= channels ? pixels[y * stride + x - channels] : 0;
      const b = y > 0 ? pixels[(y - 1) * stride + x] : 0;
      const c = x >= channels && y > 0 ? pixels[(y - 1) * stride + x - channels] : 0;
      let predicted;
      switch (filter) {
        case 0: predicted = 0; break;
        case 1: predicted = a; break;
        case 2: predicted = b; break;
        case 3: predicted = (a + b) >> 1; break;
        case 4: {
          const p = a + b - c;
          const pa = Math.abs(p - a), pb = Math.abs(p - b), pc = Math.abs(p - c);
          predicted = pa <= pb && pa <= pc ? a : pb <= pc ? b : c;
          break;
        }
        default: throw new Error(`bad PNG filter ${filter}`);
      }
      pixels[y * stride + x] = (value + predicted) & 0xff;
    }
  }
  const rgb = Buffer.alloc(width * height * 3);
  for (let p = 0; p < width * height; p++) {
    for (let ch = 0; ch < 3; ch++) rgb[p * 3 + ch] = pixels[p * channels + ch];
  }
  return { width, height, rgb };
}

// -------------------------------------------------------------------- main --

const args = process.argv.slice(2);
if (args[0] === '--compare') {
  const reference = decodePng(args[1]);
  if (reference.width !== reference.height) throw new Error('not square');
  const ours = render(reference.width);
  let total = 0;
  let worst = 0;
  let differing = 0;
  for (let i = 0; i < ours.length; i++) {
    const d = Math.abs(ours[i] - reference.rgb[i]);
    total += d;
    worst = Math.max(worst, d);
    if (d > 8) differing++;
  }
  const mean = total / ours.length;
  const share = differing / ours.length;
  console.log(
    `${reference.width}px: mean |diff| ${mean.toFixed(3)}, max ${worst}, ` +
      `${(share * 100).toFixed(3)} % of samples off by more than 8`,
  );
  // Antialiasing differs between Skia and this scanline at the edges, and
  // nowhere else. A mean that climbs means the geometry has moved.
  process.exit(mean < 1 && share < 0.01 ? 0 : 1);
}

const size = 1024;
const out =
  args[0] ??
  path.join(root, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png');
fs.writeFileSync(out, encodeRgbPng(render(size), size));
console.log(`wrote ${path.relative(root, out)} (${size} x ${size}, RGB, no alpha)`);
