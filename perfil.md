# Perfil

> **Archivo personal.** Todas las skills lo leen antes de trabajar: dice quién eres, cómo está tu equipo, qué fuentes usas, los parámetros de las rutinas y tu portafolio. Los valores compartidos por la organización van en `organizacion.md`.
>
> Lo llena `/configurar` (en Codex, `$configurar`), pero puedes editarlo a mano cuando quieras.
> Mientras quede algún `COMPLETAR` en este archivo, el brain se considera **no configurado** y el agente te ofrecerá correr `/configurar`.

## 1. Quién soy

- **Nombre**: COMPLETAR (ej. Ana Pérez)
- **Cómo me nombran**: COMPLETAR (nombres, apodos y usuario de correo con que apareces en reuniones y chats, ej. `Ana, Anita, aperez`; sirve para atribuirte compromisos)
- **Email de trabajo**: COMPLETAR (ej. `aperez@buk.cl`)
- **Rol**: COMPLETAR (ej. Product Manager — equipo Vacaciones)
- **Manager**: COMPLETAR (nombre y rol)
- **ID de usuario en Google Chat**: *(lo detecta `/configurar` o la primera corrida de `/cierre-dia`; formato `users/<número>`)*

## 2. Mi equipo

### Reportes directos

> Sus compromisos de nivel PM/PBD (discovery, documentos, definiciones) se trackean como delegación en `pendientes.md`. Deja la tabla vacía si no tienes reportes.

| Persona | Rol | Cómo la nombran |
|---|---|---|

### Pares cercanos

> Trabajan contigo pero no dependen de ti: sus compromisos **no** se trackean como delegación ni se les asignan tareas, se acuerdan.

| Persona | Rol |
|---|---|

### Rituales del equipo

- **Área de rituales**: COMPLETAR (carpeta de `2-areas/` donde van dailies, retros y sprint reviews, ej. `2-areas/equipo-vacaciones`)
- **Reuniones que nunca bloquean mi agenda**: *(opcional — ej. dailies a las que casi no vas; las usa `/planificar-semana`)*

## 3. Fuentes y herramientas

| Fuente | Estado | Herramienta | La usan |
|---|---|---|---|
| Google Calendar, Drive y Gmail | activa | `gws` | `/cierre-dia`, `/para-init`, `/planificar-semana` |
| Google Chat | activa | `gws` | `/cierre-dia`, `/mapear-chat-spaces` |
| Buk Atlas | activa | `gws` | `/atlas`, `/donde-esta`, `/cierre-dia` |
| Jira | activa | `acli` | `/jira-mios`, `/jira-ticket`, `/cierre-dia` |
| GitHub | activa | `gh` | `/mis-prs`, `/pr`, `/cierre-dia` |
| BigQuery | activa | `bq` | `/datos`, `/amplitude` |

- **Estado**: `activa` o `inactiva`. Una skill cuya fuente está inactiva avisa en una línea y termina; `/cierre-dia` solo salta ese paso.
- **Herramienta**: las skills están escritas para estas CLIs. Si usas un conector MCP en su lugar (por ejemplo, Google Calendar de claude.ai), escribe `conector` y el agente usará la herramienta equivalente.
- `/configurar` revisa cada CLI y deja esta tabla al día.

## 4. Parámetros

Cámbialos si tu caso es distinto.

| Parámetro | Valor |
|---|---|
| Zona horaria | `America/Santiago` |
| Horario laboral | 09:00–18:00 |
| Rutina `/cierre-dia` | lunes a viernes, 19:00 |
| Bloques de foco por semana (`/planificar-semana`) | 4 |

Los valores de la organización (Jira, GitHub, BigQuery, Buk Atlas, spaces a ignorar y catálogo de datos) no están acá: viven en `organizacion.md`, que se comparte aparte (ver `organizacion.ejemplo.md`).

## 5. Privacidad

- **Quién tiene acceso a este repo**: COMPLETAR (`solo yo`, o la lista de personas)
- **Detalle en temas sensibles** (desempeño, feedback, compensación, contexto personal): COMPLETAR (`completo` si solo tú tienes acceso; `metadata` si alguien más puede leerlo)

Con cualquier nivel, nunca se guardan tokens ni contraseñas.

## 6. Portafolio activo

> Lo mantienen `/para-init` (al inicio) y `/cierre-dia` (cuando nace un proyecto o área). Una línea por carpeta, con link. Edítalo a mano si quieres.

### Proyectos (`1-proyectos/`)

*(vacío — corre `/para-init`)*

### Áreas (`2-areas/`)

- [1-a-1s](2-areas/1-a-1s/) — Reuniones 1:1 recurrentes con reportes, pares, manager y stakeholders.
