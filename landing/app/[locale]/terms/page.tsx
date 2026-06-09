import type { Metadata } from "next";
import { type Locale, locales } from "@/lib/i18n";
import { notFound } from "next/navigation";

export const metadata: Metadata = {
  title: "Terms of Service – Brain Inbox",
};

export async function generateStaticParams() {
  return locales.map((locale) => ({ locale }));
}

const EFFECTIVE_DATE = "June 8, 2026";
const CONTACT_EMAIL = "legal@thebraininbox.app";
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

function TermsEn() {
  return (
    <div style={{ lineHeight: 1.75, fontSize: 16, color: "#334155" }}>
      <Section title="1. Acceptance of terms">
        <p>By downloading, installing, or using {APP_NAME} (the &ldquo;App&rdquo;) or visiting {WEBSITE} (the &ldquo;Site&rdquo;), you agree to be bound by these Terms of Service. If you do not agree, do not use the App or Site.</p>
      </Section>
      <Section title="2. Description of service">
        <p>{APP_NAME} is a productivity application that captures voice notes and text input and uses artificial intelligence to organize them into tasks, reminders, and ideas. The service is provided &ldquo;as is&rdquo; and features may change over time.</p>
      </Section>
      <Section title="3. Eligibility">
        <p>You must be at least 13 years old to use {APP_NAME}. By using the App, you represent that you meet this age requirement. If you are under 18, you represent that you have parental or guardian consent.</p>
      </Section>
      <Section title="4. User account">
        <p>You are responsible for maintaining the confidentiality of your account credentials and for all activity that occurs under your account. Notify us immediately of any unauthorized access. We reserve the right to suspend or terminate accounts that violate these Terms.</p>
      </Section>
      <Section title="5. Acceptable use">
        <p>You agree not to:</p>
        <ul style={{ paddingLeft: 24, display: "flex", flexDirection: "column", gap: 8 }}>
          <li>Use the App for any unlawful purpose or in violation of any applicable laws.</li>
          <li>Submit content that is illegal, harmful, abusive, defamatory, or violates third-party rights.</li>
          <li>Attempt to reverse-engineer, decompile, or extract the source code of the App.</li>
          <li>Interfere with or disrupt the App&apos;s infrastructure or security.</li>
          <li>Use automated means (bots, scrapers) to access the service without prior written consent.</li>
          <li>Resell or redistribute the App or its features without authorization.</li>
        </ul>
      </Section>
      <Section title="6. Your content">
        <p>You retain ownership of the content you submit to {APP_NAME} (voice notes, text, ideas). By submitting content, you grant us a limited, non-exclusive license to process that content solely to provide and improve the service. We do not claim ownership of your content.</p>
        <p>You are responsible for ensuring that your content does not violate any third-party rights or applicable laws.</p>
      </Section>
      <Section title="7. AI-generated output">
        <p>{APP_NAME} uses AI to process your input and generate structured output (tasks, reminders, ideas). AI-generated output may contain errors or inaccuracies. You are solely responsible for reviewing and acting on any AI-generated content. {APP_NAME} does not guarantee the accuracy, completeness, or fitness for purpose of any AI-generated output.</p>
      </Section>
      <Section title="8. Subscriptions and payments">
        <p>Paid features of {APP_NAME} are offered through Apple&apos;s in-app purchase system. All billing, refunds, and subscription management are governed by Apple&apos;s terms and policies. We do not process payment information directly.</p>
        <p>Free trials, if offered, convert to paid subscriptions at the end of the trial period unless cancelled before renewal through the App Store settings.</p>
      </Section>
      <Section title="9. Intellectual property">
        <p>All intellectual property in the {APP_NAME} application, including but not limited to the software, design, graphics, mascot, name, and logo, is owned by or licensed to us. You may not use our brand assets without prior written permission.</p>
      </Section>
      <Section title="10. Disclaimer of warranties">
        <p>THE APP IS PROVIDED &ldquo;AS IS&rdquo; AND &ldquo;AS AVAILABLE&rdquo; WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED. WE DO NOT WARRANT THAT THE APP WILL BE UNINTERRUPTED, ERROR-FREE, OR FREE OF HARMFUL COMPONENTS. YOUR USE OF THE APP IS AT YOUR SOLE RISK.</p>
      </Section>
      <Section title="11. Limitation of liability">
        <p>TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, {APP_NAME.toUpperCase()} AND ITS DEVELOPERS SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING LOSS OF DATA, PROFITS, OR BUSINESS, ARISING FROM YOUR USE OF OR INABILITY TO USE THE APP, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.</p>
        <p>Our total liability to you for any claims arising under these Terms shall not exceed the amount you paid us in the 12 months preceding the claim, or USD $10, whichever is greater.</p>
      </Section>
      <Section title="12. Indemnification">
        <p>You agree to indemnify and hold harmless {APP_NAME} and its developers from any claims, damages, or expenses (including legal fees) arising from your use of the App, your content, or your violation of these Terms.</p>
      </Section>
      <Section title="13. Termination">
        <p>We may suspend or terminate your access to the App at any time, with or without cause, with reasonable notice. You may stop using the App at any time. Upon termination, your right to use the App ceases immediately. Sections that by their nature should survive termination will survive.</p>
      </Section>
      <Section title="14. Governing law">
        <p>These Terms are governed by the laws of Argentina, without regard to conflict of law provisions. Any disputes shall be resolved through good-faith negotiation. If unresolved, disputes shall be submitted to the courts of Buenos Aires, Argentina.</p>
      </Section>
      <Section title="15. Changes to these terms">
        <p>We may update these Terms from time to time. Material changes will be communicated via email or in-app notification at least 7 days before taking effect. Continued use of the App after changes constitutes acceptance of the updated Terms.</p>
      </Section>
      <Section title="16. Contact">
        <p>Questions about these Terms: <a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a></p>
      </Section>
    </div>
  );
}

