import type { Metadata } from "next";
import { type Locale, locales } from "@/lib/i18n";
import { notFound } from "next/navigation";

export const metadata: Metadata = {
  title: "Privacy Policy – Brain Inbox",
  description: "How Brain Inbox collects, uses, and protects your data.",
};

export async function generateStaticParams() {
  return locales.map((locale) => ({ locale }));
}

const EFFECTIVE_DATE = "June 9, 2026";
const CONTACT_EMAIL = "privacy@thebraininbox.app";
const APP_NAME = "Brain Inbox";
const WEBSITE = "thebraininbox.app";

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div style={{ marginBottom: 44 }}>
      <h2 style={{ fontFamily: "'Nunito Sans', sans-serif", fontSize: 20, fontWeight: 800, color: "#121E49", marginBottom: 14, letterSpacing: "-0.3px" }}>
        {title}
      </h2>
      <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>{children}</div>
    </div>
  );
}

const p: React.CSSProperties = { margin: 0 };
const li: React.CSSProperties = { marginBottom: 4 };
const ul: React.CSSProperties = { paddingLeft: 24, margin: "4px 0 0 0" };
const tableStyle: React.CSSProperties = { width: "100%", borderCollapse: "collapse", fontSize: 14, marginTop: 8 };
const th: React.CSSProperties = { textAlign: "left", padding: "8px 12px", background: "#F1F5F9", fontWeight: 700, color: "#475569", borderBottom: "1px solid #E2E8F0" };
const td: React.CSSProperties = { padding: "8px 12px", borderBottom: "1px solid #F1F5F9", verticalAlign: "top", color: "#334155" };

