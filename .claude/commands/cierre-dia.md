---
description: Procesa reuniones y Google Chat del día y enriquece el brain — enruta cada fuente al proyecto correcto, extrae decisiones, pendientes y conflictos
argument-hint: [YYYY-MM-DD | varias fechas | rango — opcional, default hoy]
category: routine
---

# /cierre-dia — Procesar el día y enriquecer el brain

Tu rol: al final del día, leer todas las reuniones del usuario y la actividad de sus spaces de Google Chat, enrutar cada fuente al proyecto de `1-proyectos/` o área de `2-areas/` que corresponda, y extraer decisiones, pendientes y conflictos a sus archivos.

**Es la rutina principal del brain.** Está pensada para correr sola de lunes a viernes (ver `.claude/routines/README.md`) y también se puede invocar a mano.

> **Antes de empezar**, lee `perfil.md`. De ahí salen: el nombre y los alias del usuario (§1), sus reportes directos y pares (§2), el área de rituales (§2), las fuentes activas (§3), la zona horaria (§4) y el nivel de detalle en temas sensibles (§5). Lee también `organizacion.md`: URL de Jira (`<JIRA>`), organización de GitHub (`<org>`), ID de Buk Atlas y spaces de Chat a ignorar. Si alguna fuente está `inactiva`, salta los pasos que la usan sin reportarlo como error.

## Input

`$ARGUMENTS` opcionalmente trae una fecha ISO `YYYY-MM-DD`. Si viene vacío, usar hoy en la zona horaria de `perfil.md`.

**Si el usuario da un día de la semana** ("el viernes", "ayer", "el lunes") en vez de una fecha ISO: calcular la fecha y **verificar el día de la semana antes de procesar** — macOS `date -j -f "%Y-%m-%d" "<fecha>" "+%A"`, Linux `date -d "<fecha>" +%A`. No asumir.

`$ARGUMENTS` puede traer **más de un día** ("cierra el miércoles 2 y el jueves 3", "cierra la semana pasada", "2026-09-02 2026-09-03"). En ese caso aplica el Paso 0, que es obligatorio.

**Offset horario**: la zona horaria puede cambiar de offset en el año (horario de verano). Calcularlo para cada fecha, no asumirlo: macOS `TZ=<zona> date -j -f "%Y-%m-%d %H:%M" "<fecha> 12:00" "+%z"`, Linux `TZ=<zona> date -d "<fecha> 12:00" +%z`. En los comandos de abajo, `<offset>` va con formato `-03:00`.

## Proceso

### Paso 0: Si hay más de un día, paralelizar con subagentes (OBLIGATORIO)

**Regla dura**: si el input resuelve a **2 o más fechas**, NO las proceses en serie. Levanta **un subagente por día**, todos en un mismo mensaje para que corran en paralelo. Los días son independientes salvo en los archivos compartidos, y esos los resuelve el orquestador al final.

Antes de lanzarlos, valida cada fecha (una sola llamada con todas) y descarta sábados y domingos salvo que el usuario los haya pedido.

#### Qué hace cada subagente (Fase A — en paralelo)

Cada subagente recibe **una** fecha y ejecuta los Pasos 1 a 4, 6.1 a 6.4 y 7 para su día. Prompt base:

> Ejecuta el cierre del día `<FECHA>` siguiendo `.claude/commands/cierre-dia.md`, con estas restricciones:
> - **Escribe directamente** solo archivos con fecha en el nombre, que no pueden chocar: `<destino>/reuniones/<FECHA>-*.md`, `<destino>/decisiones/<FECHA>-*.md`, `<destino>/chat/<FECHA>-*.md`.
> - **NO toques** archivos compartidos: `pendientes.md`, `conflictos.md`, `refs/*.md`, ningún `AGENTS.md`, `perfil.md`, `3-recursos/`. Tampoco crees proyectos nuevos.
> - Devuelve en tu reporte final, en bloques separados y con el destino exacto de cada ítem: (a) pendientes candidatos ya filtrados con el criterio de la skill, con responsable y link a la fuente; (b) candidatos a cierre del Paso 5.5 con su cita textual; (c) conflictos; (d) referencias Jira/GitHub/Atlas; (e) reuniones sin fuente utilizable o sin routing claro; (f) proyectos nuevos que habría que crear, con contexto para su `AGENTS.md`.

