# Trampas de Iris y de drivers

Lo aprendido probando que no está en la documentación. Formato: fecha, versión del pack,
síntoma, causa y solución.

## Trampas confirmadas

- **2026-09-29 — v0.1.0/v0.1.1, Minecraft 26.1.2, Iris 1.11.4.** Síntoma: v0.1.0 emitía seis
  avisos `Invalid pack option:` al cargar el pack; v0.1.1, que solo retiró las seis líneas
  `profile.* =` vacías, emitió cero. Causa confirmada diferencialmente: Iris interpreta esas
  declaraciones vacías como opciones de perfil inválidas. Solución: no declarar perfiles sin
  opciones; añadir los seis perfiles con listas reales al implementar presets en fase 5.

## Observaciones no confirmadas

- En el log v0.1.0 hubo siete `Deleting stream buffers: Invalid operation.` al cambiar de shader;
  no reaparecieron en v0.1.1 al cambiar a BSL. Sin reproducción ni atribución, no se asigna una
  causa a Iris, al driver ni a este shaderpack.
