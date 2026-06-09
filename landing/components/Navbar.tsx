"use client";

import { useState, useEffect } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import type { Dictionary } from "@/lib/i18n";

type Props = { t: Dictionary["nav"]; locale: "en" | "es" };

export default function Navbar({ t, locale }: Props) {
  const [scrolled, setScrolled] = useState(false);
  const pathname = usePathname();

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const scrollTo = (id: string) => {
    document.getElementById(id)?.scrollIntoView({ behavior: "smooth" });
  };

  const otherLocale = locale === "en" ? "es" : "en";
  const otherHref =
    locale === "en"
      ? pathname.replace(/^\/en/, "/es") || "/es"
      : pathname.replace(/^\/es/, "") || "/";

  return (
    <nav
      style={{
        position: "fixed",
        top: 38,
        left: 0,
        right: 0,
        zIndex: 150,
        height: 64,
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        padding: "0 5%",
        background: scrolled ? "rgba(247,249,252,0.88)" : "transparent",
        backdropFilter: scrolled ? "blur(20px)" : "none",
        WebkitBackdropFilter: scrolled ? "blur(20px)" : "none",
        borderBottom: scrolled ? "1px solid #EEF2F7" : "1px solid transparent",
        transition: "background 0.3s, border-color 0.3s",
      }}
    >
      {/* Logo */}
      <Link
        href={locale === "en" ? "/en" : "/es"}
        style={{
          display: "flex",
          alignItems: "center",
          gap: 10,
          textDecoration: "none",
        }}
      >
        <Image
          src="/icon.png"
          alt="Brain Inbox"
          width={34}
          height={34}
          style={{ borderRadius: 10 }}
        />
        <span
          style={{
            fontFamily: "'Nunito Sans', sans-serif",
            fontWeight: 900,
            fontSize: 17,
            color: "var(--text-main)",
            letterSpacing: "-0.3px",
          }}
        >
          Brain Inbox
        </span>
      </Link>

      {/* Links */}
      <div style={{ display: "flex", alignItems: "center", gap: 28 }}>
        {[
          { id: "features", label: t.features },
          { id: "app", label: t.app },
          { id: "testimonials", label: locale === "en" ? "Reviews" : "Reseñas" },
        ].map(({ id, label }) => (
          <button
            key={id}
            onClick={() => scrollTo(id)}
            style={{
              background: "none",
              border: "none",
              cursor: "pointer",
              fontSize: 14,
              fontWeight: 500,
              color: "var(--text-secondary)",
              fontFamily: "'Plus Jakarta Sans', sans-serif",
              transition: "color 0.2s",
            }}
            onMouseEnter={(e) =>
              ((e.target as HTMLElement).style.color = "var(--primary-500)")
            }
            onMouseLeave={(e) =>
              ((e.target as HTMLElement).style.color = "var(--text-secondary)")
            }
          >
            {label}
          </button>
        ))}

        {/* Language toggle */}
        <Link
          href={otherHref}
          style={{
            display: "flex",
            alignItems: "center",
            gap: 6,
            padding: "6px 12px",
            borderRadius: 10,
            border: "1.5px solid var(--border)",
            fontSize: 13,
            fontWeight: 700,
            color: "var(--text-secondary)",
            textDecoration: "none",
            background: "var(--surface)",
            transition: "border-color 0.2s, color 0.2s",
          }}
          onMouseEnter={(e) => {
            (e.currentTarget as HTMLElement).style.borderColor =
              "var(--primary-500)";
            (e.currentTarget as HTMLElement).style.color =
              "var(--primary-500)";
          }}
          onMouseLeave={(e) => {
            (e.currentTarget as HTMLElement).style.borderColor =
              "var(--border)";
            (e.currentTarget as HTMLElement).style.color =
              "var(--text-secondary)";
          }}
        >
          <span style={{ fontSize: 15 }}>
            {otherLocale === "en" ? "🇬🇧" : "🇦🇷"}
          </span>
          {otherLocale.toUpperCase()}
        </Link>

        {/* CTA */}
        <button
          onClick={() => scrollTo("waitlist")}
          style={{
            background: "var(--primary-500)",
            color: "#fff",
            border: "none",
            padding: "10px 22px",
            borderRadius: 14,
            fontFamily: "'Plus Jakarta Sans', sans-serif",
            fontSize: 14,
            fontWeight: 700,
            cursor: "pointer",
            boxShadow: "0 6px 20px rgba(66,134,230,0.30)",
            transition: "transform 0.15s, box-shadow 0.15s",
          }}
          onMouseEnter={(e) => {
            (e.currentTarget as HTMLElement).style.transform =
              "translateY(-1px)";
            (e.currentTarget as HTMLElement).style.boxShadow =
              "0 10px 28px rgba(66,134,230,0.40)";
          }}
          onMouseLeave={(e) => {
            (e.currentTarget as HTMLElement).style.transform = "translateY(0)";
            (e.currentTarget as HTMLElement).style.boxShadow =
              "0 6px 20px rgba(66,134,230,0.30)";
          }}
        >
          {t.cta}
        </button>
      </div>
    </nav>
  );
}