#### Qué hace el orquestador (Fase B — en serie, después)

Con los reportes de todos los agentes, y **solo entonces**:

1. Ejecutar el **Paso 5.5** (cierre de pendientes) sobre el estado real de cada `pendientes.md`, con la evidencia de **todos** los días a la vez: un pendiente puede nacer el día 1 y cerrarse el día 2, y ningún agente por separado ve esa secuencia.
2. Aplicar los pendientes nuevos, deduplicando **entre días** además de contra lo existente.
3. Escribir conflictos y `refs/*.md`, crear proyectos nuevos (con confirmación) y actualizar el portafolio de `perfil.md`.
4. Emitir un único reporte del Paso 8 para todos los días.

**Por qué**: los archivos por fecha nunca chocan, así que paralelizarlos es gratis. Los compartidos sí chocan — dos agentes escribiendo `pendientes.md` a la vez se pisan — y la deduplicación necesita ver todos los días juntos.

Para un solo día, no levantes subagentes.

### Paso 1: Listar reuniones del día

```bash
gws calendar events list --params '{"calendarId":"primary","timeMin":"<fecha>T00:00:00<offset>","timeMax":"<fecha>T23:59:59<offset>","singleEvents":true,"orderBy":"startTime"}'
```

Filtrar:
- Solo eventos con más de un asistente (fuera focus time y recordatorios personales).
- Excluir los que el usuario rechazó (`responseStatus: declined` en el asistente con `"self": true`).
- Incluir todos los recurrentes que ocurrieron ese día.

### Paso 2: Para cada reunión, recolectar artefactos

**Fuentes de notas o transcripciones**, en orden de preferencia:

1. **`attachments` del evento** (primera opción, costo cero). La llamada del Paso 1 ya devolvió los `fileId` de "Notas de Gemini", "Notes by Gemini", "Notes - <reunión>", grabaciones y chat de la sesión. No busques en Drive si el evento trae adjuntos: es una llamada más por reunión y puede traer el doc equivocado.
   - **Exporta todos los docs del rango en un lote**, desde el scratchpad o un directorio temporal (nunca desde la raíz del brain):
     ```bash
     cd <directorio-temporal>
     for id in <ID1> <ID2> ...; do
       rm -f download.txt
       gws drive files export --params "{\"fileId\":\"$id\",\"mimeType\":\"text/plain\"}" >/dev/null 2>&1 </dev/null
       mv download.txt "d-$id.txt"
     done
     ```
     (el `mv` es obligatorio: `gws drive files export` ignora `-o` y siempre escribe `download.txt` en el directorio actual)
   - Los adjuntos que son Sheets no se exportan como `text/plain`: usar `text/csv` si hace falta su contenido.
2. **Búsqueda en Drive** — solo si el evento no trae adjuntos:
   ```bash
   gws drive files list --params '{"q":"name contains \"<palabra-clave-del-titulo>\" and modifiedTime > \"<fecha>T00:00:00Z\" and trashed=false and (mimeType=\"application/vnd.google-apps.document\" or mimeType=\"text/plain\")","orderBy":"modifiedTime desc","pageSize":10}'
   ```
3. **Notas propias en Drive**: docs modificados durante o justo después de la reunión. Se pueden usar, marcando `**Fuente**: notas manuales`.

Si no hay ninguna fuente, registrar metadata mínima (título, hora, asistentes) sin contenido. No saltar la reunión. Si el export de unas notas de Gemini da `404`, es un evento corporativo cuyo doc no está compartido con el usuario: registrar metadata y no reintentar.

#### Cómo leer los docs: por tramos, no completos

Las notas de Gemini tienen estructura fija: **Resumen → Decisiones → Próximos pasos → Detalles → Transcripción**. Lo primero ocupa ~15% del archivo; el resto es transcripción verbatim.

