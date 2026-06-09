"use client";

import { useRef, useEffect, useState } from "react";
import type { Dictionary } from "@/lib/i18n";

type Props = { t: Dictionary["anything"] };

export default function AnythingSection({ t }: Props) {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.1 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  return (
    <section ref={ref} style={{ padding: "120px 8%", background: "#F7F9FC", borderTop: "1px solid #EEF2F7" }}>
      <div style={{ marginBottom: 64 }}>
        <p style={{ fontSize: 11, fontWeight: 700, letterSpacing: "0.12em", textTransform: "uppercase", color: "#3578E3", marginBottom: 14 }}>
          {t.eyebrow}
        </p>
        <h2 className="font-display" style={{ fontSize: "clamp(32px, 3.5vw, 50px)", fontWeight: 900, lineHeight: 1.1, letterSpacing: "-1.5px", color: "#121E49", maxWidth: 500 }}>
          {t.headline}
        </h2>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 20 }}>
        {t.cards.map((card, i) => (
          <div key={i} style={{
            background: "#fff", borderRadius: 20, padding: "24px",
            border: "1px solid #EEF2F7",
            boxShadow: "0 2px 12px rgba(18,30,73,0.05)",
            opacity: visible ? 1 : 0,
            transform: visible ? "translateY(0)" : "translateY(20px)",
            transition: `opacity 0.5s ease ${i * 0.08}s, transform 0.5s ease ${i * 0.08}s`,
          }}>
            {/* Quote */}
            <p style={{ fontSize: 15, color: "#121E49", lineHeight: 1.6, fontStyle: "italic", marginBottom: 20, fontWeight: 500 }}>
              {card.quote}
            </p>
            {/* Divider */}
            <div style={{ borderTop: "1px solid #EEF2F7", paddingTop: 16, display: "flex", alignItems: "center", gap: 10 }}>
              <span style={{ fontSize: 18 }}>{card.icon}</span>
              <span style={{ fontSize: 13, fontWeight: 700, color: "#4286E6" }}>{card.result}</span>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