function TermsEs() {
  return (
    <div style={{ lineHeight: 1.75, fontSize: 16, color: "#334155" }}>
      <Section title="1. Aceptación de los términos">
        <p>Al descargar, instalar o usar {APP_NAME} (la &ldquo;App&rdquo;) o visitar {WEBSITE} (el &ldquo;Sitio&rdquo;), aceptás quedar vinculado por estos Términos de Servicio. Si no estás de acuerdo, no uses la App ni el Sitio.</p>
      </Section>
      <Section title="2. Descripción del servicio">
        <p>{APP_NAME} es una aplicación de productividad que captura notas de voz y texto y usa inteligencia artificial para organizarlos en tareas, recordatorios e ideas. El servicio se brinda &ldquo;tal cual&rdquo; y las funciones pueden cambiar con el tiempo.</p>
      </Section>
      <Section title="3. Elegibilidad">
        <p>Debés tener al menos 13 años para usar {APP_NAME}. Al usar la App, declarás cumplir con este requisito. Si sos menor de 18 años, declarás contar con el consentimiento de tus padres o tutores.</p>
      </Section>
      <Section title="4. Cuenta de usuario">
        <p>Sos responsable de mantener la confidencialidad de tus credenciales de cuenta y de toda la actividad que ocurra bajo tu cuenta. Notificanos de inmediato ante cualquier acceso no autorizado. Nos reservamos el derecho de suspender o eliminar cuentas que violen estos Términos.</p>
      </Section>
      <Section title="5. Uso aceptable">
        <p>Aceptás no:</p>
        <ul style={{ paddingLeft: 24, display: "flex", flexDirection: "column", gap: 8 }}>
          <li>Usar la App para fines ilegales o en violación de leyes aplicables.</li>
          <li>Enviar contenido ilegal, dañino, abusivo, difamatorio o que viole derechos de terceros.</li>
          <li>Intentar realizar ingeniería inversa, descompilar o extraer el código fuente de la App.</li>
          <li>Interferir o interrumpir la infraestructura o seguridad de la App.</li>
          <li>Usar medios automatizados (bots, scrapers) para acceder al servicio sin consentimiento previo por escrito.</li>
          <li>Revender o redistribuir la App o sus funciones sin autorización.</li>
        </ul>
      </Section>
      <Section title="6. Tu contenido">
        <p>Conservás la propiedad del contenido que enviás a {APP_NAME} (notas de voz, texto, ideas). Al enviar contenido, nos otorgás una licencia limitada y no exclusiva para procesarlo únicamente con el fin de brindar y mejorar el servicio. No reclamamos propiedad sobre tu contenido.</p>
        <p>Sos responsable de asegurarte de que tu contenido no viole derechos de terceros ni leyes aplicables.</p>
      </Section>
      <Section title="7. Output generado por IA">
        <p>{APP_NAME} usa IA para procesar tus entradas y generar output estructurado. El output generado por IA puede contener errores o imprecisiones. Sos el único responsable de revisar y actuar sobre cualquier contenido generado por IA. {APP_NAME} no garantiza la exactitud, completitud ni idoneidad del output generado por IA.</p>
      </Section>
      <Section title="8. Suscripciones y pagos">
        <p>Las funciones pagas de {APP_NAME} se ofrecen a través del sistema de compras in-app de Apple. Toda facturación, reembolsos y gestión de suscripciones se rigen por los términos y políticas de Apple. No procesamos información de pago directamente.</p>
        <p>Las pruebas gratuitas, si se ofrecen, se convierten en suscripciones pagas al finalizar el período de prueba, salvo que se cancelen antes de la renovación desde la configuración del App Store.</p>
      </Section>
      <Section title="9. Propiedad intelectual">
        <p>Toda la propiedad intelectual de la aplicación {APP_NAME}, incluyendo el software, diseño, gráficos, mascota, nombre y logo, es de nuestra propiedad o está licenciada a nosotros. No podés usar nuestros activos de marca sin autorización previa por escrito.</p>
      </Section>
      <Section title="10. Exclusión de garantías">
        <p>LA APP SE BRINDA &ldquo;TAL CUAL&rdquo; Y &ldquo;SEGÚN DISPONIBILIDAD&rdquo; SIN GARANTÍAS DE NINGÚN TIPO, EXPRESAS O IMPLÍCITAS. NO GARANTIZAMOS QUE LA APP SEA ININTERRUMPIDA, LIBRE DE ERRORES O DE COMPONENTES DAÑINOS. EL USO DE LA APP ES DE TU EXCLUSIVA RESPONSABILIDAD.</p>
      </Section>
      <Section title="11. Limitación de responsabilidad">
        <p>EN LA MÁXIMA MEDIDA PERMITIDA POR LA LEY APLICABLE, {APP_NAME.toUpperCase()} Y SUS DESARROLLADORES NO SERÁN RESPONSABLES POR DAÑOS INDIRECTOS, INCIDENTALES, ESPECIALES, CONSECUENTES O PUNITIVOS, INCLUYENDO PÉRDIDA DE DATOS, GANANCIAS O NEGOCIOS, DERIVADOS DE TU USO O IMPOSIBILIDAD DE USO DE LA APP.</p>
        <p>Nuestra responsabilidad total ante vos no excederá el monto que nos pagaste en los 12 meses anteriores al reclamo, o USD $10, lo que sea mayor.</p>
      </Section>
      <Section title="12. Indemnización">
        <p>Aceptás indemnizar y mantener indemne a {APP_NAME} y sus desarrolladores frente a cualquier reclamo, daño o gasto (incluidos honorarios legales) que surja de tu uso de la App, tu contenido o tu violación de estos Términos.</p>
      </Section>
      <Section title="13. Cancelación">
        <p>Podemos suspender o cancelar tu acceso a la App en cualquier momento, con o sin causa, con aviso razonable. Podés dejar de usar la App en cualquier momento. Las secciones que por su naturaleza deban sobrevivir a la cancelación, sobrevivirán.</p>
      </Section>
      <Section title="14. Ley aplicable">
        <p>Estos Términos se rigen por las leyes de la República Argentina. Cualquier disputa se resolverá mediante negociación de buena fe. De no resolverse, las disputas se someterán a los tribunales ordinarios de la Ciudad Autónoma de Buenos Aires.</p>
      </Section>
      <Section title="15. Cambios a estos términos">
        <p>Podemos actualizar estos Términos. Te notificaremos cambios materiales por email o en la app con al menos 7 días de anticipación. El uso continuado de la App implica aceptación de los Términos actualizados.</p>
      </Section>
      <Section title="16. Contacto">
        <p><a href={`mailto:${CONTACT_EMAIL}`} style={{ color: "#4286E6" }}>{CONTACT_EMAIL}</a></p>
      </Section>
    </div>
  );
}

