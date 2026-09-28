import React, { useEffect, useRef, useState } from "https://esm.sh/react@19.1.0";
import { createRoot } from "https://esm.sh/react-dom@19.1.0/client?external=react";

const h = React.createElement;
const MAX_TRACE = 600;

function normal() {
  const u = Math.max(Number.EPSILON, Math.random());
  return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * Math.random());
}

function nextState(state, rho) {
  const sd = Math.sqrt(Math.max(0, 1 - rho * rho));
  const x = rho * state.y + sd * normal();
  const y = rho * x + sd * normal();
  return { x, y };
}

function Plot({ trace, state }) {
  const ref = useRef(null);
  useEffect(() => {
    const canvas = ref.current;
    const rect = canvas.getBoundingClientRect();
    const ratio = window.devicePixelRatio || 1;
    canvas.width = Math.max(1, rect.width * ratio);
    canvas.height = Math.max(1, rect.height * ratio);
    const ctx = canvas.getContext("2d");
    ctx.scale(ratio, ratio);
    const w = rect.width;
    const height = rect.height;
    const pad = 24;
    const size = Math.min(w - pad * 2, height - pad * 2);
    const left = (w - size) / 2;
    const top = (height - size) / 2;
    const px = (v) => left + ((v + 3.5) / 7) * size;
    const py = (v) => top + ((3.5 - v) / 7) * size;

    ctx.clearRect(0, 0, w, height);
    ctx.fillStyle = "#fff";
    ctx.fillRect(left, top, size, size);
    ctx.strokeStyle = "#d8e1e8";
    ctx.lineWidth = 1;
    for (let tick = -3; tick <= 3; tick += 1) {
      ctx.beginPath(); ctx.moveTo(px(tick), top); ctx.lineTo(px(tick), top + size); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(left, py(tick)); ctx.lineTo(left + size, py(tick)); ctx.stroke();
    }
    ctx.strokeStyle = "#64748b";
    ctx.strokeRect(left, top, size, size);
    ctx.fillStyle = "#356d9a";
    for (const point of trace) {
      ctx.beginPath(); ctx.arc(px(point.x), py(point.y), 2.2, 0, 2 * Math.PI); ctx.fill();
    }
    ctx.fillStyle = "#d23b3b";
    ctx.beginPath(); ctx.arc(px(state.x), py(state.y), 5, 0, 2 * Math.PI); ctx.fill();
    ctx.fillStyle = "#243746";
    ctx.font = "13px sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("x", left + size / 2, height - 2);
    ctx.save(); ctx.translate(12, top + size / 2); ctx.rotate(-Math.PI / 2); ctx.fillText("y", 0, 0); ctx.restore();
  }, [trace, state]);
  return h("canvas", { ref, className: "gibbs-plot", role: "img", "aria-label": "Gráfico de dispersión de los estados recientes de la cadena Gibbs" });
}

function Sampler() {
  const [rho, setRho] = useState(0.8);
  const [state, setState] = useState({ x: 0, y: 0 });
  const stateRef = useRef(state);
  const [trace, setTrace] = useState([{ x: 0, y: 0 }]);
  const [running, setRunning] = useState(false);
  const [speed, setSpeed] = useState(5);
  const [iterations, setIterations] = useState(0);

  function step(count = 1) {
    let current = stateRef.current;
    const additions = [];
    for (let i = 0; i < count; i += 1) {
      current = nextState(current, rho);
      additions.push(current);
    }
    stateRef.current = current;
    setState(current);
    setTrace((old) => old.concat(additions).slice(-MAX_TRACE));
    setIterations((n) => n + count);
  }

  useEffect(() => {
    if (!running) return undefined;
    const timer = window.setInterval(() => step(speed), 700);
    return () => window.clearInterval(timer);
  }, [running, speed, rho]);

  function reset() {
    setRunning(false);
    const initial = { x: 0, y: 0 };
    stateRef.current = initial;
    setState(initial);
    setTrace([{ x: 0, y: 0 }]);
    setIterations(0);
  }

  return h("section", { className: "gibbs-sampler" },
    h("div", { className: "gibbs-controls" },
      h("label", { htmlFor: "gibbs-rho" }, `Correlación (ρ): ${rho.toFixed(2)}`),
      h("input", { id: "gibbs-rho", type: "range", min: "-0.95", max: "0.95", step: "0.05", value: rho, onChange: (event) => setRho(Number(event.target.value)), "aria-describedby": "gibbs-rho-help" }),
      h("span", { id: "gibbs-rho-help", className: "gibbs-help" }, "La varianza condicional es 1 − ρ²."),
      h("label", { htmlFor: "gibbs-speed" }, `Iteraciones por actualización: ${speed}`),
      h("input", { id: "gibbs-speed", type: "range", min: "1", max: "25", step: "1", value: speed, onChange: (event) => setSpeed(Number(event.target.value)) }),
      h("div", { className: "gibbs-buttons" },
        h("button", { type: "button", onClick: () => step(), disabled: running }, "Un paso"),
        h("button", { type: "button", onClick: () => setRunning((value) => !value), "aria-pressed": running }, running ? "Pausar" : "Ejecutar"),
        h("button", { type: "button", onClick: reset }, "Reiniciar")),
      h("p", { className: "gibbs-status", "aria-live": "polite" }, `Iteración ${iterations} · Estado actual: x = ${state.x.toFixed(3)}, y = ${state.y.toFixed(3)}`)),
    h(Plot, { trace, state }));
}

const root = document.getElementById("gibbs-sampler-root");
if (root) createRoot(root).render(h(Sampler));
