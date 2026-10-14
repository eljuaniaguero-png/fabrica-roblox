// Exporta los íconos: un PNG de 256 px por ícono (arte/iconos) y la hoja de íconos para
// Roblox (arte/gui/listas/HojaIconos.png, celdas de 128 px) con su mapa (HojaIconos.json).
// Uso: npm install @resvg/resvg-js && node hoja.js
const fs = require('fs');
const path = require('path');
const { Resvg } = require('@resvg/resvg-js');
const ICONOS = require('./iconos.js');
const raiz = path.join(__dirname, '..', '..');
const CELDA = 128, COLUMNAS = 6;
const nombres = Object.keys(ICONOS);
const filas = Math.ceil(nombres.length / COLUMNAS);
let hoja = '';
const lugar = {};
nombres.forEach((nombre, i) => {
  const s = ICONOS[nombre];
  fs.writeFileSync(path.join(raiz, 'iconos', nombre + '.png'), new Resvg(s, { fitTo: { mode: 'width', value: 256 } }).render().asPng());
  const x = (i % COLUMNAS) * 64, y = Math.floor(i / COLUMNAS) * 64;
  lugar[nombre] = [(i % COLUMNAS) * CELDA, Math.floor(i / COLUMNAS) * CELDA];
  hoja += `<g transform="translate(${x} ${y})">${s.replace(/<\/?svg[^>]*>/g, '').replace(/id="([^"]+)"/g, `id="$1_${i}"`).replace(/url\(#([^)]+)\)/g, `url(#$1_${i})`)}</g>`;
});
const doc = `<svg width="${COLUMNAS * 64}" height="${filas * 64}" viewBox="0 0 ${COLUMNAS * 64} ${filas * 64}" xmlns="http://www.w3.org/2000/svg">${hoja}</svg>`;
fs.writeFileSync(path.join(raiz, 'gui', 'listas', 'HojaIconos.png'), new Resvg(doc, { fitTo: { mode: 'width', value: COLUMNAS * CELDA } }).render().asPng());
fs.writeFileSync(path.join(raiz, 'gui', 'listas', 'HojaIconos.json'), JSON.stringify({ Celda: CELDA, Lugar: lugar }, null, 1));
console.log('ok', nombres.length, 'íconos,', COLUMNAS * CELDA, 'x', filas * CELDA);
