"use client";

import { useEffect, useState } from "react";
import Image from "next/image";

type Props = {
  locale: "en" | "es";
};

const MESSAGES = {
  en: {
    hero:     "Talk like you think. I'll sort the rest. 🧠",
    demo:     "See? Messy in, clean out. ✨",
    features: "I turn messy thoughts into clean plans. ✨",
    waitlist: "Your voice note in. A plan out. 🎉",
    default:  "Hey! Drop me a thought and I'll organize it. 👋",
  },
  es: {
    hero:     "Hablá como pensás. El resto lo ordeno yo. 🧠",
    demo:     "¿Ves? Entra el caos, sale el plan. ✨",
    features: "Convierto el caos en planes claros. ✨",
    waitlist: "Tu nota de voz entra. Un plan sale. 🎉",
    default:  "¡Hola! Tirame un pensamiento y lo ordeno. 👋",
  },
};

const SECTIONS = ["hero", "demo", "features", "waitlist"] as const;
type Section = (typeof SECTIONS)[number];

export default function MascotWidget({ locale }: Props) {
  const [message, setMessage] = useState<string>("");
  const [visible, setVisible] = useState(false);
  const [bounce, setBounce] = useState(false);
  const [show, setShow] = useState(false);

  useEffect(() => {
    // Show widget after 1.5s
    const t = setTimeout(() => setShow(true), 1500);
    return () => clearTimeout(t);
  }, []);

  useEffect(() => {
    const msgs = MESSAGES[locale];

    const observers: IntersectionObserver[] = [];

    SECTIONS.forEach((sectionId) => {
      const el = document.getElementById(sectionId);
      if (!el) return;

      const obs = new IntersectionObserver(
        ([entry]) => {
          if (entry.isIntersecting) {
            const msg = msgs[sectionId as Section];
            triggerMessage(msg);
          }
        },
        { threshold: 0.4 }
      );
      obs.observe(el);
      observers.push(obs);
    });

    // Show default message on mount
    setTimeout(() => triggerMessage(msgs.default), 2000);

    return () => observers.forEach((o) => o.disconnect());
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [locale]);

  function triggerMessage(msg: string) {
    setMessage(msg);
    setVisible(true);
    setBounce(true);
    setTimeout(() => setBounce(false), 500);
    // Auto-hide after 4s
    setTimeout(() => setVisible(false), 4000);
  }

  if (!show) return null;

  return (
    <>
      <style>{`
        @keyframes mascotSlideIn {
          from { transform: translateY(20px); opacity: 0; }
          to   { transform: translateY(0);    opacity: 1; }
        }
        @keyframes mascotBounce {
          0%,100% { transform: translateY(0); }
          25%      { transform: translateY(-8px); }
          75%      { transform: translateY(-4px); }
        }
        @keyframes bubblePop {
          0%   { transform: scale(0.85) translateY(6px); opacity: 0; }
          60%  { transform: scale(1.04) translateY(-2px); opacity: 1; }
          100% { transform: scale(1)    translateY(0);    opacity: 1; }
        }
        @keyframes bubbleFade {
          from { opacity: 1; }
          to   { opacity: 0; transform: translateY(-4px); }
        }
        .mascot-widget {
          position: fixed;
          bottom: 28px;
          right: 28px;
          z-index: 200;
          display: flex;
          flex-direction: column;
          align-items: flex-end;
          gap: 10px;
          animation: mascotSlideIn 0.5s ease forwards;
        }
        .mascot-img {
          width: 80px;
          height: 80px;
          cursor: pointer;
          transition: transform 0.2s;
          filter: drop-shadow(0 8px 20px rgba(18,30,73,0.22));
          border-radius: 0 !important;
          background: transparent !important;
        }
        .mascot-img:hover { transform: scale(1.06); }
        .mascot-img.bounce { animation: mascotBounce 0.5s ease; }
        .speech-bubble {
          background: #fff;
          border: 1.5px solid #4286E6;
          border-radius: 16px 16px 4px 16px;
          padding: 10px 16px;
          font-family: 'Plus Jakarta Sans', system-ui, sans-serif;
          font-size: 13px;
          font-weight: 600;
          color: #121E49;
          max-width: 220px;
          line-height: 1.5;
          box-shadow: 0 4px 20px rgba(66,134,230,0.18);
          animation: bubblePop 0.35s cubic-bezier(0.34,1.56,0.64,1) forwards;
        }
        .speech-bubble.hiding {
          animation: bubbleFade 0.3s ease forwards;
        }
      `}</style>

      <div className="mascot-widget">
        {visible && (
          <div className="speech-bubble" key={message}>
            {message}
          </div>
        )}
        <Image
          src="/icon.png"
          alt="Brain Inbox mascot"
          width={80}
          height={80}
          className={`mascot-img${bounce ? " bounce" : ""}`}
          onClick={() => triggerMessage(MESSAGES[locale].default)}
          style={{ background: "transparent", borderRadius: 0 }}
          priority
        />
      </div>
    </>
  );
}
