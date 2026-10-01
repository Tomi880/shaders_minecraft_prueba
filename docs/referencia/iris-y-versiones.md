# Iris y versiones de Minecraft (investigado el 2026-09-29)

## Soporte de Iris para 26.x

| Minecraft | Versión de Iris (Fabric) | Nota |
|---|---|---|
| 26.1 – 26.1.2 | 1.10.9 y 1.11.3+26.1 | 1.11.3 corrige bugs exclusivos de 26.1; la prueba inicial del pack usa 1.11.4+mc26.1.2 |
| 26.2 | 1.11.0 – 1.11.2+26.2 | 1.11.0: «Vulkan is not supported» |
| 26.3 | 1.11.6+26.3 (15-sep-2026) | Última revisada |

Fuentes:
- https://modrinth.com/mod/iris/version/1.11.3+26.1-fabric
- https://modrinth.com/mod/iris/version/1.11.0+26.2-fabric
- https://modrinth.com/mod/iris/version/1.11.6+26.3-fabric

## Macro `MC_VERSION` para 26.x (verificado el 2026-09-29)

La documentación de Iris define `MC_VERSION` con el formato `122` (major, minor y release), con
ejemplos para versiones 1.x y 1.21. Los valores 26.x de abajo se derivan aplicando ese formato; no
son una tabla de versiones 26.x publicada explícitamente por Iris.

| Minecraft | `MC_VERSION` derivado |
|---|---:|
| 26.1.0 | 260100 |
| 26.1.2 | 260102 |
| 26.2.0 | 260200 |
| 26.3.0 | 260300 |

Fuente oficial: https://shaders.properties/current/reference/macros/mc_version/

## Renderer Vulkan (lo más importante)

- Mojang anunció el 18-feb-2026 que Java Edition pasa de OpenGL a Vulkan.
- **26.2** trae un renderer Vulkan experimental **junto al de OpenGL**, seleccionable en
  Opciones de video.
- **Iris solo funciona con OpenGL**: con Vulkan los shaders se apagan o el juego falla. Para
  probar este pack hay que elegir OpenGL.
- Se espera que OpenGL se elimine más adelante (se habla de fines de 2026 o inicios de 2027),
  con aviso previo de Mojang. **Esto no está confirmado para una versión concreta.**
- El equipo de Iris anunció que Iris se descontinúa y trabaja en un sucesor nativo de Vulkan,
  **Aperture**, escrito desde cero. No hay confirmación de que acepte packs GLSL existentes.
- Puentes de terceros que traducen packs OptiFine/Iris a Vulkan: Vitrail Shaders, Vulcade. No
  son objetivo de este pack.

Fuentes:
- https://minecraft.wiki/w/Java_Edition_26.2-snapshot-1
- https://developers.slashdot.org/story/26/02/19/2156234/minecraft-java-is-switching-from-opengl-to-vulkan
- https://www.akliz.net/blog/posts/what-is-vulkan-minecraft
- https://modrinth.com/mod/vitrail-shaders

## Consecuencias para el pack

1. Objetivo final: Iris sobre OpenGL en 26.1–26.3. La versión activa para desarrollar y probar las fases 0–5 es 26.1.2; 26.2 y 26.3 se validarán una por una después de completar el shader.
2. La guía de instalación debe decir que se elija OpenGL en las Opciones de video (26.2+).
3. `lib/` con GLSL portable, para no reescribir todo si hay que migrar a Aperture.

## Por verificar

- [ ] Si Iris define macros `IRIS_FEATURE_*` cuando se activa un flag de
  `iris.features.optional` (clave para el fallback del modo RT).
- [ ] Versión de Distant Horizons compatible con Iris en 26.x.
