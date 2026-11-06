# Organización

> **Valores que comparte todo el equipo**: IDs y nombres internos que necesitan las skills (Jira, GitHub, BigQuery, Buk Atlas, Google Chat). No van en el repo público.
>
> - **Si eres de Buk**: pídele a Pablo Troncoso el archivo `organizacion.md` ya completo y déjalo en la raíz de la carpeta donde clonaste el repo, junto a `perfil.md`. Con eso `/configurar` no te pregunta nada de esta parte.
> - **Si no**: copia este archivo como `organizacion.md` y reemplaza cada `COMPLETAR`.
>
> `organizacion.md` está en `.gitignore`, así que no se sube a ningún repo. Si alguien actualiza el archivo compartido, basta con reemplazar tu copia.

**Versión**: COMPLETAR (fecha de la última actualización, `YYYY-MM-DD`)

## Parámetros

| Parámetro | Valor |
|---|---|
| Jira | COMPLETAR (URL base, ej. `https://<empresa>.atlassian.net`) |
| Organización de GitHub | COMPLETAR (ej. `<org>`) |
| Repo por defecto para `/pr <número>` | COMPLETAR (ej. `<org>/<repo>`) |
| Proyecto de BigQuery | COMPLETAR |
| Dónde pedir acceso a datos | COMPLETAR (space de Chat, canal o persona) |
| Buk Atlas (ID del Shared Drive) | COMPLETAR |
| Spaces de Chat que se ignoran (patrones) | `random*`, `notif*`, `anuncios*` *(agrega los de tu organización)* |

## Catálogo de datos

Lo usan `/datos` y `/amplitude` para elegir dónde consultar.

### Datasets

| Dataset | Cuándo usarlo |
|---|---|
| COMPLETAR | Eventos, sesiones y uso de producto (Amplitude) |
| COMPLETAR | *(otros datasets frecuentes y para qué sirven)* |

### Tablas del dataset de Amplitude

| Tabla | Descripción |
|---|---|
| COMPLETAR | *(una fila por tabla; `bq ls <proyecto>:<dataset>` las lista)* |
