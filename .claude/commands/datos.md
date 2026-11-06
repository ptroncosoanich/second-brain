---
description: Consulta el data warehouse (BigQuery) traduciendo una pregunta natural a SQL; muestra el resultado y opcionalmente guarda la query en 3-recursos/queries/
argument-hint: <pregunta o consulta en lenguaje natural>
category: sync
---

# /datos — Consulta al data warehouse

Tu rol: traducir una pregunta sobre datos a SQL para BigQuery, confirmar con el usuario antes de ejecutar, mostrar el resultado y, si sirve, guardar la query.

> Lee `perfil.md`: si la fuente BigQuery está `inactiva` (§3), avisar y terminar. El proyecto (`<PROYECTO>` abajo), el canal para pedir acceso y el catálogo de datasets están en `organizacion.md`. Si existe el plugin `buk-skills:bigquery`, úsalo como referencia de datasets, tablas y convenciones.

## Input

`$ARGUMENTS`: pregunta en lenguaje natural ("¿cuántos usuarios activos tuvo el módulo X en abril?", "eventos de la feature Y el último mes por tenant") o SQL directo (si empieza con `SELECT` o `WITH`, ejecutarlo tal cual tras confirmar).

## Proceso

### Paso 1: Clarificar si es vago

Si no queda claro el módulo, el período o la granularidad (tenant, país, usuario, evento), **preguntar antes de inventar SQL**. Si la pregunta es claramente de eventos o sesiones de producto, usar `/amplitude`.

### Paso 2: Identificar dataset y tabla

- Partir del **catálogo de datos** de `organizacion.md` (dataset y para qué sirve). Eventos, sesiones o Amplitude → el dataset de Amplitude (ver `/amplitude`).
- Si el catálogo no cubre la pregunta o es dudoso, listar opciones y preguntar:
  ```bash
  bq ls <PROYECTO>:
  bq ls <PROYECTO>:<dataset>
  bq show --schema --format=prettyjson <PROYECTO>:<dataset>.<tabla>
  ```

### Paso 3: Construir el SQL

- `--use_legacy_sql=false` y `--project_id=<PROYECTO>` siempre.
- Referencias completas con backticks: `` `<PROYECTO>.dataset.tabla` ``.
- `LIMIT` en exploraciones (default 50).
- `WHERE` con fechas explícitas.
- No inventar columnas: verificar con `bq show --schema` si hay duda.

### Paso 4: Confirmar antes de ejecutar

```
Voy a ejecutar:

SELECT ...
FROM `<PROYECTO>.<dataset>.<tabla>`
WHERE <fecha> BETWEEN '2026-04-01' AND '2026-04-30'
GROUP BY ...
LIMIT 50

¿Procedo? (sí / no / ajusta)
```

Para queries pesadas, correr antes `--dry_run` y mostrar los bytes estimados. Advertir si pasa de 1 GB o si no hay filtro temporal sobre una tabla grande.

### Paso 5: Ejecutar

```bash
bq query --use_legacy_sql=false --project_id=<PROYECTO> --format=prettyjson '<SQL>'
```

Para resultados grandes, ofrecer `--format=csv` hacia `3-recursos/queries/output/<slug>-<fecha>.csv`.

### Paso 6: Presentar

- Tabla markdown de hasta 10 filas, con el total.
- 1-2 hallazgos factuales, sin especular.
- Ofrecer cortes adicionales o exportar a CSV.

### Paso 7: Guardar la query (opcional)

Si el usuario lo pide o el SQL es reutilizable, `3-recursos/queries/<slug-descriptivo>.sql`:

```sql
-- <Descripción en una línea>
-- Creada: YYYY-MM-DD vía /datos
-- Pregunta original: "<pregunta>"

SELECT ...
```

## Reglas

- **NUNCA** ejecutar SQL sin mostrarlo y confirmar (salvo que el usuario diga "ejecuta directo").
- **Errores de permisos**: indicar dónde pedir acceso según `organizacion.md`.
- **Costo**: `--dry_run` para queries pesadas; nunca sin `WHERE` sobre tablas grandes.
- **No interpretar de más**: números factuales; las conclusiones las saca el usuario.
- Slug único en `3-recursos/queries/`: si existe, preguntar antes de sobrescribir.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