export default async function TermsPage({
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
            {isEs ? "Términos de Servicio" : "Terms of Service"}
          </p>
          <h1 style={{ fontFamily: "'Nunito Sans', sans-serif", fontSize: 40, fontWeight: 900, letterSpacing: "-1.5px", marginBottom: 12, lineHeight: 1.1 }}>
            {isEs ? "Reglas del juego." : "The rules of the game."}
          </h1>
          <p style={{ fontSize: 14, color: "#64748B", marginBottom: 56 }}>
            {isEs ? `Última actualización: ${EFFECTIVE_DATE}` : `Last updated: ${EFFECTIVE_DATE}`}
          </p>
          {isEs ? <TermsEs /> : <TermsEn />}
          <div style={{ marginTop: 64, padding: "24px 28px", background: "#FFF7ED", border: "1px solid #FED7AA", borderRadius: 16, fontSize: 13, color: "#92400E", lineHeight: 1.6 }}>
            <strong>{isEs ? "Nota:" : "Note:"}</strong> {isEs
              ? "Este documento es un template estándar. Para una app con usuarios a escala o con operación en múltiples jurisdicciones, consultá con un abogado antes de lanzar."
              : "This is a standard template. For an app operating at scale or across multiple jurisdictions, consult a lawyer before launch."}
          </div>
        </main>
      </body>
    </html>
  );
}
