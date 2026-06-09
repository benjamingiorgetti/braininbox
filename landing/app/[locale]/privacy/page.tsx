import type { Metadata } from "next";
import { type Locale, locales } from "@/lib/i18n";
import { notFound } from "next/navigation";

export const metadata: Metadata = {
  title: "Privacy Policy – Brain Inbox",
};

export async function generateStaticParams() {
  return locales.map((locale) => ({ locale }));
}

const EFFECTIVE_DATE = "June 8, 2026";
const CONTACT_EMAIL = "privacy@thebraininbox.app";
const APP_NAME = "Brain Inbox";
const WEBSITE = "thebraininbox.app";

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div style={{ marginBottom: 40 }}>
      <h2 style={{ fontFamily: "'Nunito Sans', sans-serif", fontSize: 20, fontWeight: 800, color: "#121E49", marginBottom: 12, letterSpacing: "-0.3px" }}>
        {title}
      </h2>
      <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>{children}</div>
    </div>
  );
}

function PrivacyEn() {
  return (
    <div style={{ lineHeight: 1.75, fontSize: 16, color: "#334155" }}>
      <Section title="1. Who we are">
        <p>{APP_NAME} operates the {APP_NAME} mobile application and the website {WEBSITE}. We are an independent developer. For privacy-related questions, contact us at <a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a>.</p>
      </Section>
      <Section title="2. What data we collect">
        <p>We collect only what&apos;s necessary to provide the service:</p>
        <ul style={{ paddingLeft: 24, display: "flex", flexDirection: "column", gap: 8 }}>
          <li><strong>Account data:</strong> email address when you join the waitlist or create an account.</li>
          <li><strong>Voice and text input:</strong> the notes, voice recordings, and text you submit to the app. Used solely to generate your tasks, reminders, and ideas.</li>
          <li><strong>Usage data:</strong> anonymous, aggregated analytics about how you use the app. We do not track you across apps or websites.</li>
          <li><strong>Device data:</strong> device type, OS version, and app version — used for debugging and compatibility.</li>
        </ul>
        <p>We do <strong>not</strong> collect payment information (handled entirely by Apple), government IDs, financial data, or precise location.</p>
      </Section>
      <Section title="3. How we use your data">
        <ul style={{ paddingLeft: 24, display: "flex", flexDirection: "column", gap: 8 }}>
          <li>To provide and improve the {APP_NAME} service.</li>
          <li>To process your voice notes and text and return structured output.</li>
          <li>To send product updates if you opted in.</li>
          <li>To diagnose bugs and improve performance.</li>
        </ul>
        <p>We do <strong>not</strong> sell your data or use it for advertising.</p>
      </Section>
      <Section title="4. AI processing">
        <p>Your voice notes and text inputs may be processed by third-party AI providers (such as OpenAI) to generate structured output. These providers act as processors on our behalf and are contractually prohibited from using your data to train their own models. We send only the minimum data necessary.</p>
      </Section>
      <Section title="5. Data storage and security">
        <p>Your data is stored on secure cloud servers with encryption in transit (HTTPS/TLS) and at rest. Access is restricted to authorized personnel. No system is 100% secure, but we take industry-standard measures to protect your information.</p>
      </Section>
      <Section title="6. Data retention">
        <p>We retain your data while your account is active or as needed to provide the service. You can request deletion at any time by emailing <a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a>. We process deletion requests within 30 days.</p>
      </Section>
      <Section title="7. Your rights (GDPR and international users)">
        <p>If you are in the EEA, UK, or another region with applicable privacy laws, you have the right to: access your data, correct inaccurate data, request deletion (&ldquo;right to be forgotten&rdquo;), restrict or object to processing, data portability, and to withdraw consent at any time. Email us to exercise any of these rights.</p>
      </Section>
      <Section title="8. Third-party services">
        <ul style={{ paddingLeft: 24, display: "flex", flexDirection: "column", gap: 8 }}>
          <li><strong>AI providers:</strong> to process voice and text input.</li>
          <li><strong>Cloud infrastructure:</strong> to store and serve your data securely.</li>
          <li><strong>Analytics:</strong> anonymous and aggregated usage data only.</li>
          <li><strong>Apple App Store:</strong> handles all in-app purchases. Apple&apos;s privacy policy governs payment data.</li>
        </ul>
        <p>We do not use advertising networks or sell data to data brokers.</p>
      </Section>
      <Section title="9. Children's privacy">
        <p>{APP_NAME} is not directed at children under 13 (or under 16 in the EEA). We do not knowingly collect data from children. If you believe a child has submitted data, contact us immediately.</p>
      </Section>
      <Section title="10. Changes to this policy">
        <p>We may update this policy. Material changes will be communicated via email or in-app notification. Continued use after changes constitutes acceptance of the updated policy.</p>
      </Section>
      <Section title="11. Contact">
        <p><a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a></p>
      </Section>
    </div>
  );
}

