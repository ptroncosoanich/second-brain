# Área: 1:1s

**Tipo**: Área (responsabilidad continua, sin deadline)

## Qué cubre

Reuniones 1:1 recurrentes con reportes directos, pares, manager y stakeholders cercanos. Una carpeta por persona.

`/cierre-dia` enruta acá las reuniones de 2 asistentes que son recurrentes, y `/mapear-chat-spaces` los DM con estas personas.

## Convención

```
1-a-1s/
└── <nombre-corto>/          # kebab-case, ej. ana o ana-perez
    ├── contexto.md          # rol, relación (reporte / par / manager), temas recurrentes, acuerdos de trabajo
    ├── reuniones/
    │   └── YYYY-MM-DD.md
    ├── chat/                # síntesis de DMs (si se mapeó el DM)
    ├── decisiones/
    └── pendientes.md        # lo que el usuario tiene que hacer o seguir con esta persona
```

`contexto.md` mínimo:

```markdown
# <Nombre Apellido>

**Rol**: <rol>
**Relación**: <reporte directo | par | manager | stakeholder>
**Email**: <email>
**1:1**: <frecuencia y hora>

## Temas recurrentes

## Acuerdos de trabajo

## Notas
```

## Reglas

- Los compromisos de un **reporte directo** se trackean en su `pendientes.md` (delegación). Los de un **par** no: se acuerdan y quedan en la nota de la reunión, salvo que el usuario esté bloqueado esperándolos.
- Feedback, desempeño y temas personales se registran según el nivel de privacidad de `perfil.md` §5.
- Si un 1:1 es sobre un proyecto específico, la nota va al proyecto y acá solo un link.

## Personas

*(se agregan con `/configurar`, `/para-init` o `/cierre-dia`)*
