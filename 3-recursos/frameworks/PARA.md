# PARA — Referencia del método

Acrónimo creado por Tiago Forte. Organiza la información por **accionabilidad**, no por tema.

## Los 4 buckets

### 1-proyectos (Projects)

**Definición**: esfuerzos con un **objetivo claro** y un **deadline** (implícito o explícito).

**Ejemplos**: "Lanzamiento del nuevo onboarding", "Migración de la feature X a la nueva arquitectura", "Hiring de PM senior".

**Test**: si puedo decir "esto está terminado cuando ___", es un proyecto.

### 2-areas (Areas of responsibility)

**Definición**: responsabilidad **continua** sin fin definido; hay que sostener un estándar en el tiempo.

**Ejemplos**: el producto o módulo del que eres dueño, los rituales de tu equipo, `1-a-1s`, coaching de PMs, relación con otra área.

**Test**: si nunca termina, es área.

### 3-recursos (Resources)

**Definición**: material de **referencia** transversal: no es accionable por sí solo, pero lo consultas cuando hace falta.

**Ejemplos**: frameworks (PARA, JTBD, RICE, OKRs), plantillas, queries reutilizables, docs de Buk Atlas que usas seguido, ideas para proyectos futuros.

**Test**: si sirve para *muchos* proyectos o áreas, es recurso.

### 4-archivo (Archive)

**Definición**: proyectos **terminados** o áreas que ya no aplican. **No borrar**: son auditables y útiles para retrospectivas.

**Convención**: mover la carpeta completa de `1-proyectos/` a `4-archivo/` cuando un proyecto cierra, con su nombre original, y sacarla del portafolio de `perfil.md`.

## Principios

1. **Accionabilidad sobre tema**: un doc de "estrategia de IA" vive en un proyecto si es accionable ahora, o en recursos si es referencia. Lo decide su rol en tu trabajo, no su tema.
2. **Movilidad**: los archivos cambian de bucket cuando cambia su rol. Una idea (recurso) que se vuelve compromiso (proyecto) cambia de carpeta.
3. **Progressive disclosure**: cada proyecto y área tiene su `AGENTS.md`; el agente carga primero la raíz y después el del proyecto.
4. **Un archivo, un lugar**: no duplicar; enlazar con links markdown.
5. **Mantenimiento mínimo**: si algo no encaja claro, va a `3-recursos/inbox.md` y se clasifica después.

## Lectura adicional

- [Building a Second Brain](https://www.buildingasecondbrain.com/) — Tiago Forte
- [How we built an AI second brain for 60k knowledge workers](https://medium.com/@AnalyticsAtMeta/how-we-built-an-ai-second-brain-for-60k-knowledge-workers-78c507dd795b) — Analytics at Meta
