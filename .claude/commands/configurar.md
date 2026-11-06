---
description: Configura el brain para su usuario — revisa organizacion.md, llena perfil.md, verifica las CLIs, crea el área del equipo, genera los adaptadores de Codex, instala la rutina y revisa que el repo sea privado
argument-hint: [organizacion | perfil | fuentes | parametros | estructura | codex | rutina | git — opcional, para correr un solo bloque]
category: bootstrap
---

# /configurar — Dejar el brain listo para usar

Tu rol: guiar al usuario por la configuración de este workspace hasta que pueda correr `/para-init` y `/cierre-dia`. Conversacional: un bloque a la vez, con defaults propuestos, preguntando solo lo que no puedes inferir.

## Input

`$ARGUMENTS`:
- vacío → flujo completo, retomando donde quedó (lo que ya está configurado se muestra y se salta).
- un bloque (`organizacion`, `perfil`, `fuentes`, `parametros`, `estructura`, `codex`, `rutina`, `git`) → solo ese.

## Paso 0: Diagnóstico

Ejecutar en paralelo y mostrar una tabla de estado (✅ listo · ⚠️ a medias · ❌ falta):

```bash
ls organizacion.md && grep -c "COMPLETAR" organizacion.md   # valores de la organización (Paso 0.5)
grep -n "COMPLETAR" perfil.md                       # campos pendientes del perfil
for c in gws gh acli bq claude codex; do printf '%s: ' "$c"; command -v "$c" || echo "no instalado"; done
gws calendar calendarList list --params '{"maxResults":1}' </dev/null   # sesión de Google
gh auth status
acli jira workitem search --jql "assignee = currentUser()" --limit 1 --json
bq ls --max_results=1 --project_id=<proyecto de BigQuery de organizacion.md>   # solo si organizacion.md existe
git remote -v
ls .agents/skills
uname -s; launchctl list 2>/dev/null | grep cierre-dia; crontab -l 2>/dev/null | grep cierre-dia
```

Un error de autenticación no es un fallo de la skill: es una fila ❌ con su remedio. Proponer el orden de los bloques que faltan y empezar por el primero.

## Paso 0.5: Organización (`organizacion`)

`organizacion.md` (en la raíz, junto a `perfil.md`) trae los valores compartidos por el equipo: Jira, GitHub, BigQuery, Buk Atlas, spaces a ignorar y catálogo de datos. No viene en el repo público y está en `.gitignore`.

- **Existe y no tiene `COMPLETAR`** → ✅. Usar sus valores sin preguntar nada de esta parte y validarlos en el Paso 2 (el proyecto de BigQuery con `bq ls`, el ID de Atlas con una búsqueda de prueba de `/atlas`).
- **No existe** → decírselo al usuario antes de seguir, tal cual:
  ```
  Falta organizacion.md, el archivo con los valores internos de Buk (Jira, GitHub, BigQuery, Buk Atlas).
  Pídeselo a Pablo Troncoso y déjalo en la raíz de esta carpeta (junto a perfil.md); después vuelve a correr /configurar.
  ```
  Mientras tanto, seguir con los bloques que no lo necesitan (`perfil`, `estructura`, `codex`) y dejar las fuentes Jira, GitHub, BigQuery y Buk Atlas como ⚠️ pendientes. Si el usuario no es de Buk o no puede conseguirlo, ofrecer copiar `organizacion.ejemplo.md` a `organizacion.md` y completarlo juntos.
- **Existe con `COMPLETAR`** → completar solo esos campos con el usuario.

Nunca inventar ni deducir estos valores, y nunca escribirlos en `perfil.md` ni en otro archivo versionado.

## Paso 1: Perfil (`perfil`)

1. **Inferir antes de preguntar**: si `gws` responde, el email es el `id` del calendario con `"primary": true` en `gws calendar calendarList list`. Si hay `git config user.name`, proponerlo como nombre.
2. **Preguntar en un solo mensaje** lo que falte (usar `AskUserQuestion` si está disponible):
   - nombre, cómo te nombran en reuniones y chats (apodos, usuario de correo), rol, manager;
   - reportes directos (nombre, rol, cómo los nombran) — puede ser ninguno;
   - pares cercanos (nombre y rol) — explicar que sus compromisos no se trackean como delegación;
   - nombre del equipo (para el área de rituales) y reuniones que nunca bloquean la agenda (opcional);
   - quién más tiene acceso al repo → de ahí sale el nivel de detalle en temas sensibles (`completo` si es solo el usuario, `metadata` si no). Explicar la diferencia en una línea.
3. Escribir las secciones 1, 2 y 5 de `perfil.md` con `Edit`, reemplazando cada `COMPLETAR`. No tocar el resto.
4. **ID de Google Chat** (si `gws` funciona): `gws chat spaces list` → en uno o dos spaces recientes, `gws chat spaces members list --params '{"parent":"spaces/<ID>","pageSize":100}'` → el `member.name` cuyo email coincide con el del usuario. Si no aparece rápido, dejarlo vacío: `/cierre-dia` lo detecta después.

## Paso 2: Fuentes (`fuentes`)

Para cada fila de `perfil.md` §3, según el diagnóstico:

