import { writeFileSync } from 'fs';

const numberOfColors = 256;
const paneBackgroundDimming = 0.85;
const dimmingColor = '#000000';

const hexToRgb = (hex) => {
  const h = hex.replace('#', '');
  return [parseInt(h.substring(0, 2), 16), parseInt(h.substring(2, 4), 16), parseInt(h.substring(4, 6), 16)];
};

const rgbToHex = (r, g, b) =>
  `#${[r, g, b].map(v => Math.round(v).toString(16).toUpperCase().padStart(2, '0')).join('')}`;

const mixColors = (rgb, dimRgb, amount) =>
  rgb.map((c, i) => c * (1 - amount) + dimRgb[i] * amount);

const hsbToRgb = (h, s, b) => {
  s /= 100;
  b /= 100;
  const c = b * s;
  const x = c * (1 - Math.abs((h / 60) % 2 - 1));
  const m = b - c;
  let r, g, bl;
  if (h < 60)       [r, g, bl] = [c, x, 0];
  else if (h < 120) [r, g, bl] = [x, c, 0];
  else if (h < 180) [r, g, bl] = [0, c, x];
  else if (h < 240) [r, g, bl] = [0, x, c];
  else if (h < 300) [r, g, bl] = [x, 0, c];
  else              [r, g, bl] = [c, 0, x];
  return [Math.round((r + m) * 255), Math.round((g + m) * 255), Math.round((bl + m) * 255)];
};

const dimRgb = hexToRgb(dimmingColor);

const colors = [];
for (let i = 0; i < numberOfColors; i++) {
  const hue = Math.round((360 / numberOfColors) * i);
  const [r, g, b] = hsbToRgb(hue, 100, 100);
  const tabColor = rgbToHex(r, g, b);
  const [dr, dg, db] = mixColors([r, g, b], dimRgb, paneBackgroundDimming);
  const paneBackgroundColor = rgbToHex(dr, dg, db);
  colors.push({ tabColor, paneBackgroundColor });
}

writeFileSync('colors.json', JSON.stringify(colors, null, 2) + '\n');
writeFileSync('colors.txt', colors.map(c => `${c.tabColor} ${c.paneBackgroundColor}`).join('\r\n') + '\r\n');

const cmdLines = colors.map((c, i) => `set "TAB_${i}=${c.tabColor}" & set "BG_${i}=${c.paneBackgroundColor}"`);
cmdLines.push(`set "TOTAL_COLORS=${colors.length}"`);
writeFileSync('colors.cmd', cmdLines.join('\r\n') + '\r\n');

console.log(`Generated ${colors.length} colors in colors.json, colors.txt and colors.cmd`);
