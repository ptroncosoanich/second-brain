---
description: Propone el foco de la semana leyendo todos los pendientes abiertos; los ordena por prioridad y antigüedad, los agrupa por esfuerzo y propone bloques en el calendario
argument-hint: [YYYY-MM-DD opcional — lunes de la semana a planificar; por defecto la semana en curso]
category: routine
---

# /planificar-semana — Foco semanal a partir de los pendientes

Tu rol: leer **todos** los pendientes abiertos del brain y proponerle al usuario en qué enfocarse esta semana, agrupado por **tipo de esfuerzo**. No es un resumen de todo lo pendiente: es una selección corta y defendible.

> **Principio**: el resultado es un plan al que el usuario le pueda decir que sí. Si no cabe en una semana real con la agenda llena de reuniones, la skill falló. **Menos y mejor elegido** gana a exhaustivo.

> **Antes de empezar**, lee `perfil.md`: nombre (§1), reportes directos y pares (§2), reuniones que no bloquean la agenda (§2), zona horaria, horario laboral y cupo de foco (§4).

## Input

`$ARGUMENTS` puede traer el lunes a planificar (`YYYY-MM-DD`). Si viene vacío, la semana en curso. Mostrar el rango y la semana `YYYY-Www`.

---

## Paso 1: Recolectar pendientes abiertos

```bash
find 1-proyectos 2-areas -name 'pendientes.md' -type f
```

Un ítem está **abierto** si es:

- Familia A: `` - `[TAG]` YYYY-MM-DD — texto `` con `TAG` ∈ `propuesto`, `confirmado`, `P1`…`P5`.
- Familia B: `- [ ] texto — Responsable [Px] *(de: fecha — título)*`.

**Excluir**: `[completado:...]`, líneas bajo `## Completados` y `- [x]`.

Por cada ítem: `file`, `slug`, `tag`, `fecha`, `texto`, `responsable` (si la línea lo declara) y `antigüedad_dias`.

---

## Paso 2: Puntuar por prioridad y antigüedad

`score = peso_prioridad + bonus_antigüedad`

| Tag | Peso |
|---|---|
| `P1` | 100 |
| `P2` | 70 |
| `P3` | 45 |
| `P4` | 25 |
| `P5` | 10 |
| `propuesto` / `confirmado` | 35 |

**Bonus por antigüedad**: +2 por semana cumplida, con tope de +30. La antigüedad amplifica, no reemplaza: un P4 viejo no desplaza a un P1 fresco.

**Overrides que van directo arriba**:

- **Compromiso con fecha vencida o de esta semana** ("informar antes del X", "enviar el martes").
- **Cliente en riesgo o escalamiento** (baja de servicio, cliente crítico, impacto legal o regulatorio).

**Candidatos a descartar, no a hacer**: `P4`/`P5` con más de 8 semanas. No entran al plan; se listan como higiene (Paso 6).

---

## Paso 3: Clasificar por tipo de esfuerzo

### Determinar el responsable (obligatorio antes de clasificar)

Un pendiente es **de otra persona** si:

- tiene prefijo con nombre: `` - `[P2]` 2026-08-25 — [Ana] Investigar... ``;
- tiene campo `(responsable: <persona>)`, `(responsable: equipo)`;
- tiene `(pedido por <usuario>)` — por definición lo ejecuta otro;
- el texto nombra a un tercero como ejecutor.

Sin ninguna señal, el responsable es el usuario (convención de `/cierre-dia`). `(responsable: sin determinar)` se trata como no propio. Responsable compartido (`responsable: <usuario> + <otro>`) cuenta como propio.

### 🔴 El foco es solo para trabajo propio

**Regla dura**: un pendiente cuyo responsable es otra persona **NUNCA** entra en 🔴, aunque su texto calce con los patrones de foco. Lo que al usuario le cuesta tiempo es **pedirlo, revisarlo y desbloquearlo**:

| Situación | Categoría |
|---|---|
| Solo hay que empujarlo o preguntar cómo va | 🟢 — punto del 1:1 o mensaje |
| Ya hay entregable y hay que revisarlo | 🟡 |
| Hay que alinear criterio con esa persona | 🟡 |

Si un ítem sin marcador de responsable parece trabajo pesado que por contexto es claramente de otro, no asumir que es del usuario: dejarlo en 🟡 con `(responsable no declarado — ¿es tuyo?)`.

### 🟢 Cortas pero importantes — menos de ~30 min

*Agendar, coordinar, enviar un correo, responder, avisar, contactar, cargar información, compartir un link, consultar algo puntual.* También el seguimiento a delegados: para reportes directos, como punto del 1:1; para pares o terceros, como mensaje.

### 🟡 Mediano esfuerzo — ~30 min a ~2 h, o requiere conversar

*Revisar un documento y comentar, ajustar un diseño, alinear un tema, preparar una presentación, definir un criterio acotado, validar una propuesta.*

### 🔴 Requieren foco — más de 1 h continua

*Investigar un mercado o competidor, analizar datos, revisar tickets en volumen, escribir un documento de estrategia desde cero, resolver una definición compleja, rediseñar un modelo.*

**Cupo duro**: el de `perfil.md` §4 (por defecto 4). Si hay más candidatos, elegir los de mayor score y nombrar el resto en "No entran esta semana".

**Ante la duda, subir de categoría**: subestimar el esfuerzo es lo que hace que un plan no se cumpla.

---

## Paso 4: Podar a un plan realista

| Categoría | Cupo |
|---|---|
| 🟢 Cortas | ~8 |
| 🟡 Mediano | ~5 |
| 🔴 Foco | el de `perfil.md` (duro) |

- **Máximo 2 ítems de foco del mismo proyecto o área.**
- **Deduplicar por tema**: dos pendientes que son la misma conversación van como uno, con ambos orígenes.
- **Agrupar lo agrupable**: varias cortas con la misma persona son un bloque ("en el 1:1 con Ana: A, B, C").

---

## Paso 5: Proponer bloques en el calendario

Un plan sin hora agendada no se cumple. Buscar espacio real en la agenda y **proponer** un bloque por ítem.

### 5.1 — Leer la agenda

```bash
gws calendar events list --params '{"calendarId":"primary","timeMin":"<lunes>T00:00:00<offset>","timeMax":"<sábado>T00:00:00<offset>","singleEvents":true,"orderBy":"startTime","maxResults":100}'
```

`<offset>` es el de la zona horaria de `perfil.md` para esa semana (ver `/cierre-dia`, sección Input). Parsear desde la primera llave.

### 5.2 — Qué ocupa de verdad

Mirar el `responseStatus` del asistente con `"self": true`:

| Situación | ¿Bloquea? |
|---|---|
| `accepted` | ✅ Sí |
| `needsAction` (sin responder) | ✅ Sí |
| `tentative` | ❌ No |
| `declined` | ❌ No |
| **Sin invitados** (almuerzo, "Fuera de la oficina", bloques propios) | ✅ **Sí** — es tiempo que el usuario reservó |
| Evento de día completo ajeno (ej. "Vacaciones de Ana") | ❌ No |
| Reuniones de "nunca bloquean mi agenda" (`perfil.md` §2) | ❌ No, aunque estén `accepted` |

> ⚠️ Los eventos **sin invitados** no tienen `responseStatus`: tratarlos como opcionales haría agendar encima del almuerzo.

### 5.3 — Duración

🔴 1 hora · 🟡 30 minutos · 🟢 15 minutos.

### 5.4 — Colocar los bloques

- **Dentro del horario laboral** de `perfil.md` §4. Fuera solo si no hay alternativa, y decirlo.
- **Respetar el almuerzo** y los bloques propios.
- **Dejar aire**: no pegar bloques a una reunión que empieza justo después.
- **Foco primero**, de preferencia en la mañana y en los huecos más largos.
- **Máximo un 🔴 por día.**
- **Agrupar las 🟢** de la misma persona en un bloque, o anexarlas a un 1:1 existente esa semana.
- **Respetar el orden de score**: si no alcanza el espacio, lo de menor score queda sin hora, dicho explícitamente.

