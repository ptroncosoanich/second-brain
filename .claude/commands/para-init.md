---
description: Escanea actividad reciente (Calendar, Gmail, Drive, Chat) y propone la estructura inicial de proyectos y áreas
argument-hint: [días hacia atrás — opcional, default 14]
category: bootstrap
---

# /para-init — Bootstrap del brain

Tu rol: detectar los proyectos y áreas activos del usuario desde su actividad reciente y proponer una estructura inicial en `1-proyectos/` y `2-areas/`.

> **Antes de empezar**, lee `perfil.md`: nombre y email del usuario (§1), su equipo y área de rituales (§2), fuentes activas (§3), zona horaria (§4) y portafolio actual (§6). Si el perfil tiene `COMPLETAR`, sugerir `/configurar` primero.

## Cuándo usar

- **Primera vez**, con `1-proyectos/` vacío.
- Cuando el usuario pida "re-evaluar mis proyectos" o "actualizar el portafolio". En ese caso, proponer solo lo que no existe y sugerir archivar lo que ya no tiene actividad.

## Proceso

### Paso 1: Recolectar señales

Ventana: `$ARGUMENTS` días hacia atrás (default 14). Ejecutar en paralelo, saltando las fuentes inactivas:

1. **Calendario**: eventos con otros asistentes, agrupando por título recurrente.
   ```bash
   gws calendar events list --params '{"calendarId":"primary","timeMin":"<desde-ISO>","timeMax":"<hoy-ISO>","singleEvents":true,"orderBy":"startTime","maxResults":250}'
   ```
2. **Gmail**: hilos con respuestas (sin promociones ni notificaciones).
   ```bash
   gws gmail messages list --params '{"q":"in:inbox newer_than:<N>d -category:promotions -category:updates","maxResults":100}'
   ```
3. **Drive**: archivos modificados por el usuario.
   ```bash
   gws drive files list --params '{"q":"modifiedTime > '\''<desde-ISO>'\'' and '\''me'\'' in owners and trashed=false","orderBy":"modifiedTime desc","pageSize":100}'
   ```
4. **Chat**: spaces con actividad reciente (`lastActiveTime` dentro de la ventana; paginar con `nextPageToken`).
   ```bash
   gws chat spaces list --params '{"pageSize":100}'
   ```

Parsear la salida de `gws` desde la primera llave (`out[out.find('{'):]`): la línea `Using keyring backend` va a stderr.

### Paso 2: Sintetizar candidatos

Agrupar las señales por **proyecto candidato**. Un candidato necesita:
- asistentes recurrentes en Calendar, o un hilo de correo activo, o varios docs editados de un mismo tema, o un space de Chat activo;
- un objetivo o entregable identificable (un 1:1 recurrente no es proyecto: es área).

Para cada uno, inferir: **slug** (kebab-case sin acentos), **título**, **descripción** de 1 línea, **stakeholders** (de asistentes y remitentes), **señales** (2-5 evidencias con link) y **confianza** (alta/media/baja).

### Paso 3: Distinguir proyecto vs área

- **Proyecto** (`1-proyectos/`): tiene deadline implícito o entregable. Ej.: "Lanzamiento de la feature X", "Hiring de PM", "Migración a Y".
- **Área** (`2-areas/`): responsabilidad continua. Ej.: el producto o módulo del que el usuario es dueño, coaching de su equipo, una relación con otro equipo.

Áreas que ya existen y no se proponen de nuevo: `1-a-1s` (los 1:1 recurrentes van ahí, una carpeta por persona) y el área de rituales de `perfil.md` §2. Si la actividad cae en ellas, agregar contexto a sus carpetas.

### Paso 4: Presentar la propuesta y pedir confirmación

Antes de crear cualquier archivo:

```
Detecté los siguientes candidatos:

Proyectos
1. [alta] <slug> — <título>
   <descripción 1 línea>
   Stakeholders: <lista>
   Señales: <2-3 evidencias>

Áreas
2. [media] <slug> — <título>
   ...

1:1 recurrentes (→ 2-areas/1-a-1s/<persona>/)
- <persona> — <N> reuniones

¿Confirmo? Puedes decir:
- "sí todos"
- "sí 1, 3, 5"
- "agrega <slug> con <descripción>"
- "descarta 2" / "2 es área, no proyecto"
```

### Paso 5: Crear la estructura

Para cada proyecto o área confirmado:

```
<1-proyectos|2-areas>/<slug>/
├── AGENTS.md          # desde 3-recursos/plantillas/proyecto.md o area.md, con los datos del Paso 2
├── reuniones/
├── decisiones/
├── chat/
├── refs/README.md     # links iniciales detectados (todas las señales, aunque parezcan duplicadas)
├── pendientes.md      # "# Pendientes"
└── conflictos.md      # "# Conflictos"
```

Git no guarda carpetas vacías: crear un `.gitkeep` en `reuniones/`, `decisiones/` y `chat/`.

Para cada 1:1 confirmado: `2-areas/1-a-1s/<persona>/contexto.md` con rol, relación y temas recurrentes detectados.

### Paso 6: Actualizar el portafolio

Reemplazar el placeholder de `perfil.md` §6 (o agregar al final de cada lista) con una línea por proyecto o área creado: `- [<slug>](<ruta>/) — <descripción 1 línea>`.

### Paso 7: Reportar

```
Bootstrap completo:
- N proyectos en 1-proyectos/
- M áreas en 2-areas/
- K personas en 2-areas/1-a-1s/
- Portafolio de perfil.md actualizado

Siguiente:
- /mapear-chat-spaces para que /cierre-dia enrute tu Chat.
- Completa las secciones "## Jira" y "## GitHub" de cada AGENTS.md si usas esas fuentes.
- /cierre-dia al final del día.
```

## Reglas

- **NUNCA** crear archivos sin la confirmación del Paso 4.
- Si una señal es ambigua entre dos proyectos, confianza media y que decida el usuario.
- Si menos de 2 señales soportan un candidato, no proponerlo: sugerir agregarlo a mano.
- Conservar todos los links originales en `refs/README.md`: son evidencia.
- Privacidad: los títulos de reuniones y spaces sensibles (evaluaciones, compensaciones) se proponen sin detalle si `perfil.md` §5 dice `metadata`.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