| Estado | Acción |
|---|---|
| CLI instalada y con sesión | `activa` |
| CLI instalada sin sesión | dar el comando de login y esperar a que el usuario lo corra (`gws`: el login de buk-cli; `bq`: `gcloud auth login`; GitHub: `gh auth login`; Jira: `acli jira auth login --web`) |
| CLI no instalada | dar la instalación: `gws` y `bq` vienen con buk-cli (guía interna de Buk; ofrecer `/atlas buk-cli` si Atlas funciona); `brew install gh`; `brew tap atlassian/homebrew-acli && brew install acli` |
| El usuario no usa esa fuente | `inactiva` |
| Prefiere un conector MCP | `conector` en la columna Herramienta (advertir que la rutina programada lo necesita disponible en `claude --print`) |

No instales nada por tu cuenta: muestra el comando y deja que el usuario lo corra o te lo pida explícitamente. Al terminar, actualizar la tabla de §3 y volver a probar las que cambiaron.

## Paso 3: Parámetros (`parametros`)

Mostrar la tabla de `perfil.md` §4 y preguntar solo: "¿Algo distinto para ti? (zona horaria, horario laboral, hora de la rutina, cupo de foco)". Los valores de `organizacion.md` no se tocan: son compartidos y se actualizan reemplazando el archivo.

## Paso 4: Estructura (`estructura`)

1. Crear el **área de rituales** de `perfil.md` §2 si no existe: `2-areas/<slug>/` con `AGENTS.md` desde `3-recursos/plantillas/area.md` (equipo y rituales que dio el usuario), `pendientes.md` (`# Pendientes`), `conflictos.md` (`# Conflictos`) y las carpetas `reuniones/`, `decisiones/`, `chat/`, `refs/`.
2. Agregarla al portafolio de `perfil.md` §6.
3. Para cada reporte directo o par con 1:1 recurrente, ofrecer crear `2-areas/1-a-1s/<persona>/contexto.md` (ver `2-areas/1-a-1s/AGENTS.md`).

## Paso 5: Codex (`codex`)

```bash
bash .agents/sync-skills.sh
```

Explicar en una línea: en Codex las skills se invocan con `$<nombre>`.

## Paso 6: Rutina diaria (`rutina`)

1. Explicar: `/cierre-dia` corre sola a la hora de `perfil.md` §4 con `claude --print` en esta máquina (necesita la máquina encendida y la sesión iniciada). Detalle en `.claude/routines/README.md`.
2. **Requisitos**: la rutina corre con `claude --print`, así que necesita Claude Code instalado aunque el usuario trabaje con Codex, y que haya aceptado el diálogo de confianza de Claude Code en esta carpeta (sin eso, `claude --print` ignora `.claude/settings.json` y rechaza todos los comandos). Si esta sesión es de Claude Code, ya está; si es de Codex, pedirle que abra `claude` una vez en la carpeta del brain.
3. **Pedir confirmación** antes de instalar: escribe fuera del repo (`~/Library/LaunchAgents/` en macOS, `crontab` en Linux).
4. Instalar con la hora del perfil y verificar:
   ```bash
   bash .claude/routines/instalar-rutina.sh <HH:MM>
   ```
5. Ofrecer una prueba inmediata: `bash .claude/routines/cierre-dia.sh` (procesa hoy; tarda unos minutos) y revisar el log que indica el script.

## Paso 7: Git y sync (`git`)

1. **El repo remoto debe ser privado**: `gh repo view --json nameWithOwner,visibility`. Si es `PUBLIC`, detenerse y advertir con claridad: el brain va a contener notas de reuniones, decisiones y temas de personas. Sugerir `gh repo edit --visibility private --accept-visibility-change-consequences` y no seguir hasta que el usuario decida.
2. Si no hay remoto: explicar cómo crearlo privado (`gh repo create <nombre> --private --source . --push`) y esperar confirmación antes de correrlo.
3. **brain-sync**: ofrecer agregar a `~/.zshrc` (pedir confirmación, es un archivo fuera del repo):
   ```bash
   source "<ruta absoluta del brain>/.claude/routines/brain-sync.sh"
   ```
   Uso: `brain-sync "mensaje"` hace commit, pull con rebase y push.
4. Ofrecer el primer commit con la configuración (`git add -A && git commit -m "configurar brain"`), sin hacer push salvo que el usuario lo pida.

## Paso 8: Siguientes pasos

```
✓ Brain configurado:
- Organización: organizacion.md versión <YYYY-MM-DD> | falta (pedírselo a Pablo Troncoso)
- Perfil: <nombre> — <rol>
- Fuentes activas: <lista> · inactivas: <lista>
- Área de rituales: 2-areas/<slug>/
- Codex: <N> adaptadores generados
- Rutina: <L-V HH:MM | no instalada>
- Repo: <owner/repo> (<privado|sin remoto>)

Siguiente:
1. /para-init — propone tus proyectos y áreas desde las últimas 2 semanas.
2. /mapear-chat-spaces — asocia tus spaces de Chat a esos proyectos.
3. /cierre-dia — corre el primero a mano al final del día y revisa el resultado.
```

Ofrecer correr `/para-init` de inmediato.

## Reglas

- **Nunca escribir secretos** (tokens, contraseñas, API keys) en `perfil.md` ni en ningún archivo del repo.
- **Confirmar antes de tocar algo fuera del repo** (`~/.zshrc`, `~/Library/LaunchAgents/`, `crontab`) y antes de cualquier acción en GitHub (crear repo, cambiar visibilidad, push).
- **No instalar software sin que el usuario lo pida**: mostrar el comando.
- **Idempotente**: re-ejecutar es seguro; solo pregunta por lo que falta y muestra lo demás como ✅.
- **Respetar lo que el usuario ya editó** en `perfil.md`: reemplazar solo `COMPLETAR` y los campos que él pida cambiar.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