- **Por defecto, lee hasta el final de "Detalles"**. La línea de corte sale de `grep -n -m1 -E -- "- Transcripción|- Transcript|📖 Transcrip|^00:00:" <doc>`; si no aparece, el doc no tiene transcripción.
- **Baja a la transcripción solo cuando**:
  - hay que **atribuirle un compromiso al usuario** y el resumen no deja claro quién dijo qué (los criterios 1 y 2 del filtro de pendientes exigen speaker identificable);
  - el resumen se ve **incoherente** o en un idioma que no corresponde (Meet a veces detecta mal el idioma y produce texto sin sentido pero bien formateado: tratar esa fuente como ausente);
  - hay un **conflicto o un cierre de pendiente** que necesita cita textual.
- **Docs de datos** (sprint reviews, análisis de tickets, listados): lee hasta la tabla de KPIs o las conclusiones y detente.

**Regla**: extraer decisiones, pendientes y conflictos desde la fuente más cruda disponible: transcripción verbatim > notas manuales > resumen IA.

### Paso 3: Enrutar al proyecto o área

Para cada reunión, decidir destino. Reglas en orden (parar al primer match con confianza alta):

1. **El doc adjunto está en `refs/` de un proyecto existente**: ese proyecto.
2. **El título contiene el slug o el nombre de un proyecto activo** (revisar `1-proyectos/*/AGENTS.md`): ese proyecto.
3. **La mayoría de los asistentes son stakeholders de un proyecto** (cruzar con `1-proyectos/*/AGENTS.md` y `2-areas/*/AGENTS.md`): ese proyecto.
4. **Es un 1:1 recurrente** (2 asistentes, recurrente): `2-areas/1-a-1s/<persona>/` (ver su `AGENTS.md`).
5. **Es un ritual del equipo** (daily, retro, sprint review, comité): el área de rituales de `perfil.md` §2.
6. **Keyword match contra los `AGENTS.md` de proyectos**: el de mayor overlap.
7. **Si es dudoso**: `3-recursos/inbox-reuniones/<fecha>-<slug>.md` y marcarlo en el reporte como "requiere routing manual".

### Paso 4: Crear la nota de reunión

En `<destino>/reuniones/YYYY-MM-DD-<slug-titulo>.md`:

```markdown
# <Título de la reunión>

**Fecha**: YYYY-MM-DD HH:MM
**Duración**: <minutos>
**Asistentes**: <lista>
**Calendar event**: <link>
**Doc/transcript**: <link si existe>
**Fuente usada para extracción**: <transcripción verbatim | notas manuales | resumen IA>

## Contexto

<1-2 líneas sobre por qué se hizo, si se infiere del doc>

## Resumen

<resumen factual del transcript o notas, sin opinión>

## Próximos pasos mencionados

<lista textual de lo que se dijo que se haría — alimenta pendientes.md en el Paso 5>
```

**Idempotencia**: si el archivo ya existe, no sobrescribir; añadir `## Actualización <timestamp>` al final solo si hay información nueva.

### Paso 5: Extraer decisiones, pendientes y conflictos

**Decisiones** ("se decidió que…", "vamos a…", acuerdos): un archivo por decisión en `<destino>/decisiones/YYYY-MM-DD-<slug-corto>.md`:

```markdown
# <Título corto de la decisión>

**Fecha**: YYYY-MM-DD
**Contexto**: <de qué reunión salió> → [reunión](../reuniones/<archivo>.md)
**Quienes**: <personas involucradas>

## Decisión

<texto>

## Alternativas consideradas

<si aplica>

## Implicancias

<si se mencionaron>
```

**Pendientes** ("X hará Y", "queda pendiente Z"):

> **Principio rector**: `pendientes.md` es la lista de lo que *el usuario* tiene que hacer, decidir o esperar — **no la bitácora de trabajo del equipo**. La ejecución del equipo ya vive en Jira y en las notas de reunión. Un pendiente que el usuario no puede accionar ni necesita vigilar es ruido.
>
> **Test de utilidad** — antes de crear un pendiente: *"¿qué hace el usuario con esto?"* Si la respuesta honesta es "nada, se entera nomás", **NO crear**: va como bullet en "Próximos pasos mencionados" de la nota.

**Filtro estricto — crear el pendiente solo si cumple AL MENOS UNA condición**:

1. **Asignado al usuario**: el texto lo identifica explícitamente como responsable.
   - Patrones: "<nombre> va a…", "<nombre> se encarga de…", "@<nombre> + verbo", "<usuario-de-correo> + verbo", "yo + verbo" cuando el speaker identificado es el usuario. Usar los alias de "Cómo me nombran" de `perfil.md`.
   - Si no hay transcripción con speakers y solo dice "yo me encargo" sin saber quién es "yo", **NO** crear.
2. **Pedido por el usuario**: él solicitó la acción, aunque la ejecute otro. Debe haber evidencia en la fuente de que el pedido salió de él; no asumirlo porque el tema sea suyo.
3. **El usuario está bloqueado esperándolo**: el trabajo es de otro, pero su resultado es input directo de una decisión, comunicación o entregable del usuario, y él tendría que perseguirlo si se atrasa.
   - Válido: "[Ana] Revisar el documento de alternativas" cuando el usuario no puede cerrar la decisión del proyecto sin esa revisión.
   - **Inválido**: "[Diego] Enviar PR para cambiar el criterio de las alertas del job" — es ejecución de ingeniería; el usuario no la desbloquea ni la necesita para decidir.
   - En la duda: **NO crear**.
4. **Delegación a un reporte directo** (tabla de `perfil.md` §2): sus compromisos se trackean porque el usuario responde por ese trabajo y lo sigue en el 1:1.
   - Solo trabajo de nivel PM/PBD: discovery, documentos, definiciones, investigación, decisiones de producto. **No** ejecución de ingeniería o diseño que ellos coordinen.
   - ⚠️ **Los pares no entran por acá.** Sus compromisos solo cuentan si cumplen el criterio 2 o el 3. Tampoco el resto del equipo.
   - Si el usuario no tiene reportes directos, este criterio no aplica.
5. **Riesgo o compromiso externo que el usuario responde**: cliente en riesgo, escalamiento, fecha comprometida con alguien fuera del equipo, o decisión con impacto legal o regulatorio.
   - Válido: "El cliente Acme amenaza con dar de baja el servicio si no hay solución este mes".
   - **Inválido**: "Contemplar en el diseño la liquidación obligatoria cada 6 meses que exige Brasil" — es una restricción de diseño: va como contexto en la nota o como conflicto/riesgo.

**NO incluir** (regla dura — son los que más ruido generan):

- **Ejecución de ingeniería y diseño del equipo**: PRs, fixes, implementaciones, investigaciones técnicas, tareas de diseño, migraciones. Aunque tengan responsable claro: eso vive en Jira.
- **Compromisos de otros sin gancho con el usuario**: que el tema sea de un proyecto suyo **no basta**.
- **Sub-tareas de un pendiente que ya existe**: complementar el existente (ver Idempotencia).
- **"Seguir", "monitorear", "estar atento a"** sin acción ni fecha. Si el seguimiento importa, va como conflicto o riesgo.
- **Continuidad normal del trabajo** ("seguir avanzando con la misión").
- Acciones ya registradas como decisiones, y recordatorios genéricos sin responsable ni proyecto.

**Presupuesto por fuente**: como referencia, **máximo ~3 pendientes por reunión y ~2 por hilo de Chat**. Si estás por crear más, casi siempre estás transcribiendo el plan del equipo: quédate con los de mayor consecuencia y manda el resto a "Próximos pasos mencionados". Es una señal de revisión, no un límite rígido (un kickoff real puede justificar más).

**Formato** en `<destino>/pendientes.md` (crear con header `# Pendientes` si no existe):

```markdown
- `[propuesto]` 2026-05-25 — <texto> (responsable: <persona>, de [reunión](reuniones/<archivo>.md))
```

- Si el responsable es el usuario, omitir el campo.
- Si lo pidió el usuario, agregar `(pedido por <nombre>)`.
- **Si el responsable NO es el usuario, declararlo SIEMPRE** con `(responsable: <persona>)` o con prefijo `[<Nombre>]`. Omitirlo hace que se lea como trabajo propio y `/planificar-semana` le agendaría un bloque de foco por trabajo de otro.
- Si la fuente no deja claro quién ejecuta: `(responsable: sin determinar)`. La ausencia de marcador significa "es del usuario", y eso debe ser una afirmación, no un descuido.