function PrivacyEn() {
  return (
    <div style={{ lineHeight: 1.75, fontSize: 16, color: "#334155" }}>

      <Section title="1. Who we are">
        <p style={p}><strong>{APP_NAME}</strong> is an independent iOS app that turns voice notes into structured tasks, ideas, and reminders. We operate the {APP_NAME} app and the website {WEBSITE}. There is no company behind this yet — it is developed by Benjamin Giorgetti.</p>
        <p style={p}>Privacy questions: <a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a></p>
      </Section>

      <Section title="2. The core principle: your data stays on your device">
        <p style={p}>{APP_NAME} is <strong>local-first</strong>. Everything you capture — voice notes, tasks, ideas, reminders — is stored on your device using an encrypted on-device database. We do not run servers that store your personal data.</p>
        <p style={p}>The only data that leaves your device is what is strictly required to process your voice note through AI (see Section 3).</p>
      </Section>

      <Section title="3. What data leaves your device and why">
        <p style={p}>When you record a voice note, two requests are made to external AI services:</p>
        <table style={tableStyle}>
          <thead>
            <tr>
              <th style={th}>Data sent</th>
              <th style={th}>Sent to</th>
              <th style={th}>Purpose</th>
              <th style={th}>Retained?</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style={td}>Audio file (.m4a)</td>
              <td style={td}>OpenAI (Whisper API)</td>
              <td style={td}>Transcription — converts speech to text</td>
              <td style={td}>Not retained by OpenAI (API use, not training)</td>
            </tr>
            <tr>
              <td style={td}>Text transcript</td>
              <td style={td}>OpenAI (GPT-4o-mini API)</td>
              <td style={td}>Extraction — identifies tasks, ideas, dates, people</td>
              <td style={td}>Not retained by OpenAI (API use, not training)</td>
            </tr>
          </tbody>
        </table>
        <p style={p}>OpenAI processes this data on our behalf under a data processing agreement. Per <a href="https://openai.com/enterprise-privacy" style={{ color: "#4286E6" }}>OpenAI's API terms</a>, data submitted via the API is not used to train their models. We send the minimum data necessary — no name, device ID, or account information is included in these requests.</p>
      </Section>

      <Section title="4. Subscription and payments">
        <p style={p}>Subscriptions and in-app purchases are handled exclusively by Apple's App Store. We do not see or store your payment information.</p>
        <p style={p}>We use <strong>RevenueCat</strong> to manage subscription status. RevenueCat receives your Apple-assigned anonymous subscriber ID and your subscription state (active, expired, etc.). It does not receive your name, email, or payment details. See <a href="https://www.revenuecat.com/privacy" style={{ color: "#4286E6" }}>RevenueCat's Privacy Policy</a>.</p>
      </Section>

      <Section title="5. Google Calendar (optional)">
        <p style={p}>If you choose to connect Google Calendar, {APP_NAME} uses Google's OAuth 2.0 to request permission to create calendar events on your behalf. We request only the minimum scope required (<code>calendar.events</code>). We do not read, copy, or store your existing calendar data. You can disconnect Google Calendar at any time from the app's Settings screen.</p>
      </Section>

      <Section title="6. What we do not collect">
        <ul style={ul}>
          <li style={li}>We do not collect your name, email address, or any account information (the app has no accounts in its current version).</li>
          <li style={li}>We do not use advertising networks or track you across other apps or websites.</li>
          <li style={li}>We do not collect precise location data.</li>
          <li style={li}>We do not sell data to third parties.</li>
          <li style={li}>We do not use analytics SDKs. Usage events are stored locally on your device only.</li>
        </ul>
      </Section>

      <Section title="7. Microphone permission">
        <p style={p}>{APP_NAME} requests microphone access solely to record voice notes. Audio is recorded locally and immediately sent to OpenAI for transcription. The original audio file is then deleted from our processing pipeline. You can revoke microphone permission at any time in iOS Settings → Privacy & Security → Microphone.</p>
      </Section>

      <Section title="8. Data deletion">
        <p style={p}>Because all data is stored on your device, you can delete everything at any time:</p>
        <ul style={ul}>
          <li style={li}><strong>In-app:</strong> Settings → Delete All Data — permanently removes all voice notes, tasks, ideas, and preferences from your device.</li>
          <li style={li}><strong>Uninstall:</strong> Deleting the app removes all local data.</li>
          <li style={li}><strong>Individual items:</strong> Swipe to delete on any item in the inbox.</li>
        </ul>
        <p style={p}>There is no server-side account to delete because we do not store your data on our servers. For any questions, contact <a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a>.</p>
      </Section>

      <Section title="9. Children's privacy">
        <p style={p}>{APP_NAME} is not directed at children under 13 (or under 16 in the EEA). We do not knowingly collect data from children. If you believe a child has used the app and you have concerns, contact us immediately.</p>
      </Section>

      <Section title="10. Your rights (GDPR, CCPA, and international users)">
        <p style={p}>Because {APP_NAME} does not maintain a server-side account or database with your personal data, most privacy rights are exercised directly on your device (see Section 8).</p>
        <p style={p}>For any data processed by third-party services (OpenAI, RevenueCat) on our behalf, you can contact us at <a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a> and we will coordinate accordingly. Applicable rights include: access, correction, erasure, restriction of processing, data portability, and the right to object.</p>
        <p style={p}><strong>California residents (CCPA):</strong> We do not sell personal information. You have the right to know what data is collected, to request deletion, and to non-discrimination for exercising these rights.</p>
      </Section>

      <Section title="11. Security">
        <p style={p}>On-device data is protected by iOS's built-in data protection (AES-256 encryption tied to your device passcode). Data in transit to OpenAI and RevenueCat uses HTTPS/TLS. No system is perfectly secure; we take commercially reasonable measures to protect your information.</p>
      </Section>

      <Section title="12. Changes to this policy">
        <p style={p}>If we make material changes — such as adding a new third-party service or changing how we process data — we will notify you via an in-app notice before the change takes effect. Continued use after the notification period constitutes acceptance.</p>
      </Section>

      <Section title="13. Contact">
        <p style={p}>For any privacy-related questions or requests:<br /><a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a></p>
      </Section>

    </div>
  );
}

