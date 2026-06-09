"use client";

import { useRef, useEffect, useState } from "react";
import Image from "next/image";
import type { Dictionary } from "@/lib/i18n";

type Props = { t: Dictionary["demo"] };

const TYPE_COLORS: Record<string, { bg: string; color: string }> = {
  Task:          { bg: "#EEF6FF", color: "#2B64D3" },
  Calendar:      { bg: "#F0FDF4", color: "#166534" },
  Reminder:      { bg: "#FFF7ED", color: "#92400E" },
  Tarea:         { bg: "#EEF6FF", color: "#2B64D3" },
  Calendario:    { bg: "#F0FDF4", color: "#166534" },
  Recordatorio:  { bg: "#FFF7ED", color: "#92400E" },
  Idea:          { bg: "#F5F3FF", color: "#5B21B6" },
};

export default function Demo({ t }: Props) {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);
  const [rowsVisible, setRowsVisible] = useState(0);

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => {
      if (e.isIntersecting) setVisible(true);
    }, { threshold: 0.2 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  useEffect(() => {
    if (!visible) return;
    t.rows.forEach((_, i) => {
      setTimeout(() => setRowsVisible(i + 1), 400 + i * 300);
    });
  }, [visible, t.rows]);

  return (
    <section
      ref={ref}
      style={{
        padding: "120px 8%",
        background: "#F7F9FC",
        borderTop: "1px solid #EEF2F7",
      }}
    >
      <div style={{ maxWidth: 760, margin: "0 auto" }}>
        {/* Header */}
        <p style={{ fontSize: 11, fontWeight: 700, letterSpacing: "0.12em", textTransform: "uppercase", color: "#3578E3", marginBottom: 14 }}>
          {t.eyebrow}
        </p>
        <h2 className="font-display" style={{ fontSize: "clamp(32px, 3.5vw, 50px)", fontWeight: 900, lineHeight: 1.1, letterSpacing: "-1.5px", color: "#121E49", marginBottom: 56 }}>
          {t.headline}
        </h2>

        {/* Input bubble */}
        <div style={{ marginBottom: 32 }}>
          <p style={{ fontSize: 12, fontWeight: 700, color: "#94A3B8", letterSpacing: "0.08em", textTransform: "uppercase", marginBottom: 12 }}>
            {t.inputLabel}
          </p>
          <div style={{
            display: "flex", alignItems: "flex-start", gap: 16,
            background: "#121E49", borderRadius: 20, padding: "20px 24px",
            opacity: visible ? 1 : 0,
            transform: visible ? "translateY(0)" : "translateY(16px)",
            transition: "opacity 0.5s ease, transform 0.5s ease",
          }}>
            <span style={{ fontSize: 20, flexShrink: 0, marginTop: 2 }}>🎙️</span>
            <p style={{ fontSize: 16, color: "#fff", lineHeight: 1.6, fontStyle: "italic", margin: 0, opacity: 0.9 }}>
              {t.input}
            </p>
          </div>
        </div>

        {/* Arrow */}
        <div style={{ textAlign: "center", fontSize: 24, color: "#CBD5E1", marginBottom: 32, opacity: visible ? 1 : 0, transition: "opacity 0.5s ease 0.3s" }}>
          ↓
        </div>

        {/* Output rows */}
        <div style={{ marginBottom: 12 }}>
          <p style={{ fontSize: 12, fontWeight: 700, color: "#94A3B8", letterSpacing: "0.08em", textTransform: "uppercase", marginBottom: 16 }}>
            {t.outputLabel}
          </p>
          <div style={{ background: "#fff", borderRadius: 20, border: "1px solid #EEF2F7", overflow: "hidden", boxShadow: "0 4px 24px rgba(18,30,73,0.06)" }}>
            {t.rows.map((row, i) => {
              const colors = TYPE_COLORS[row.type] || { bg: "#F7F9FC", color: "#64748B" };
              return (
                <div key={i} style={{
                  display: "flex", alignItems: "center", justifyContent: "space-between",
                  padding: "18px 24px",
                  borderBottom: i < t.rows.length - 1 ? "1px solid #EEF2F7" : "none",
                  opacity: rowsVisible > i ? 1 : 0,
                  transform: rowsVisible > i ? "translateX(0)" : "translateX(-12px)",
                  transition: "opacity 0.4s ease, transform 0.4s ease",
                }}>
                  <span style={{ fontSize: 16, color: "#121E49", fontWeight: 500 }}>{row.result}</span>
                  <span style={{ fontSize: 12, fontWeight: 700, padding: "4px 12px", borderRadius: 100, background: colors.bg, color: colors.color, flexShrink: 0 }}>
                    {row.type}
                  </span>
                </div>
              );
            })}
          </div>
        </div>

        {/* Mascot bubble */}
        <div style={{
          display: "flex", alignItems: "center", gap: 14, marginTop: 28,
          opacity: rowsVisible >= t.rows.length ? 1 : 0,
          transform: rowsVisible >= t.rows.length ? "translateY(0)" : "translateY(8px)",
          transition: "opacity 0.4s ease, transform 0.4s ease",
        }}>
          <Image src="/icon.png" alt="Brain Inbox" width={44} height={44} style={{ borderRadius: 0, filter: "drop-shadow(0 4px 8px rgba(18,30,73,0.15))", flexShrink: 0 }} />
          <div style={{ background: "#fff", border: "1.5px solid #4286E6", borderRadius: "16px 16px 16px 4px", padding: "10px 18px", fontSize: 14, fontWeight: 600, color: "#121E49", boxShadow: "0 4px 16px rgba(66,134,230,0.15)" }}>
            {t.mascotSay}
          </div>
        </div>
      </div>
    </section>
  );
}
