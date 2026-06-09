import { type Locale, getDictionary, locales } from "@/lib/i18n";
import { notFound } from "next/navigation";
import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import Demo from "@/components/Demo";
import UseCases from "@/components/UseCases";
import AnythingSection from "@/components/AnythingSection";
import Features from "@/components/Features";
import WaitlistCTA from "@/components/WaitlistCTA";
import Footer from "@/components/Footer";
import MascotWidget from "@/components/MascotWidget";

export async function generateStaticParams() {
  return locales.map((locale) => ({ locale }));
}

export default async function Home({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  if (!locales.includes(locale as Locale)) notFound();

  const dict = getDictionary(locale as Locale);
  const typedLocale = locale as Locale;

  return (
    <>
      {/* Announcement bar */}
      <div style={{
        position: "fixed", top: 0, left: 0, right: 0, zIndex: 200,
        background: "linear-gradient(90deg, #4286E6 0%, #7263BA 100%)",
        color: "#fff", textAlign: "center", padding: "9px 16px",
        fontSize: 13, fontWeight: 600, letterSpacing: "0.01em",
        fontFamily: "'Plus Jakarta Sans', sans-serif",
      }}>
        {dict.announcementBar}
        <span style={{ opacity: 0.8, fontWeight: 400, marginLeft: 8 }}>{dict.announcementSub}</span>
      </div>

      <div style={{ height: 38 }} />
      <Navbar t={dict.nav} locale={typedLocale} />

      <main>
        <div id="hero"><Hero t={dict.hero} /></div>
        <div id="demo"><Demo t={dict.demo} /></div>
        <div id="usecases"><UseCases t={dict.usecases} /></div>
        <div id="anything"><AnythingSection t={dict.anything} /></div>
        <div id="features"><Features t={dict.features} /></div>
        <div id="waitlist"><WaitlistCTA t={dict.waitlist} /></div>
      </main>

      <Footer t={dict.footer} />
      <MascotWidget locale={typedLocale} />
    </>
  );
}