**Idempotencia — tres reglas**:
1. **No re-agregar completados** — revisar la sección `## Completados` del mismo archivo.
2. **No duplicar uno relacionado** — si ya hay un pendiente abierto sobre el mismo tema o acción, **complementarlo** al final de su línea (`(también en [reunión X](...))`). Solo crear uno nuevo si el scope o el responsable es claramente distinto.
3. **Match semántico, no literal** — mismo objeto de trabajo y misma acción esperada, aunque cambien las palabras.

Flag inicial siempre `[propuesto]`. La priorización (P1-P5) la hace el usuario con `/revisar-pendientes`.

**Ante la duda**, no crear y dejarlo como bullet en "Próximos pasos mencionados". Si después importa, el usuario lo captura con `/capturar`.

**Conflictos y bloqueos** (tensiones, desacuerdos sin resolver, dependencias bloqueadas): append en `<destino>/conflictos.md`:

```markdown
- 2026-05-25 — <descripción> (de [reunión](reuniones/<archivo>.md))
```

### Paso 5.5: Cerrar pendientes ya resueltos

Las fuentes del día también **resuelven** pendientes de días anteriores. **Ejecutar este paso ANTES de agregar los pendientes nuevos**, para no duplicar algo que la misma fuente da por resuelto.

**5.5.1 — Cargar los abiertos del destino**: `[propuesto]`, `[confirmado]`, `[P1]`…`[P5]` y `- [ ]` del `pendientes.md` del destino, más el de proyectos hermanos que la fuente nombre explícitamente. No barrer todo el brain.

**5.5.2 — Buscar evidencia de resolución** (transcripción > notas > resumen IA).

Señales válidas (pasado y hecho consumado):
- "ya lo mandé", "quedó listo", "lo subí ayer", "ya está en producción", "lo cerramos".
- "ya hablé con <persona>" para un pendiente de hablar con esa persona.
- El entregable aparece como existente ("en el documento que envié", "el PR que ya está mergeado").
- Una **decisión** de la misma reunión que responde exactamente lo que el pendiente pedía definir → cerrar el pendiente y registrar la decisión.

No son cierre: futuro o intención ("lo voy a mandar", "casi listo"), avance parcial, que el tema solo se mencione, o que otro diga que "debería estar listo" sin confirmarlo el responsable.

> **Regla de oro — conservador por defecto**: cerrar un pendiente que sigue abierto es peor que dejar abierto uno ya hecho. **Ante cualquier duda, NO cerrar.**

**5.5.3 — Exigir evidencia citable**: solo cerrar si puedes pegar el fragmento textual que lo respalda, y si ese fragmento se refiere al **mismo objeto de trabajo**. "Avanzamos con el orden de consumo" NO cierra "Enviar el código del orden de consumo a <persona> para revisión".

**5.5.4 — Aplicar el cierre**: mover la línea a `## Completados` al final del mismo `pendientes.md` (crearla si no existe), conservando el texto y la metadata:

```markdown
## Completados

- `[completado:2026-08-31]` 2026-08-25 — <texto original íntegro> (originalmente: [P2]) — 🤖 cerrado por /cierre-dia según [reunión](reuniones/2026-08-27-checkpoint.md): "ya le mandé el doc el martes"
```

Siempre con el marcador `🤖 cerrado por /cierre-dia`, el link a la fuente y la cita. Nunca borrar la línea: los cierres automáticos son falibles y deben poder revertirse.

**5.5.5 — Casos dudosos: anotar, no cerrar**:

```markdown
- `[P2]` 2026-08-25 — <texto original> (de [reunión](...)) — ⏳ avance 2026-08-31: "estoy terminando el doc, lo mando mañana" (de [reunión](reuniones/2026-08-31-daily.md))
```

**5.5.6 — Reportar siempre**: todo cierre automático aparece en el reporte del Paso 8 con su cita.

### Paso 6: Procesar la actividad de Google Chat

Chat es una fuente paralela a las reuniones: muchas decisiones y compromisos viven solo ahí. Si la fuente Google Chat está inactiva, saltar al Paso 7.

#### Paso 6.1: Barrer los spaces con actividad

Cada llamada a `gws` cuesta ~1,3 s y un usuario típico tiene cientos de spaces. Cuatro reglas:

**a) Parte del índice cacheado.** `3-recursos/chat-spaces.md` tiene los spaces conocidos con su `spaces/ID` y destino. Refréscalo con `gws chat spaces list` (paginando con `nextPageToken`: `pageSize` 100 no trae todo) si aparecen spaces desconocidos o pasó más de un mes.

**b) Filtra por `lastActiveTime`.** `gws chat spaces list` devuelve `lastActiveTime` por space: descarta los que tienen actividad anterior al inicio del rango. Excluye también los que calzan con los patrones a ignorar de `organizacion.md`, los spaces efímeros de reunión (nombre que termina en fecha: `... - Sep 3`) y los DM o group chats sin actividad en el rango.

**c) Consulta el rango completo de una vez**, no día por día:

```bash
gws chat spaces messages list --params '{"parent":"spaces/<SPACE_ID>","filter":"create_time > \"<desde>T00:00:00<offset>\" AND create_time < \"<hasta>T23:59:59<offset>\"","pageSize":200,"orderBy":"create_time ASC"}'
```

**d) Paraleliza el barrido** con ~10 workers:

```python
from concurrent.futures import ThreadPoolExecutor
import json, subprocess

def fetch(space_id):
    params = json.dumps({"parent": space_id,
                         "filter": f'create_time > "{desde}T00:00:00{offset}" AND create_time < "{hasta}T23:59:59{offset}"',
                         "pageSize": 200, "orderBy": "create_time ASC"})
    p = subprocess.run(['gws', 'chat', 'spaces', 'messages', 'list', '--params', params],
                       capture_output=True, text=True, stdin=subprocess.DEVNULL)
    out = p.stdout[p.stdout.find('{'):]          # ← ver "Parseo de gws" en Reglas críticas
    try:
        return space_id, json.loads(out).get('messages', [])
    except Exception:
        return space_id, None                     # None = error, distinto de [] = sin mensajes

with ThreadPoolExecutor(max_workers=10) as ex:
    resultados = dict(ex.map(fetch, space_ids))
```

La función distingue **error (`None`)** de **space sin mensajes (`[]`)**: confundirlos produce un falso "no hubo actividad".

**ID del usuario**: si `perfil.md` §1 no tiene el "ID de usuario en Google Chat", obtenerlo de `gws chat spaces members list` en algún space con actividad (el miembro cuyo email es el del usuario) y guardarlo en `perfil.md`.

#### Paso 6.2: Decidir qué spaces procesar

**Sí**: spaces con más de 3 mensajes en el día y al menos uno sustantivo (más de 15 palabras); spaces donde se menciona al usuario (`<users/ID>` o sus alias); spaces donde el usuario escribió.

**No**: anuncios unidireccionales (solo bots o un mismo remitente sin respuestas), spaces con solo emojis o links, y spaces sociales (nombre con "random", "off-topic", "memes", "cafecito"…) — saltarlos y mencionarlos en el reporte.

#### Paso 6.3: Enrutar el space

1. **Mapeo explícito**: `**Space**: \`spaces/XXX\`` en algún `1-proyectos/*/AGENTS.md` o `2-areas/*/AGENTS.md` (lo siembra `/mapear-chat-spaces`). Es el camino preferido.
2. **El nombre del space contiene el slug o una keyword de un proyecto activo.**
3. **Los miembros coinciden con los stakeholders de un proyecto.**
4. **Si es dudoso**: resumen en `3-recursos/inbox-chat/<fecha>-<slug-space>.md` y marcarlo en el reporte para mapeo manual.

#### Paso 6.4: Sintetizar los hilos (no transcribir)

Los mensajes traen solo `sender.name` (`users/<id>`). Resuelve los nombres con `gws chat spaces members list --params '{"parent":"spaces/<ID>","pageSize":100}'` (trae `displayName` y `email`), solo para los spaces que vas a procesar y en paralelo. No uses la People API: el token de `gws` no tiene esos scopes. No atribuyas un "yo me encargo" sin haber resuelto antes quién lo escribió.

Agrupar por `thread.name` y, por cada hilo sustantivo, extraer decisiones explícitas, compromisos con responsable y preguntas o conflictos sin resolver. Escribir en `<destino>/chat/YYYY-MM-DD-<slug-tema>.md`:

```markdown
# <Tema del hilo>

**Fecha**: YYYY-MM-DD
**Space**: <nombre del space> (`spaces/XXX`)
**Participantes**: <nombres>
**Mensajes**: N
**Link al thread**: <URL si gws la devuelve>
**Fuente**: Google Chat (verbatim agrupado por thread)

## Contexto

<1-2 líneas: por qué empezó el hilo>

## Lo que pasó (resumen factual)

<bullets>

## Mensajes clave (citas literales relevantes)

> **<persona>**: "<cita>"
```

#### Paso 6.5: Decisiones, pendientes y conflictos (igual que reuniones)

Mismo flujo del Paso 5, con `de [chat](chat/<archivo>.md)` como fuente. **Incluye el Paso 5.5**: los hilos de Chat son de las fuentes más frecuentes de cierre ("listo, ya lo subí").

Si en el día hay una notificación de un comentario asignado al usuario en un doc, leer el comentario con `gws drive comments list` (con `startModifiedTime`) en vez de exportar el doc completo.

### Paso 7: Enriquecer con referencias externas

Para cada reunión e hilo procesado, si el contenido menciona:

- **Tickets de Jira** (regex `[A-Z]+-\d+`), si la fuente Jira está activa: verificar **una vez** `command -v acli`. Si existe, consultar `acli jira workitem view <KEY> --json --fields summary,status,priority,assignee`; si no, registrar link y contexto marcando estado y prioridad como no verificados, sin reintentar por cada ticket. Añadir a `<destino>/refs/jira.md`:
  ```markdown
  - [KEY-1234](<JIRA>/browse/KEY-1234) — <Status> — <Priority> — "<Summary>" (mencionado en [<reunión|chat>](<archivo>) el YYYY-MM-DD)
  ```
  Si el KEY ya está, actualizar el status (no duplicar).
- **PRs de GitHub** (URLs `github.com/<org>/<repo>/pull/N` o `<org>/<repo>#N`), si la fuente GitHub está activa: `gh pr view <N> --repo <org>/<repo> --json number,title,state,labels,url`. Añadir a `<destino>/refs/github.md`:
  ```markdown
  - [#1234 <org>/<repo>](https://github.com/<org>/<repo>/pull/1234) — <State> — "<Title>" (mencionado en [<reunión|chat>](<archivo>) el YYYY-MM-DD)
  ```
  Si ya está, actualizar el State.
- **Procesos, políticas o docs oficiales**, si Buk Atlas está activa: buscar el término en Atlas (ver `/atlas`) y, si hay un doc relevante, añadirlo a `refs/README.md` como "Buk Atlas — <nombre>".

### Paso 8: Reportar

```
✓ Cierre del día <YYYY-MM-DD>:

Reuniones (N procesadas):
- ✅ <título 1> → <proyecto/área> (D dec, P pend, C confl)
- ⚠️  <título 2> → 3-recursos/inbox-reuniones/ (sin routing)

Chat (M spaces con actividad):
- ✅ <space> → <proyecto/área> (T threads, D dec, P pend)
- ⚠️  <space> → 3-recursos/inbox-chat/ (sin mapeo — correr /mapear-chat-spaces)

Total: <D> decisiones, <P> pendientes propuestos, <C> conflictos.
<X> referencias externas linkeadas (Jira/GitHub/Atlas).

🤖 Pendientes cerrados automáticamente (<K>) — revisa y avísame si alguno no corresponde:
- <proyecto/área> · "<texto del pendiente>"
  └ evidencia: "<cita textual>" (de <reunión|chat>)

⏳ Con avance pero sin cerrar (<J>):
- <proyecto/área> · "<texto>" — "<cita>"

Proyectos actualizados: <lista>
```

Si no hubo cierres ni avances, omitir esas dos secciones. **Nunca** omitir un cierre que sí ocurrió.

Si hubo reuniones sin notas o spaces sin contenido sustantivo:
```
ℹ️  <N> reuniones sin notas accesibles — registré solo metadata.
ℹ️  <M> spaces sin actividad sustantiva — saltados.
```

## Reglas críticas

