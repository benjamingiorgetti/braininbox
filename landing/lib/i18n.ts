export type Locale = "en" | "es";
export const defaultLocale: Locale = "en";
export const locales: Locale[] = ["en", "es"];

const dictionaries = {
  en: {
    announcementBar: "🧠 Brain Inbox is coming to the App Store",
    announcementSub: "· Limited beta access",

    nav: {
      features: "Features",
      app: "The App",
      how: "How it works",
      cta: "Join beta",
    },

    hero: {
      eyebrow: "Private beta · Limited spots",
      headline: "Turn your voice notes into tasks, ideas and a calendar.",
      sub: "Talk like you think. Brain Inbox listens, sorts what matters, and leaves everything organized — before you forget it.",
      inputPlaceholder: "your@email.com",
      cta: "Join the free beta",
      successMsg: "You're in. We'll reach out soon.",
      microcopy: "No credit card. Limited early access.",
    },

    demo: {
      eyebrow: "✦ See it in action",
      headline: "From messy thought to clear plan.",
      input: "\"I need to call Nico tomorrow, study calculus on Thursday and remember to buy mom's birthday gift.\"",
      inputLabel: "You say:",
      outputLabel: "Brain Inbox creates:",
      rows: [
        { result: "Call Nico tomorrow", type: "Task" },
        { result: "Study calculus — Thursday", type: "Calendar" },
        { result: "Buy mom's birthday gift", type: "Reminder" },
      ],
      mascotSay: "Done. Three things captured, zero forgotten.",
    },

    usecases: {
      eyebrow: "✦ Built for",
      headline: "People who think faster than they type.",
      items: [
        {
          emoji: "🎓",
          title: "Students who remember everything at 2 AM",
          body: "Capture what you need to study, do, or buy — without breaking your flow.",
        },
        {
          emoji: "⚡",
          title: "Founders thinking faster than they can write",
          body: "Drop ideas mid-run, in the shower, between meetings. Nothing gets lost.",
        },
        {
          emoji: "🎙️",
          title: "People who send voice memos to themselves",
          body: "Stop playing back 3-minute audios. Brain Inbox turns them into action.",
        },
        {
          emoji: "🧩",
          title: "Anyone juggling too many open loops",
          body: "Tasks, ideas, reminders — all in one place, automatically sorted.",
        },
      ],
    },

    anything: {
      eyebrow: "✦ Just say it",
      headline: "Tell it anything. It knows what to do.",
      cards: [
        { quote: "\"Pay the credit card by Friday.\"", result: "Reminder set", icon: "🔔" },
        { quote: "\"Idea: app to organize screenshots.\"", result: "Idea saved", icon: "💡" },
        { quote: "\"Call Fran tomorrow after class.\"", result: "Task with pending time", icon: "✅" },
        { quote: "\"Study for calculus exam Thursday.\"", result: "Calendar event suggested", icon: "📅" },
        { quote: "\"Remember to send the invoice.\"", result: "Reminder created", icon: "🔔" },
        { quote: "\"I want to read Atomic Habits.\"", result: "Idea saved", icon: "💡" },
      ],
    },

    features: {
      eyebrow: "✦ Features",
      headline: ["What Brain Inbox", "does for you."],
      phone: "/screenshots/home.png",
      items: [
        {
          title: "Talk, don't type",
          body: "Say it out loud — a task, an idea, a reminder. Brain Inbox picks out what matters and puts it where it belongs.",
        },
        {
          title: "Nothing slips through",
          body: "Every thought gets a home. Open loops become tasks. Vague ideas become notes. Dates become reminders.",
        },
        {
          title: "Your day, ready when you wake up",
          body: "Check your schedule in the morning and see everything laid out — no more piecing it together from five different places.",
        },
        {
          title: "Review when you're ready",
          body: "Things that need a decision wait in your inbox. No pressure, no noise.",
        },
      ],
    },

    waitlist: {
      headline: "Your voice note in. A plan out.",
      sub: "Brain Inbox is in private beta. Leave your email and we'll reach out when it's your turn.",
      inputPlaceholder: "your@email.com",
      cta: "Join the free beta",
      successMsg: "You're in. We'll reach out soon.",
      microcopy: "No credit card. Limited spots.",
      mascotSay: "I'll keep your spot warm. 🧠",
    },

    footer: {
      links: ["Privacy", "Terms", "Contact"],
      copy: "© 2026 Brain Inbox · thebraininbox.app",
    },
  },

  es: {
    announcementBar: "🧠 Brain Inbox llega pronto al App Store",
    announcementSub: "· Beta privada · Cupos limitados",

    nav: {
      features: "Funciones",
      app: "La App",
      how: "Cómo funciona",
      cta: "Unirme a la beta",
    },

    hero: {
      eyebrow: "Beta privada · Cupos limitados",
      headline: "Convertí tus notas de voz en tareas, ideas y calendario.",
      sub: "Hablá como pensás. Brain Inbox escucha, separa lo importante y te deja todo organizado antes de que se te olvide.",
      inputPlaceholder: "tu@email.com",
      cta: "Unirme a la beta gratis",
      successMsg: "Estás adentro. Te avisamos pronto.",
      microcopy: "Sin tarjeta. Acceso anticipado limitado.",
    },

    demo: {
      eyebrow: "✦ Cómo funciona",
      headline: "De pensamiento desordenado a plan claro.",
      input: "\"Tengo que llamar a Nico mañana, estudiar cálculo el jueves y acordarme de comprar el regalo de mamá.\"",
      inputLabel: "Vos decís:",
      outputLabel: "Brain Inbox crea:",
      rows: [
        { result: "Llamar a Nico mañana", type: "Tarea" },
        { result: "Estudiar cálculo — jueves", type: "Calendario" },
        { result: "Comprar regalo de mamá", type: "Recordatorio" },
      ],
      mascotSay: "Listo. Tres cosas capturadas, ninguna olvidada.",
    },

    usecases: {
      eyebrow: "✦ Para quién es",
      headline: "Gente que piensa más rápido de lo que escribe.",
      items: [
        {
          emoji: "🎓",
          title: "Estudiantes que se acuerdan de todo a las 2 AM",
          body: "Capturá lo que tenés que estudiar, hacer o comprar — sin cortar el hilo.",
        },
        {
          emoji: "⚡",
          title: "Founders que piensan más rápido de lo que escriben",
          body: "Volcá ideas mientras corrés, en la ducha, entre reuniones. Nada se pierde.",
        },
        {
          emoji: "🎙️",
          title: "Gente que se manda audios a sí misma",
          body: "Dejá de escuchar audios de 3 minutos. Brain Inbox los convierte en acción.",
        },
        {
          emoji: "🧩",
          title: "Cualquiera con demasiados loops abiertos",
          body: "Tareas, ideas, recordatorios — todo en un lugar, ordenado automáticamente.",
        },
      ],
    },

    anything: {
      eyebrow: "✦ Decile cualquier cosa",
      headline: "Decile cualquier cosa. Sabe qué hacer.",
      cards: [
        { quote: "\"Tengo que pagar la tarjeta el viernes.\"", result: "Recordatorio creado", icon: "🔔" },
        { quote: "\"Idea: app para organizar screenshots.\"", result: "Idea guardada", icon: "💡" },
        { quote: "\"Mañana llamar a Fran después de clase.\"", result: "Tarea con horario pendiente", icon: "✅" },
        { quote: "\"El jueves estudiar parcial de cálculo.\"", result: "Evento sugerido en agenda", icon: "📅" },
        { quote: "\"Acordarme de mandar la factura.\"", result: "Recordatorio creado", icon: "🔔" },
        { quote: "\"Quiero leer Atomic Habits.\"", result: "Idea guardada", icon: "💡" },
      ],
    },

    features: {
      eyebrow: "✦ Funciones",
      headline: ["Lo que Brain Inbox", "hace por vos."],
      phone: "/screenshots/home.png",
      items: [
        {
          title: "Hablá, no escribas",
          body: "Decilo en voz alta — una tarea, una idea, un recordatorio. Brain Inbox saca lo que importa y lo pone donde corresponde.",
        },
        {
          title: "Nada se pierde",
          body: "Cada pensamiento tiene un lugar. Los loops abiertos se vuelven tareas. Las ideas vagas, notas. Las fechas, recordatorios.",
        },
        {
          title: "Tu día, listo cuando te levantás",
          body: "Mirá tu agenda a la mañana y encontrá todo ordenado — sin tener que armar el rompecabezas de cinco lugares distintos.",
        },
        {
          title: "Decidí cuando estés listo",
          body: "Las cosas que necesitan una decisión esperan en tu inbox. Sin presión, sin ruido.",
        },
      ],
    },

    waitlist: {
      headline: "Tu nota de voz entra. Un plan sale.",
      sub: "Brain Inbox está en beta privada. Dejá tu email y te avisamos cuando sea tu turno.",
      inputPlaceholder: "tu@email.com",
      cta: "Unirme a la beta gratis",
      successMsg: "Estás adentro. Te avisamos pronto.",
      microcopy: "Sin tarjeta. Cupos limitados.",
      mascotSay: "Te guardo el lugar. 🧠",
    },

    footer: {
      links: ["Privacidad", "Términos", "Contacto"],
      copy: "© 2026 Brain Inbox · thebraininbox.app",
    },
  },
} as const;

export type Dictionary = (typeof dictionaries)["en"];
export function getDictionary(locale: Locale): Dictionary {
  return dictionaries[locale] as Dictionary;
}
