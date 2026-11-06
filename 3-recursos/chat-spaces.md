# Índice de spaces de Google Chat

> Caché de entrada para el Paso 6.1 de `/cierre-dia`: evita re-descubrir y re-clasificar los spaces en cada corrida.
>
> **Última actualización**: *(nunca — la llena `/mapear-chat-spaces`)*
>
> Refrescar con `gws chat spaces list` (paginando con `nextPageToken`) si aparecen spaces desconocidos o pasó más de un mes. La columna **Destino** la mantiene `/mapear-chat-spaces`; los mapeos que mandan viven en el `AGENTS.md` de cada proyecto o área.

## Ignorados

- Patrones de "Spaces de Chat que se ignoran" de `organizacion.md` (anuncios, notificaciones, social).
- Spaces efímeros de reunión: Google crea uno por sesión de Meet, con la fecha en el nombre (`... - Sep 3`). Su contenido ya está en las notas de la reunión.

## Spaces activos

| Space | ID | Destino |
|---|---|---|
