# Plan por fases

Cada fase deja el pack **compilando y funcional**, y se cierra solo cuando pasa su prueba en el
PC (registrada en `docs/pruebas/registro.md`). Al cerrar cada fase, actualiza
`docs/arquitectura.md`.

## Secuencia de versiones

El objetivo final sigue siendo Minecraft 26.1–26.3. Para no mantener dos versiones en paralelo,
las fases 0–5 se desarrollan y prueban sobre Minecraft 26.1.2. Solo después de cerrar la fase 5
se abre la fase 6 de compatibilidad, probando primero 26.2 y luego 26.3, una versión a la vez.
Esta secuencia no reduce el objetivo final de compatibilidad.

| Fase | Alcance | Se cierra cuando… |
|---|---|---|
| 0. Esqueleto | Menú traducido, `gbuffers_*` pass-through, `composite` y `final` simples, bibliotecas base e IDs de fuentes de luz. No se declaran perfiles vacíos; los seis presets funcionales se completarán en fase 5. | **Cerrada el 2026-09-29** con la prueba v0.1.1 en Minecraft 26.1.2: el pack carga, el log no contiene errores ni avisos `Invalid pack option`, y el cambio a BSL no reproduce los errores de buffers. El usuario acepta avanzar; se deja constancia de que no hubo una comparación A/B formal con vanilla. |
| 1. Base + iluminación + sombras | Luz solar/lunar, luz de bloques por color, shadow mapping con distorsión, PCF/VPS, SSAO, emisivos, tonemapping básico | En curso: el primer bloque implementa sombras direccionales PCF/PCSS sobre terreno en v0.2.0. Cerrar la fase después de probar la referencia 8, validar dirección/penumbra y corregir acne o peter-panning; completar después las funciones restantes de iluminación. |
| 2. Cielo, nubes, niebla y clima | Rayleigh + Mie, nubes 2D y 3D, estrellas, luna con halo, niebla volumétrica con god rays, lluvia y tormenta | Referencias 1, 3, 5, 7 y 9 comparables |
| 3. Agua y dimensiones | Olas, SSR, refracción, absorción, espuma, bajo el agua; Nether y End | Referencias 2, 4 y 10 comparables |
| 4. Ray Tracing | Voxelización en shadow pass, DDA, GI, sombras puntuales, reflejos, AO, acumulación + denoiser, fallback por `iris.features.optional` | Very High corre en la RTX 5060; al quitar el soporte el pack cae al modo clásico sin crashear |
| 5. Post-procesado, menú y presets | Exposición automática, bloom, TAA/TAAU, DoF, motion blur, viñeta, corrección de color, menú completo, 6 presets, tooltips con impacto | Cambiar de preset se nota en FPS y calidad; tabla de rendimiento medida |
| 6. Compatibilidad posterior | Adaptaciones que requieran las versiones restantes del objetivo final | Solo después de cerrar fase 5, validar y adaptar Minecraft 26.2 y luego 26.3, de forma secuencial y sin mantener dos versiones activas a la vez. |

> La comparación diferencial confirmó que las seis declaraciones `profile.* =` vacías de v0.1.0
> causaban los avisos `Invalid pack option:` en Iris 1.11.4. No vuelvas a declarar perfiles vacíos;
> agrega los seis perfiles con listas reales de opciones en la fase 5.

## Antes de empezar la fase 4

Resolver los pendientes de `docs/referencia/iris-y-versiones.md` (macros de features, fallback).
