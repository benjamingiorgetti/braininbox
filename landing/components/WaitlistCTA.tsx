"use client";

import { useState } from "react";
import Image from "next/image";
import type { Dictionary } from "@/lib/i18n";

type Props = { t: Dictionary["waitlist"] };

export default function WaitlistCTA({ t }: Props) {
  const [email, setEmail] = useState("");
  const [submitted, setSubmitted] = useState(false);

  return (
    <section id="waitlist" style={{ padding: "140px 8%", background: "linear-gradient(180deg, #EEF6FF 0%, #F7F9FC 100%)", borderTop: "1px solid #EEF2F7", textAlign: "center", position: "relative", overflow: "hidden" }}>
      <div style={{ position: "absolute", width: 700, height: 700, background: "radial-gradient(circle, rgba(212,149,238,0.12) 0%, transparent 70%)", top: -300, left: "50%", transform: "translateX(-50%)", pointerEvents: "none" }} />

      {/* Mascot */}
      <div style={{ width: 88, margin: "0 auto 28px", animation: "bounce 3s ease-in-out infinite" }}>
        <Image src="/icon.png" alt="Brain Inbox" width={88} height={88}
          style={{ filter: "drop-shadow(0 12px 28px rgba(18,30,73,0.14))", background: "transparent", borderRadius: 0 }} />
      </div>

      {/* Mascot says */}
      <div style={{ display: "inline-flex", alignItems: "center", gap: 8, background: "#fff", border: "1.5px solid #4286E6", borderRadius: "14px 14px 14px 4px", padding: "8px 18px", fontSize: 14, fontWeight: 600, color: "#121E49", boxShadow: "0 4px 16px rgba(66,134,230,0.12)", marginBottom: 40, position: "relative", zIndex: 1 }}>
        {t.mascotSay}
      </div>

      <h2 className="font-display" style={{ fontSize: "clamp(36px, 4.5vw, 60px)", fontWeight: 900, lineHeight: 1.08, letterSpacing: "-2px", color: "#121E49", marginBottom: 18, position: "relative", zIndex: 1 }}>
        {t.headline}
      </h2>

      <p style={{ fontSize: 18, color: "#64748B", lineHeight: 1.65, maxWidth: 420, margin: "0 auto 44px", position: "relative", zIndex: 1 }}>
        {t.sub}
      </p>

      {!submitted ? (
        <>
          <form
            onSubmit={(e) => { e.preventDefault(); if (email) setSubmitted(true); }}
            style={{ display: "flex", gap: 10, maxWidth: 440, margin: "0 auto 12px", position: "relative", zIndex: 1 }}
          >
            <input
              type="email" value={email} onChange={(e) => setEmail(e.target.value)}
              placeholder={t.inputPlaceholder} required
              style={{ flex: 1, padding: "16px 20px", border: "1.5px solid #D9EBFF", borderRadius: 16, fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: 15, background: "#fff", color: "#121E49", outline: "none", boxShadow: "0 4px 16px rgba(18,30,73,0.06)" }}
              onFocus={(e) => (e.currentTarget.style.borderColor = "#4286E6")}
              onBlur={(e) => (e.currentTarget.style.borderColor = "#D9EBFF")}
            />
            <button type="submit"
              style={{ background: "linear-gradient(180deg, #51A5F1 0%, #3578E3 100%)", color: "#fff", border: "none", padding: "16px 28px", borderRadius: 16, fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: 15, fontWeight: 700, cursor: "pointer", boxShadow: "0 6px 20px rgba(66,134,230,0.35)", whiteSpace: "nowrap", transition: "transform 0.15s" }}
              onMouseEnter={(e) => (e.currentTarget.style.transform = "translateY(-2px)")}
              onMouseLeave={(e) => (e.currentTarget.style.transform = "translateY(0)")}
            >{t.cta}</button>
          </form>
          <p style={{ fontSize: 13, color: "#94A3B8", fontWeight: 500, position: "relative", zIndex: 1 }}>{t.microcopy}</p>
        </>
      ) : (
        <div style={{ display: "inline-flex", alignItems: "center", gap: 10, background: "#fff", border: "1.5px solid #D9EBFF", borderRadius: 16, padding: "18px 28px", fontSize: 16, fontWeight: 600, color: "#2B64D3", boxShadow: "0 8px 24px rgba(18,30,73,0.08)", position: "relative", zIndex: 1 }}>
          🎉 {t.successMsg}
        </div>
      )}

      <style>{`@keyframes bounce { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }`}</style>
    </section>
  );
}
