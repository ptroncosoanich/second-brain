---
description: Asocia tus spaces de Google Chat a proyectos o áreas del brain, para que /cierre-dia sepa cómo enrutar la actividad
category: bootstrap
---

# /mapear-chat-spaces — Mapeo de spaces a proyectos y áreas

Tu rol: detectar los spaces de Google Chat en los que participa el usuario y proponer un mapeo a sus proyectos y áreas. El mapeo queda sembrado en el `AGENTS.md` de cada destino, donde `/cierre-dia` lo lee.

> **Antes de empezar**, lee `perfil.md`: email e ID de Chat del usuario (§1), su equipo (§2), y si la fuente Google Chat está activa (§3). Los patrones de spaces a ignorar están en `organizacion.md`. Si Google Chat está inactiva, avisar y terminar.

## Cuándo usar

- **Primera vez**, después de `/para-init`.
- Cuando se agreguen proyectos o áreas con space asociado.
- Cuando `/cierre-dia` reporte spaces "sin mapeo".

## Proceso

### Paso 1: Listar los spaces

```bash
gws chat spaces list --params '{"pageSize":100}'
```

**Paginar con `nextPageToken`** hasta el final: una sola página no trae todo (un usuario típico tiene cientos o miles, la mayoría efímeros de reunión). Parsear desde la primera llave (`out[out.find('{'):]`).

Por cada space: `name` (`spaces/XXX`), `displayName`, `spaceType` (`SPACE`, `GROUP_CHAT`, `DIRECT_MESSAGE`) y `lastActiveTime`.

### Paso 2: Filtrar los irrelevantes

Descartar de la propuesta:
- Los que calzan con los patrones a ignorar de `organizacion.md`.
- Spaces efímeros de reunión (nombre que termina en fecha, ej. `... - Sep 3`): su contenido ya está en las notas de la reunión.
- DM y spaces sin actividad en los últimos 60 días.
- Spaces sociales ("random", "off-topic", "memes", "cafecito", celebraciones) y de bots.

Marcar como **dudosos** los de nombre genérico ("General", "Equipo").

### Paso 3: Proponer el mapeo

Reglas en orden:

1. **El nombre contiene el slug o el nombre de un proyecto activo** (`1-proyectos/*/`) → confianza **alta**.
2. **El nombre contiene una keyword de un área** (ver los `AGENTS.md` de `2-areas/`) → confianza **media**.
3. **Los miembros coinciden con los stakeholders de un proyecto o área**: `gws chat spaces members list --params '{"parent":"spaces/XXX","pageSize":100}'` y cruzar con los `AGENTS.md` → confianza **media**. Hacerlo en paralelo y solo para los candidatos sin match por nombre.
4. **DM con una persona de `2-areas/1-a-1s/`** o de las tablas de `perfil.md` §2 → `2-areas/1-a-1s/<persona>/`, confianza **alta**.
5. **Sin match claro** → "sin mapear": decide el usuario.

### Paso 4: Presentar la propuesta y pedir confirmación

```
Encontré N spaces relevantes. Propuesta de mapeo:

✅ Confianza alta (M):
1. "<nombre del space>" (spaces/AAA111) → 1-proyectos/<slug>/
2. DM con <persona> (spaces/BBB222) → 2-areas/1-a-1s/<persona>/

⚠️  Confianza media (M):
3. "<nombre>" (spaces/CCC333) → 2-areas/<area>/  (¿correcto?)

❓ Sin mapeo claro (M):
4. "<nombre>" (spaces/DDD444) — ¿algún proyecto o área?

Puedes decir:
- "sí todos" → confirma alta y media
- "sí 1, 2"
- "mapea 4 a <slug>"
- "ignora 3"
```

### Paso 5: Sembrar el mapeo

Para cada mapeo confirmado, `Edit` sobre el `AGENTS.md` del destino. Si no existe la sección, crearla:

```markdown
## Spaces de Chat asociados

- **Space**: `spaces/AAA111` — "<nombre del space>" (mapeado vía /mapear-chat-spaces el YYYY-MM-DD)
```

**Usar el formato exacto `**Space**: \`spaces/XXX\``**: `/cierre-dia` lo busca con regex.

Además, actualizar `3-recursos/chat-spaces.md` (el índice que usa `/cierre-dia` como caché): una fila por space relevante con su ID y destino, los ignorados en su sección, y la fecha de actualización en el encabezado.

### Paso 6: Reportar

```
✓ Mapeo completado:
- N spaces mapeados
- M ignorados
- K sin mapeo (decisión postergada)

Actualizados:
- 1-proyectos/<slug>/AGENTS.md (+N spaces)
- 3-recursos/chat-spaces.md

El próximo /cierre-dia ya enruta estos spaces.
```

## Reglas

- **NUNCA** mapear sin la confirmación del Paso 4: el mapeo define el routing futuro.
- **DMs**: por defecto van a `2-areas/1-a-1s/<persona>/`. Avisar si se va a mapear un DM a un proyecto o área de equipo.
- **Spaces sensibles** ("salarios", "performance", "evaluaciones"): advertir antes de mapear; con privacidad `metadata` en `perfil.md` §5, sugerir no mapearlos.
- **Idempotencia**: si un space ya está mapeado (su ID ya aparece), no duplicar; si la propuesta es a otro destino, pedir confirmación y mover la línea.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
