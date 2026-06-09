"use client";

import { useRef, useEffect, useState } from "react";
import type { Dictionary } from "@/lib/i18n";

type Props = { t: Dictionary["usecases"] };

export default function UseCases({ t }: Props) {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.1 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  return (
    <section ref={ref} style={{ padding: "120px 8%", background: "#fff", borderTop: "1px solid #EEF2F7" }}>
      <div style={{ marginBottom: 64 }}>
        <p style={{ fontSize: 11, fontWeight: 700, letterSpacing: "0.12em", textTransform: "uppercase", color: "#3578E3", marginBottom: 14 }}>
          {t.eyebrow}
        </p>
        <h2 className="font-display" style={{ fontSize: "clamp(32px, 3.5vw, 50px)", fontWeight: 900, lineHeight: 1.1, letterSpacing: "-1.5px", color: "#121E49" }}>
          {t.headline}
        </h2>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(2, 1fr)", gap: 24 }}>
        {t.items.map((item, i) => (
          <div key={i} style={{
            background: "#F7F9FC", borderRadius: 24, padding: "32px 28px",
            border: "1px solid #EEF2F7",
            opacity: visible ? 1 : 0,
            transform: visible ? "translateY(0)" : "translateY(24px)",
            transition: `opacity 0.6s ease ${i * 0.1}s, transform 0.6s ease ${i * 0.1}s`,
          }}>
            <div style={{ fontSize: 36, marginBottom: 16 }}>{item.emoji}</div>
            <h3 className="font-display" style={{ fontSize: 19, fontWeight: 800, color: "#121E49", marginBottom: 10, letterSpacing: "-0.3px", lineHeight: 1.3 }}>
              {item.title}
            </h3>
            <p style={{ fontSize: 15, color: "#64748B", lineHeight: 1.7 }}>
              {item.body}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}