function PrivacyEs() {
  return (
    <div style={{ lineHeight: 1.75, fontSize: 16, color: "#334155" }}>

      <Section title="1. Quiénes somos">
        <p style={p}><strong>{APP_NAME}</strong> es una app iOS independiente que convierte notas de voz en tareas, ideas y recordatorios estructurados. Operamos la app {APP_NAME} y el sitio web {WEBSITE}. No hay una empresa detrás aún — la desarrolla Benjamin Giorgetti.</p>
        <p style={p}>Consultas de privacidad: <a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a></p>
      </Section>

      <Section title="2. El principio base: tus datos se quedan en tu dispositivo">
        <p style={p}>{APP_NAME} es <strong>local-first</strong>. Todo lo que capturás — notas de voz, tareas, ideas, recordatorios — se almacena en tu dispositivo usando una base de datos cifrada. No operamos servidores que almacenen tus datos personales.</p>
        <p style={p}>Los únicos datos que salen de tu dispositivo son los estrictamente necesarios para procesar tu nota de voz con IA (ver Sección 3).</p>
      </Section>

      <Section title="3. Qué datos salen de tu dispositivo y por qué">
        <p style={p}>Cuando grabás una nota de voz, se hacen dos solicitudes a servicios de IA externos:</p>
        <table style={tableStyle}>
          <thead>
            <tr>
              <th style={th}>Dato enviado</th>
              <th style={th}>Destinatario</th>
              <th style={th}>Propósito</th>
              <th style={th}>¿Lo retienen?</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style={td}>Archivo de audio (.m4a)</td>
              <td style={td}>OpenAI (Whisper API)</td>
              <td style={td}>Transcripción — convierte voz a texto</td>
              <td style={td}>No (uso de API, no entrenamiento)</td>
            </tr>
            <tr>
              <td style={td}>Texto transcripto</td>
              <td style={td}>OpenAI (GPT-4o-mini API)</td>
              <td style={td}>Extracción — identifica tareas, ideas, fechas, personas</td>
              <td style={td}>No (uso de API, no entrenamiento)</td>
            </tr>
          </tbody>
        </table>
        <p style={p}>OpenAI procesa estos datos en nuestro nombre bajo un acuerdo de procesamiento de datos. Según los <a href="https://openai.com/enterprise-privacy" style={{ color: "#4286E6" }}>términos de la API de OpenAI</a>, los datos enviados vía API no se usan para entrenar sus modelos. Enviamos solo los datos mínimos necesarios — sin nombre, ID de dispositivo ni información de cuenta.</p>
      </Section>

      <Section title="4. Suscripciones y pagos">
        <p style={p}>Las suscripciones y compras dentro de la app son gestionadas exclusivamente por el App Store de Apple. No vemos ni almacenamos tu información de pago.</p>
        <p style={p}>Usamos <strong>RevenueCat</strong> para gestionar el estado de la suscripción. RevenueCat recibe tu ID de suscriptor anónimo asignado por Apple y el estado de tu suscripción. No recibe tu nombre, email ni datos de pago. Ver <a href="https://www.revenuecat.com/privacy" style={{ color: "#4286E6" }}>Política de Privacidad de RevenueCat</a>.</p>
      </Section>

      <Section title="5. Google Calendar (opcional)">
        <p style={p}>Si elegís conectar Google Calendar, {APP_NAME} usa OAuth 2.0 de Google para solicitar permiso de crear eventos de calendario en tu nombre. Solo solicitamos el permiso mínimo requerido (<code>calendar.events</code>). No leemos, copiamos ni almacenamos tu calendario existente. Podés desconectar Google Calendar cuando quieras desde Configuración.</p>
      </Section>

      <Section title="6. Lo que no recopilamos">
        <ul style={ul}>
          <li style={li}>No recopilamos nombre, email ni datos de cuenta (la app no tiene cuentas en su versión actual).</li>
          <li style={li}>No usamos redes publicitarias ni te rastreamos entre apps o sitios web.</li>
          <li style={li}>No recopilamos ubicación precisa.</li>
          <li style={li}>No vendemos datos a terceros.</li>
          <li style={li}>No usamos SDKs de analíticas. Los eventos de uso se almacenan solo localmente.</li>
        </ul>
      </Section>

      <Section title="7. Permiso del micrófono">
        <p style={p}>{APP_NAME} solicita acceso al micrófono únicamente para grabar notas de voz. El audio se graba localmente y se envía a OpenAI para transcripción. El archivo de audio original se elimina después del procesamiento. Podés revocar el permiso del micrófono en Configuración de iOS → Privacidad y seguridad → Micrófono.</p>
      </Section>

      <Section title="8. Eliminación de datos">
        <p style={p}>Dado que todos los datos están en tu dispositivo, podés eliminarlos en cualquier momento:</p>
        <ul style={ul}>
          <li style={li}><strong>Desde la app:</strong> Configuración → Eliminar todos los datos — borra permanentemente notas de voz, tareas, ideas y preferencias de tu dispositivo.</li>
          <li style={li}><strong>Desinstalando la app:</strong> Eliminar la app borra todos los datos locales.</li>
          <li style={li}><strong>Ítems individuales:</strong> Deslizá para eliminar cualquier ítem en el inbox.</li>
        </ul>
        <p style={p}>No hay cuenta en el servidor que eliminar porque no almacenamos tus datos en nuestros servidores. Para consultas: <a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a>.</p>
      </Section>

      <Section title="9. Privacidad de menores">
        <p style={p}>{APP_NAME} no está dirigida a menores de 13 años (ni de 16 en el EEE). No recopilamos datos de menores conscientemente. Si creés que un menor usó la app, contactanos de inmediato.</p>
      </Section>

      <Section title="10. Tus derechos (GDPR, CCPA y usuarios internacionales)">
        <p style={p}>Dado que {APP_NAME} no mantiene una base de datos en servidor con tus datos personales, la mayoría de los derechos de privacidad se ejercen directamente en tu dispositivo (ver Sección 8).</p>
        <p style={p}>Para datos procesados por servicios de terceros (OpenAI, RevenueCat) en nuestro nombre, podés contactarnos a <a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a> y coordinaremos. Los derechos aplicables incluyen: acceso, rectificación, supresión, limitación del tratamiento, portabilidad y oposición.</p>
        <p style={p}><strong>Usuarios en California (CCPA):</strong> No vendemos información personal. Tenés derecho a saber qué datos se recopilan, a solicitar su eliminación y a no sufrir discriminación por ejercer estos derechos.</p>
      </Section>

      <Section title="11. Seguridad">
        <p style={p}>Los datos en el dispositivo están protegidos por la protección de datos integrada de iOS (cifrado AES-256 vinculado a tu contraseña del dispositivo). Los datos en tránsito hacia OpenAI y RevenueCat usan HTTPS/TLS. Tomamos medidas razonables para proteger tu información.</p>
      </Section>

      <Section title="12. Cambios a esta política">
        <p style={p}>Si hacemos cambios materiales — como agregar un nuevo servicio de terceros o cambiar cómo procesamos datos — te notificaremos mediante un aviso en la app antes de que el cambio entre en vigor. El uso continuado tras el período de notificación implica aceptación.</p>
      </Section>

      <Section title="13. Contacto">
        <p style={p}>Para consultas o solicitudes de privacidad:<br /><a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a></p>
      </Section>

    </div>
  );
}

