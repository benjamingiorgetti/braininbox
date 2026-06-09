"use client";

import { useRef, useEffect, useState } from "react";
import Image from "next/image";

type FeatureItem = { title: string; body: string };
type Props = {
  t: {
    eyebrow: string;
    headline: readonly [string, string];
    phone: string;
    items: readonly FeatureItem[];
  };
};

export default function Features({ t }: Props) {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(
      ([e]) => { if (e.isIntersecting) setVisible(true); },
      { threshold: 0.1 }
    );
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  return (
    <section
      id="app"
      ref={ref}
      style={{
        padding: "120px 8%",
        background: "#fff",
        borderTop: "1px solid #EEF2F7",
        opacity: visible ? 1 : 0,
        transform: visible ? "translateY(0)" : "translateY(32px)",
        transition: "opacity 0.7s ease, transform 0.7s ease",
      }}
    >
      {/* Header */}
      <div style={{ marginBottom: 72 }}>
        <p style={{ fontSize: 11, fontWeight: 700, letterSpacing: "0.12em", textTransform: "uppercase", color: "#3578E3", marginBottom: 14 }}>
          {t.eyebrow}
        </p>
        <h2
          style={{
            fontFamily: "'Nunito Sans', sans-serif",
            fontSize: "clamp(36px, 4vw, 54px)",
            fontWeight: 900,
            lineHeight: 1.08,
            letterSpacing: "-1.6px",
            color: "#121E49",
          }}
        >
          {t.headline[0]}<br />{t.headline[1]}
        </h2>
      </div>

      {/* Cal AI layout: phone left, feature list right */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "1fr 1fr",
          gap: 80,
          alignItems: "center",
        }}
      >
        {/* Phone mockup */}
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            background: "linear-gradient(140deg, #EEF6FF 0%, #D9EBFF 100%)",
            borderRadius: 32,
            padding: "48px 32px 0",
            overflow: "hidden",
            border: "1px solid rgba(18,30,73,0.06)",
          }}
        >
          <Image
            src={t.phone}
            alt="Brain Inbox app"
            width={260}
            height={540}
            style={{
              borderRadius: "32px 32px 0 0",
              boxShadow: "0 -8px 40px rgba(18,30,73,0.14)",
              display: "block",
            }}
          />
        </div>

        {/* Feature list */}
        <div style={{ display: "flex", flexDirection: "column", gap: 0 }}>
          {t.items.map((item, i) => (
            <div
              key={i}
              style={{
                padding: "28px 0",
                borderBottom: i < t.items.length - 1 ? "1px solid #EEF2F7" : "none",
              }}
            >
              <h3
                style={{
                  fontFamily: "'Nunito Sans', sans-serif",
                  fontSize: 20,
                  fontWeight: 800,
                  color: "#121E49",
                  marginBottom: 8,
                  letterSpacing: "-0.3px",
                }}
              >
                {item.title}
              </h3>
              <p style={{ fontSize: 15, color: "#64748B", lineHeight: 1.7 }}>
                {item.body}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
