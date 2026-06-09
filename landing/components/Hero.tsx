"use client";

import { useEffect, useRef, useState } from "react";
import Image from "next/image";
import type { Dictionary } from "@/lib/i18n";

type Props = { t: Dictionary["hero"] };

export default function Hero({ t }: Props) {
  const phoneRef = useRef<HTMLDivElement>(null);
  const [email, setEmail] = useState("");
  const [submitted, setSubmitted] = useState(false);

  useEffect(() => {
    const handleMouse = (e: MouseEvent) => {
      if (!phoneRef.current) return;
      const x = (e.clientX / window.innerWidth - 0.5) * 10;
      const y = (e.clientY / window.innerHeight - 0.5) * 7;
      phoneRef.current.style.transform = `translate(${x}px, ${y}px) rotateY(${x * 0.4}deg) rotateX(${-y * 0.3}deg)`;
    };
    window.addEventListener("mousemove", handleMouse);
    return () => window.removeEventListener("mousemove", handleMouse);
  }, []);

  return (
    <section style={{ minHeight: "100vh", display: "grid", gridTemplateColumns: "1fr 1fr", alignItems: "center", padding: "0 8%", gap: 80, position: "relative", overflow: "hidden" }}>
      {/* Ambient glows */}
      <div style={{ position: "absolute", width: 700, height: 700, background: "radial-gradient(circle, rgba(212,149,238,0.13) 0%, transparent 65%)", top: -300, right: -200, pointerEvents: "none" }} />
      <div style={{ position: "absolute", width: 500, height: 500, background: "radial-gradient(circle, rgba(66,134,230,0.10) 0%, transparent 65%)", bottom: -200, left: -100, pointerEvents: "none" }} />

      {/* Left */}
      <div style={{ position: "relative", zIndex: 2 }}>
        <div style={{ display: "inline-flex", alignItems: "center", gap: 8, background: "#EEF6FF", border: "1px solid #D9EBFF", color: "#2B64D3", fontSize: 11, fontWeight: 700, letterSpacing: "0.1em", textTransform: "uppercase", padding: "6px 14px", borderRadius: 100, marginBottom: 28 }}>
          <span>✦</span> {t.eyebrow}
        </div>

        <h1 className="font-display" style={{ fontSize: "clamp(38px, 4.5vw, 64px)", fontWeight: 900, lineHeight: 1.08, letterSpacing: "-2px", color: "#121E49", marginBottom: 24, maxWidth: 560 }}>
          {t.headline}
        </h1>

        <p style={{ fontSize: 18, lineHeight: 1.7, color: "#64748B", maxWidth: 440, marginBottom: 40 }}>
          {t.sub}
        </p>

        {!submitted ? (
          <>
            <form onSubmit={(e) => { e.preventDefault(); if (email) setSubmitted(true); }} style={{ display: "flex", gap: 10, maxWidth: 460, marginBottom: 12 }}>
              <input
                type="email" value={email} onChange={(e) => setEmail(e.target.value)}
                placeholder={t.inputPlaceholder} required
                style={{ flex: 1, padding: "15px 20px", border: "1.5px solid #EEF2F7", borderRadius: 16, fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: 15, background: "#fff", color: "#121E49", outline: "none" }}
                onFocus={(e) => (e.currentTarget.style.borderColor = "#4286E6")}
                onBlur={(e) => (e.currentTarget.style.borderColor = "#EEF2F7")}
              />
              <button type="submit" style={{ background: "linear-gradient(180deg, #51A5F1 0%, #3578E3 100%)", color: "#fff", border: "none", padding: "15px 28px", borderRadius: 16, fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: 15, fontWeight: 700, cursor: "pointer", boxShadow: "0 6px 20px rgba(66,134,230,0.35)", whiteSpace: "nowrap", transition: "transform 0.15s" }}
                onMouseEnter={(e) => (e.currentTarget.style.transform = "translateY(-2px)")}
                onMouseLeave={(e) => (e.currentTarget.style.transform = "translateY(0)")}
              >{t.cta}</button>
            </form>
            <p style={{ fontSize: 13, color: "#94A3B8", fontWeight: 500 }}>{t.microcopy}</p>
          </>
        ) : (
          <div style={{ display: "inline-flex", alignItems: "center", gap: 10, background: "#fff", border: "1.5px solid #D9EBFF", borderRadius: 16, padding: "16px 24px", fontSize: 15, fontWeight: 600, color: "#2B64D3", boxShadow: "0 8px 24px rgba(18,30,73,0.08)" }}>
            🎉 {t.successMsg}
          </div>
        )}
      </div>

      {/* Right — phone */}
      <div style={{ display: "flex", justifyContent: "center", alignItems: "center", position: "relative", zIndex: 2, perspective: 1200 }}>
        <div ref={phoneRef} style={{ transition: "transform 0.08s ease-out", transformStyle: "preserve-3d" }}>
          <Image src="/screenshots/home.png" alt="Brain Inbox app" width={300} height={620}
            style={{ borderRadius: 44, boxShadow: "0 40px 80px rgba(18,30,73,0.20), 0 0 0 1px rgba(18,30,73,0.05)", display: "block" }}
            priority
          />
        </div>
      </div>
    </section>
  );
}