Si no hay espacio para todo, no comprimir ni salirse del horario: reportar cuántos quedaron sin bloque.

### 5.5 — Proponer, no crear

**La skill nunca crea eventos sin confirmación.** Si el usuario acepta:

```bash
gws calendar events insert --params '{"calendarId":"primary"}' --json '{
  "summary":"🔴 Foco: <título corto>",
  "description":"Bloque de foco (plan semanal <YYYY-Www>).\n\n<contexto>\n\nPendiente [<Px>] abierto desde <fecha> · <ruta del pendientes.md>",
  "start":{"dateTime":"<ISO>","timeZone":"<zona de perfil.md>"},
  "end":{"dateTime":"<ISO>","timeZone":"<zona de perfil.md>"},
  "eventType":"focusTime","transparency":"opaque"}'
```

`eventType`: `focusTime` para 🔴, `default` para 🟡 y 🟢. Sin invitados.

---

## Paso 6: Presentar el plan

En el chat (sin crear archivos por defecto):

```markdown
# Semana <YYYY-Www> (<lunes DD/MM> – <viernes DD/MM>)

**Foco de la semana**: <una frase — el hilo conductor>

## 🔴 Requieren foco (<n>/<cupo>) — bloques de 1h

1. **<título corto>** · `<slug>` · `[P1]` · <n> semanas abierto
   📅 <día DD/MM> <HH:MM>–<HH:MM>
   <por qué esta semana, en una línea>

## 🟡 Mediano esfuerzo (<n>) — bloques de 30 min
- **<título>** · `<slug>` · `[P2]` · 📅 <día DD/MM> <HH:MM>

## 🟢 Cortas pero importantes (<n>) — bloques de 15 min
- **<título>** · `<slug>` · `[P3]` · 📅 <día DD/MM> <HH:MM>
- **En el 1:1 con <persona>** (<día DD/MM> <HH:MM>, ya agendado): <a>, <b>

## ⚠️ Sin espacio en la agenda (<n>)
- **<título>** · `<slug>` — candidato a la próxima semana

---

## No entran esta semana
- **<título>** · `<slug>` — <razón: cupo de foco lleno / depende de X>

## 🧹 Higiene (<n> ítems P4–P5 con +8 semanas)
Candidatos a descartar en `/revisar-pendientes`:
- <título> · `<slug>` · abierto hace <n> semanas
```

- **Cada ítem de foco lleva su "por qué esta semana".** Si no puedes escribirlo, no debería estar.
- Mostrar siempre prioridad y antigüedad.
- **"No entran esta semana" es obligatoria** si hubo candidatos de foco fuera del cupo.
- No inventar deadlines que no estén en el texto.
- Decir sobre qué reuniones se agenda encima, si corresponde.
- Omitir "Sin espacio" si todo entró.
- Ítems de carpetas sensibles: referenciarlos por proyecto, sin el contenido.

---

## Paso 7: Cerrar

Preguntar en una línea si quiere **crear los bloques en el calendario**, ajustar el ranking o guardar el plan en `3-recursos/planificacion/<YYYY-Www>.md`. No escribir el archivo ni crear eventos salvo que lo pida; si acepta los eventos, crearlos todos y reportar cada uno con su link.

---

## Reglas críticas

- **Solo lectura por defecto**: no modifica ningún `pendientes.md` (eso es `/revisar-pendientes`) ni el calendario sin confirmación.
- **Nunca tratar un evento sin invitados como libre.**
- **El cupo de foco es duro.**
- **Nada delegado en 🔴.**
- **No re-priorizar los archivos**: el score ordena el plan; los `[Px]` los decide el usuario.
- **Pocos pendientes** (menos de 5): decirlo y proponer un plan corto, sin rellenar.
- **Idempotente**: re-ejecutar el mismo día da el mismo plan.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
