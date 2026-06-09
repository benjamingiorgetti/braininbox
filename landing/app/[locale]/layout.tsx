import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { locales, type Locale, getDictionary } from "@/lib/i18n";
import "../globals.css";

export async function generateStaticParams() {
  return locales.map((locale) => ({ locale }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  const isEs = locale === "es";
  return {
    title: isEs
      ? "Brain Inbox – Tu segundo cerebro, por fin organizado"
      : "Brain Inbox – Your second brain, finally organized",
    description: isEs
      ? "Hablá libremente. Brain Inbox convierte tus pensamientos desordenados en tareas y recordatorios claros."
      : "Speak freely. Brain Inbox turns messy thoughts and voice notes into clear tasks and reminders.",
    metadataBase: new URL("https://thebraininbox.app"),
    alternates: {
      canonical: locale === "en" ? "/en" : `/es`,
      languages: { en: "/en", es: "/es" },
    },
  };
}

export default async function LocaleLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  if (!locales.includes(locale as Locale)) notFound();

  return (
    <html lang={locale}>
      <body>{children}</body>
    </html>
  );
}