export default async function PrivacyPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  if (!locales.includes(locale as Locale)) notFound();
  const isEs = locale === "es";

  return (
    <html lang={locale}>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@800;900&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet" />
      </head>
      <body style={{ background: "#F7F9FC", margin: 0 }}>
        <main style={{ maxWidth: 760, margin: "0 auto", padding: "72px 5% 120px", fontFamily: "'Plus Jakarta Sans', sans-serif", color: "#121E49" }}>
          <a
            href={`/${locale}`}
            style={{ display: "inline-flex", alignItems: "center", gap: 6, fontSize: 14, color: "#64748B", textDecoration: "none", marginBottom: 48, fontWeight: 500 }}
          >
            ← {isEs ? "Volver" : "Back"}
          </a>

          <p style={{ fontSize: 12, fontWeight: 700, letterSpacing: "0.1em", textTransform: "uppercase", color: "#4286E6", marginBottom: 12 }}>
            {isEs ? "Política de Privacidad" : "Privacy Policy"}
          </p>
          <h1 style={{ fontFamily: "'Nunito Sans', sans-serif", fontSize: 40, fontWeight: 900, letterSpacing: "-1.5px", marginBottom: 8, lineHeight: 1.1 }}>
            {isEs ? "Tu privacidad, en serio." : "Your privacy, seriously."}
          </h1>
          <p style={{ fontSize: 14, color: "#64748B", marginBottom: 16 }}>
            {isEs ? `Última actualización: ${EFFECTIVE_DATE}` : `Last updated: ${EFFECTIVE_DATE}`}
          </p>

          <div style={{ background: "#EFF6FF", border: "1px solid #BFDBFE", borderRadius: 12, padding: "14px 18px", marginBottom: 56, fontSize: 14, color: "#1E40AF", lineHeight: 1.6 }}>
            <strong>{isEs ? "Resumen rápido:" : "TL;DR:"}</strong>{" "}
            {isEs
              ? "Brain Inbox es local-first. Tus notas, tareas e ideas se guardan solo en tu dispositivo. El único dato que sale es el audio de tu nota de voz — se envía a OpenAI para transcribir y se elimina de inmediato. No te rastreamos, no vendemos tus datos."
              : "Brain Inbox is local-first. Your notes, tasks, and ideas are stored only on your device. The only data that leaves is your voice note audio — sent to OpenAI for transcription and immediately discarded. We don't track you or sell your data."}
          </div>

          {isEs ? <PrivacyEs /> : <PrivacyEn />}

          <div style={{ marginTop: 64, paddingTop: 32, borderTop: "1px solid #E2E8F0", fontSize: 13, color: "#94A3B8" }}>
            © 2026 {APP_NAME} · {WEBSITE}
          </div>
        </main>
      </body>
    </html>
  );
}
