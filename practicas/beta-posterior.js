import React, { useMemo, useState } from "https://esm.sh/react@19.1.0";
import { createRoot } from "https://esm.sh/react-dom@19.1.0/client?external=react";

const h = React.createElement;
const WIDTH = 720;
const HEIGHT = 340;
const MARGIN = { top: 20, right: 20, bottom: 48, left: 58 };
const BINS = 40;
const DRAWS = 10000;

function seededRandom(seed) {
  let value = seed >>> 0;
  return () => {
    value += 0x6D2B79F5;
    let t = value;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function gammaSample(shape, random) {
  if (shape < 1) return gammaSample(shape + 1, random) * Math.pow(random(), 1 / shape);
  const d = shape - 1 / 3;
  const c = 1 / Math.sqrt(9 * d);
  for (;;) {
    let x;
    let v;
    do {
      const u1 = Math.max(random(), Number.EPSILON);
      const u2 = random();
      x = Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);
      v = 1 + c * x;
    } while (v <= 0);
    v *= v * v;
    const u = random();
    if (u < 1 - 0.0331 * x ** 4 || Math.log(u) < 0.5 * x * x + d * (1 - v + Math.log(v))) return d * v;
  }
}

function logGamma(z) {
  const coefficients = [676.5203681218851, -1259.1392167224028, 771.3234287776531, -176.6150291621406, 12.507343278686905, -0.13857109526572012, 9.984369578019572e-6, 1.5056327351493116e-7];
  if (z < 0.5) return Math.log(Math.PI) - Math.log(Math.sin(Math.PI * z)) - logGamma(1 - z);
  z -= 1;
  let x = 0.9999999999998099;
  coefficients.forEach((coefficient, i) => { x += coefficient / (z + i + 1); });
  const t = z + coefficients.length - 0.5;
  return 0.9189385332046727 + (z + 0.5) * Math.log(t) - t + Math.log(x);
}

function betaDensity(x, a, b) {
  if (x <= 0 || x >= 1) return 0;
  return Math.exp((a - 1) * Math.log(x) + (b - 1) * Math.log1p(-x) - (logGamma(a) + logGamma(b) - logGamma(a + b)));
}

function PosteriorPlot() {
  const [successes, setSuccesses] = useState(27);
  const n = 40;
  const a = 2 + successes;
  const b = 2 + n - successes;
  const plot = useMemo(() => {
    const random = seededRandom(123 + successes);
    const bins = Array(BINS).fill(0);
    for (let i = 0; i < DRAWS; i += 1) {
      const x = gammaSample(a, random);
      const y = gammaSample(b, random);
      bins[Math.min(BINS - 1, Math.floor((x / (x + y)) * BINS))] += 1;
    }
    const density = bins.map((count) => count / DRAWS * BINS);
    const max = Math.max(...density, ...Array.from({ length: 101 }, (_, i) => betaDensity(i / 100, a, b)));
    return { density, max };
  }, [successes, a, b]);

  const innerWidth = WIDTH - MARGIN.left - MARGIN.right;
  const innerHeight = HEIGHT - MARGIN.top - MARGIN.bottom;
  const x = (value) => MARGIN.left + value * innerWidth;
  const y = (value) => MARGIN.top + innerHeight - value / plot.max * innerHeight;
  const curve = Array.from({ length: 201 }, (_, i) => {
    const value = i / 200;
    return `${i ? "L" : "M"}${x(value).toFixed(2)},${y(betaDensity(value, a, b)).toFixed(2)}`;
  }).join(" ");

  return h("section", { className: "beta-posterior" },
    h("label", { htmlFor: "beta-successes" }, `Exitos observados: ${successes} de ${n}`),
    h("input", { id: "beta-successes", type: "range", min: 0, max: n, step: 1, value: successes, onChange: (event) => setSuccesses(Number(event.target.value)), "aria-describedby": "beta-posterior-summary" }),
    h("p", { id: "beta-posterior-summary", className: "beta-summary", "aria-live": "polite" }, `Posterior: Beta(${a}, ${b}) · ${DRAWS.toLocaleString("es-ES")} simulaciones`),
    h("svg", { className: "beta-chart", viewBox: `0 0 ${WIDTH} ${HEIGHT}`, role: "img", "aria-label": `Histograma de 10.000 simulaciones de una posterior Beta(${a}, ${b}) y su densidad analitica` },
      ...[0, 0.25, 0.5, 0.75, 1].map((tick) => h("g", { key: tick },
        h("line", { x1: x(0), x2: x(1), y1: y(tick * plot.max), y2: y(tick * plot.max), stroke: "#d8e1e8" }),
        h("text", { x: x(0) - 9, y: y(tick * plot.max) + 4, textAnchor: "end" }, (tick * plot.max).toFixed(1)))),
      ...plot.density.map((value, index) => h("rect", { key: index, x: x(index / BINS) + 1, y: y(value), width: innerWidth / BINS - 2, height: Math.max(0, MARGIN.top + innerHeight - y(value)), fill: "#d8e7f3" })),
      h("path", { d: curve, fill: "none", stroke: "#d95f02", strokeWidth: 2.5 }),
      h("line", { x1: x(0), x2: x(1), y1: MARGIN.top + innerHeight, y2: MARGIN.top + innerHeight, stroke: "#526575" }),
      ...[0, 0.25, 0.5, 0.75, 1].map((tick) => h("text", { key: `x${tick}`, x: x(tick), y: HEIGHT - 20, textAnchor: "middle" }, tick.toFixed(2))),
      h("text", { x: WIDTH / 2, y: HEIGHT - 2, textAnchor: "middle" }, "θ"),
      h("text", { x: MARGIN.left, y: 14, fill: "#12304a" }, "Densidad")),
    h("p", { className: "beta-legend" }, h("span", { className: "beta-legend-bars" }), "Simulaciones", " ", h("span", { className: "beta-legend-line" }), "Densidad Beta analítica"));
}

const root = document.getElementById("beta-posterior-root");
if (root) createRoot(root).render(h(PosteriorPlot));