function PrivacyEs() {
  return (
    <div style={{ lineHeight: 1.75, fontSize: 16, color: "#334155" }}>
      <Section title="1. Quiénes somos">
        <p>{APP_NAME} opera la aplicación móvil {APP_NAME} y el sitio web {WEBSITE}. Somos un desarrollador independiente. Para consultas de privacidad: <a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a>.</p>
      </Section>
      <Section title="2. Qué datos recopilamos">
        <p>Recopilamos solo lo necesario para brindar el servicio:</p>
        <ul style={{ paddingLeft: 24, display: "flex", flexDirection: "column", gap: 8 }}>
          <li><strong>Datos de cuenta:</strong> dirección de email al unirte a la lista de espera o crear una cuenta.</li>
          <li><strong>Entradas de voz y texto:</strong> las notas y grabaciones que enviás a la app. Se usan únicamente para generar tus tareas, recordatorios e ideas.</li>
          <li><strong>Datos de uso:</strong> analíticas anónimas y agregadas sobre el uso de la app. No te rastreamos entre apps o sitios web.</li>
          <li><strong>Datos del dispositivo:</strong> tipo de dispositivo, versión del SO y de la app — para debugging y compatibilidad.</li>
        </ul>
        <p>No recopilamos datos de pago (gestionados íntegramente por Apple), documentos de identidad, datos financieros, ni ubicación precisa.</p>
      </Section>
      <Section title="3. Cómo usamos tus datos">
        <ul style={{ paddingLeft: 24, display: "flex", flexDirection: "column", gap: 8 }}>
          <li>Para proveer y mejorar el servicio {APP_NAME}.</li>
          <li>Para procesar tus notas y devolverte output estructurado.</li>
          <li>Para enviarte actualizaciones del producto si optaste por recibirlas.</li>
          <li>Para diagnosticar errores y mejorar el rendimiento.</li>
        </ul>
        <p>No vendemos tus datos ni los usamos para publicidad.</p>
      </Section>
      <Section title="4. Procesamiento con IA">
        <p>Tus notas de voz y texto pueden ser procesadas por proveedores de IA de terceros (como OpenAI) para generar output estructurado. Estos proveedores tienen prohibido contractualmente usar tus datos para entrenar sus propios modelos. Solo enviamos los datos mínimos necesarios.</p>
      </Section>
      <Section title="5. Almacenamiento y seguridad">
        <p>Tus datos se almacenan en servidores cloud seguros con cifrado en tránsito (HTTPS/TLS) y en reposo. El acceso está restringido a personal autorizado. Tomamos medidas razonables para proteger tu información.</p>
      </Section>
      <Section title="6. Retención de datos">
        <p>Conservamos tus datos mientras tu cuenta esté activa. Podés solicitar la eliminación en cualquier momento escribiendo a <a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a>. Procesamos solicitudes de eliminación en un plazo de 30 días.</p>
      </Section>
      <Section title="7. Tus derechos">
        <p>Tenés derecho a: acceder a tus datos, corregir datos inexactos, solicitar la eliminación, oponerte al procesamiento, portabilidad de datos y retirar el consentimiento en cualquier momento. Escribinos para ejercer cualquiera de estos derechos.</p>
      </Section>
      <Section title="8. Servicios de terceros">
        <ul style={{ paddingLeft: 24, display: "flex", flexDirection: "column", gap: 8 }}>
          <li><strong>Proveedores de IA:</strong> para procesar voz y texto.</li>
          <li><strong>Infraestructura cloud:</strong> para almacenar y servir tus datos de forma segura.</li>
          <li><strong>Analíticas:</strong> datos de uso anónimos y agregados únicamente.</li>
          <li><strong>Apple App Store:</strong> gestiona todas las compras. La política de privacidad de Apple rige los datos de pago.</li>
        </ul>
        <p>No usamos redes publicitarias ni vendemos datos.</p>
      </Section>
      <Section title="9. Privacidad de menores">
        <p>{APP_NAME} no está dirigida a menores de 13 años. No recopilamos datos de menores conscientemente. Contactanos de inmediato si creés que un menor nos proporcionó datos.</p>
      </Section>
      <Section title="10. Cambios a esta política">
        <p>Podemos actualizar esta política. Te notificaremos cambios materiales por email o en la app. El uso continuado implica aceptación de la política actualizada.</p>
      </Section>
      <Section title="11. Contacto">
        <p><a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a></p>
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
      <body style={{ background: "#F7F9FC", margin: 0 }}>
        <main style={{ maxWidth: 720, margin: "0 auto", padding: "80px 5% 120px", fontFamily: "'Plus Jakarta Sans', sans-serif", color: "#121E49" }}>
          <a href={`/${locale}`} style={{ display: "inline-flex", alignItems: "center", gap: 6, fontSize: 14, color: "#64748B", textDecoration: "none", marginBottom: 48, fontWeight: 500 }}>
            ← {isEs ? "Volver" : "Back"}
          </a>
          <p style={{ fontSize: 12, fontWeight: 700, letterSpacing: "0.1em", textTransform: "uppercase", color: "#4286E6", marginBottom: 12 }}>
            {isEs ? "Política de Privacidad" : "Privacy Policy"}
          </p>
          <h1 style={{ fontFamily: "'Nunito Sans', sans-serif", fontSize: 40, fontWeight: 900, letterSpacing: "-1.5px", marginBottom: 12, lineHeight: 1.1 }}>
            {isEs ? "Tu privacidad, en serio." : "Your privacy, seriously."}
          </h1>
          <p style={{ fontSize: 14, color: "#64748B", marginBottom: 56 }}>
            {isEs ? `Última actualización: ${EFFECTIVE_DATE}` : `Last updated: ${EFFECTIVE_DATE}`}
          </p>
          {isEs ? <PrivacyEs /> : <PrivacyEn />}
          <div style={{ marginTop: 64, padding: "24px 28px", background: "#FFF7ED", border: "1px solid #FED7AA", borderRadius: 16, fontSize: 13, color: "#92400E", lineHeight: 1.6 }}>
            <strong>{isEs ? "Nota:" : "Note:"}</strong> {isEs
              ? "Este documento es un template estándar. Para una app con usuarios a escala, consultá con un abogado especializado en privacidad."
              : "This document is a standard template. For an app with users at scale, consult a privacy lawyer before launch."}
          </div>
        </main>
      </body>
    </html>
  );
}
