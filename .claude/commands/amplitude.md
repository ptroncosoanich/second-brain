---
description: Atajo para consultar Amplitude vía BigQuery — eventos, sesiones y uso de módulos de producto
argument-hint: <pregunta sobre eventos, sesiones o uso de un módulo>
category: sync
---

# /amplitude — Métricas de producto en BigQuery

Tu rol: variante de `/datos` enfocada en el dataset de Amplitude. Asume que la pregunta es sobre eventos de producto, sesiones, conversiones o uso de módulos.

No usa la API de Amplitude: los datos viven en BigQuery (`<PROYECTO>.<DATASET>.*`), la fuente oficial dentro de Buk.

> Lee `perfil.md`: si BigQuery está `inactiva` (§3), avisar y terminar. `<PROYECTO>` es el proyecto de BigQuery de `organizacion.md`.

## Input

`$ARGUMENTS`: "eventos de la feature X el último mes", "sesiones promedio por usuario en abril por país", "top eventos del módulo Y por tenant".

## Tablas

El dataset de Amplitude y su catálogo de tablas están en `organizacion.md` (sección "Catálogo de datos"; abajo, `<DATASET>`). Confirmar nombres y schema antes de usar:

```bash
bq ls <PROYECTO>:<DATASET>
bq show --schema --format=prettyjson <PROYECTO>:<DATASET>.<tabla>
```

Si `organizacion.md` no trae el catálogo, listar las tablas con `bq ls` y preguntar cuál usar.

## Proceso

### Paso 1: Dimensión y métrica

- **Dimensión**: tenant, país, día, evento, usuario.
- **Métrica**: eventos, sesiones únicas, usuarios únicos, conversiones.

### Paso 2: Filtros

- **Período**: confirmar si es vago.
- **Módulo o feature**: `event_type LIKE '<prefijo>_%'` o el nombre del evento.
- **Tenant**: si se menciona.

### Paso 3: SQL

```sql
SELECT
  <dimensión>,
  COUNT(*) AS eventos,
  COUNT(DISTINCT user_id) AS usuarios_unicos
FROM `<PROYECTO>.<DATASET>.<tabla de eventos>`
WHERE event_time BETWEEN '<inicio>' AND '<fin>'
  AND <filtros>
GROUP BY 1
ORDER BY eventos DESC
LIMIT 50
```

Adaptar las columnas a las que existan (`bq show --schema`).

### Paso 4: Confirmar y ejecutar

Igual que `/datos`: mostrar el SQL, pedir confirmación, `--dry_run` si es pesada, ejecutar.

### Paso 5: Presentar

Top 10 y total. Ofrecer exportar a CSV, guardar la query en `3-recursos/queries/amplitude-<slug>.sql` o un corte adicional.

## Reglas

- **No inventar columnas.**
- **Nunca `SELECT *` sin `LIMIT`** sobre la tabla de eventos (es grande).
- **Siempre `WHERE event_time BETWEEN ...`**: las tablas están particionadas por tiempo.
- Errores de permisos → dónde pedir acceso según `organizacion.md`.
- Confirmar antes de ejecutar.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
