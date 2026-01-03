---
name: clean-ui
description: Limpia y divide código UI sucio en Widgets reutilizables
tools: [ 'edit' ]
argument-hint: Selecciona el código sucio antes de ejecutar
---
Actúa como un experto en UI/UX Flutter y Material 3.
Refactoriza el código seleccionado en `${selection}`.

Tu tarea:
1. Atomizar: Divide el código en widgets pequeños en `lib/ui/home/widgets/` (ej: `TaskTile`, `HomeAppBar`).
2. Theming: Usa `Theme.of(context)` en lugar de colores fijos.
3. Lógica Visual:
   - En `TaskTile`: Si `due_date` pasó y no está completa, muestra la fecha en color de error.
   - Si está completa, usa estilo tachado (line-through).
4. Conexión: Los Checkbox deben llamar a los métodos de `TaskProvider` y NO usar `setState` local.