- **Más de un día ⇒ subagentes en paralelo** (Paso 0). No es opcional.
- **Parseo de `gws`: siempre desde la primera llave.** `gws` escribe `Using keyring backend: …` en **stderr**: en la terminal se ve mezclado con el JSON, pero vía `subprocess` no. Por eso `tail -n +2` o `split('\n')[1:]` **rompen el JSON en silencio**. Usar siempre `out = p.stdout[p.stdout.find('{'):]`.
- **Canario antes de todo barrido masivo.** Antes de recorrer los spaces, probar con uno que sepas que tiene mensajes. Si un barrido da cero resultados en *todos* los ítems, es un bug de parseo hasta que se pruebe lo contrario.
- **`gws` consume stdin.** Un `while read … done < archivo` que llame a `gws` procesa solo la primera línea. Redirigir `</dev/null` o hacer el loop en Python.
- **Cerrar pendientes solo con evidencia citable** (Paso 5.5). Nunca por inferencia ni por intención futura. Todo cierre se reporta con su cita.
- **NUNCA** crear Google Tasks, enviar mensajes ni hacer nada externo. Solo escribir en el brain.
- **Privacidad**: aplicar el nivel de `perfil.md` §5. Con `completo`, registrar desempeño, feedback, compensación y contexto personal con el mismo detalle que el resto. Con `metadata`, registrar solo el tema y quiénes participaron. Nunca tokens ni contraseñas.
- **Idempotencia**: segura de re-ejecutar el mismo día. Verificar duplicados antes de añadir cualquier ítem.
- **Si el día no tiene reuniones ni Chat procesables**: `Sin actividad procesable para <fecha>.` y terminar.
- **Más de 10 reuniones**: procesar en lotes y reportar progreso intermedio.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*

### Heredados del brain original (aplican a cualquier usuario de `gws`)

- **2026-06-15 — Día equivocado por un weekday relativo.** Se pidió "el viernes" y se procesó un sábado (resultado falso-vacío). Verificar siempre el día de la semana de la fecha calculada (sección Input).
- **2026-08-31 — `acli` no instalado.** El Paso 7 fallaba con `command not found`. Verificar `command -v acli` una vez y, si falta, registrar los tickets sin estado en vez de abortar el paso.
- **2026-08-31 — Transcripción con idioma mal detectado.** Meet transcribió una reunión en español como inglés y las notas de Gemini heredaron el sinsentido, bien formateado. Si el contenido es incoherente, tratar la fuente como ausente y no inventar decisiones ni pendientes.
- **2026-08-31 — `gws drive files export` ignora `-o`.** Siempre escribe `download.txt` en el cwd; exportar desde un directorio temporal y renombrar tras cada llamada. Nunca desde la raíz del brain.
- **2026-09-04 — Dos días procesados en serie: 22 minutos.** Origen del Paso 0 (subagentes por día) y de exportar los docs en lote.
- **2026-09-04 — "Using keyring backend" va a stderr.** Descartar la primera línea de stdout rompió el JSON y tres barridos reportaron "cero actividad" en spaces con mensajes. Parsear desde la primera llave.
- **2026-09-04 — `while read` consumido por `gws`.** `gws` lee stdin; redirigir `</dev/null` o usar Python.
- **2026-10-05 — Los mensajes de Chat no traen el nombre del remitente.** La People API responde `403 insufficient authentication scopes`; resolver con `gws chat spaces members list`. Además: `gws chat spaces list` hay que paginarlo, y el offset horario cambia con el horario de verano.
- **2026-10-26 — Notas de Gemini de eventos corporativos dan 404.** En eventos con invitación por grupo el doc aparece en `attachments` pero no está compartido. Registrar metadata y no reintentar con otros flags.
- **2026-11-05 — Export de un doc muy grande falla por timeout.** Para leer un comentario, usar `gws drive comments list` en vez de exportar el doc. No reintentar el export más de una vez.
- **2026-11-05 — Cambió el separador de la transcripción.** Las notas de Gemini ya no usan `📖 Transcripción` sino `<Título> - Transcripción`; cortar con la expresión del Paso 2. Filtrar spaces por `lastActiveTime` bajó el barrido de ~440 a ~57 spaces sin perder actividad.
