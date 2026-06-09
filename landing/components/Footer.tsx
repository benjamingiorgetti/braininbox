"use client";

import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import type { Dictionary } from "@/lib/i18n";

type Props = { t: Dictionary["footer"] };

export default function Footer({ t }: Props) {
  const pathname = usePathname();
  const locale = pathname.startsWith("/es") ? "es" : "en";

  const links = [
    { label: t.links[0], href: `/${locale}/privacy` },
    { label: t.links[1], href: `/${locale}/terms` },
    { label: t.links[2], href: `mailto:hi@thebraininbox.app` },
  ];

  return (
    <footer style={{ background: "var(--primary-900)", color: "rgba(255,255,255,0.5)", padding: "40px 8%", display: "flex", alignItems: "center", justifyContent: "space-between", flexWrap: "wrap", gap: 20, fontSize: 13 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
        <Image src="/icon.png" alt="Brain Inbox" width={28} height={28} style={{ borderRadius: 8 }} />
        <span style={{ fontFamily: "'Nunito Sans', sans-serif", fontWeight: 800, fontSize: 15, color: "#fff" }}>Brain Inbox</span>
      </div>
      <div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
        {links.map(({ label, href }) => (
          <Link
            key={label}
            href={href}
            style={{ color: "rgba(255,255,255,0.45)", textDecoration: "none", transition: "color 0.2s" }}
            onMouseEnter={(e) => ((e.currentTarget as HTMLElement).style.color = "#fff")}
            onMouseLeave={(e) => ((e.currentTarget as HTMLElement).style.color = "rgba(255,255,255,0.45)")}
          >
            {label}
          </Link>
        ))}
      </div>
      <div>{t.copy}</div>
    </footer>
  );
}
