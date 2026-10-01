# Arquitectura del shaderpack

## Alcance actual: fase 1 (primer bloque de sombras)

La fase 0 se aceptó el 2026-09-29 tras probar v0.1.1 en Minecraft 26.1.2/Iris 1.11.4: el pack cargó,
no hubo errores ni avisos `Invalid pack option`, y el cambio a BSL no reprodujo los errores de
buffers. No se hizo una comparación A/B formal con vanilla. Los perfiles vacíos se retiraron; los
seis perfiles funcionales se agregarán en fase 5 cuando existan opciones reales.

El build v0.2.0 inicia fase 1 con un mapa de sombras direccionales, distorsión de proyección y
recepción PCF/PCSS en terreno. Aún requiere validación en el PC. Las fases 0–5 usan 26.1.2 como única
versión activa; 26.2 y 26.3 se revisarán secuencialmente después de la fase 5. Registra las pruebas
en `docs/pruebas/registro.md`.

Los programas `gbuffers_basic`, `gbuffers_textured` y `gbuffers_textured_lit` cubren las familias
base. Los demás nombres de `gbuffers` usan los fallbacks que documenta Iris, evitando duplicar
shaders equivalentes. Las texturas usan el atlas y el mapa de luz vanilla; `alphaTestRef` conserva
los recortes alfa. Los cristales del End se clasifican en `entity.properties`, porque son entidades,
no bloques.

## Flujo implementado

Iris ejecuta el pipeline en el orden oficial siguiente. En fase 1 el mapa de profundidad se genera
en `shadow` y se consulta por píxel en `gbuffers_terrain`; `shadowcomp` y `deferred` siguen ausentes.

| Orden | Pase | Estado actual | Función actual / prevista |
|---:|---|---|---|
| 1 | `setup` | Ausente | Reservado para preparar recursos de cómputo cuando una fase futura lo requiera. |
| 2 | `begin` | Ausente | Reservado para operaciones previas al dibujo de cada frame. |
| 3 | `shadow` | Implementado en v0.2.0 | Escribe profundidad direccional con distorsión; fase 4 podría añadir voxelización solo con soporte verificado. |
| 4 | `shadowcomp` | Ausente | No hace falta para el PCF/PCSS receptor de este bloque; reservar para procesar `shadowcolor` si una fase futura lo requiere. |
| 5 | `prepare` | Ausente | Fase 4: preparación de recursos temporales/voxelizados, si las capacidades opcionales están disponibles. |
| 6 | `gbuffers` opacos | Parcialmente implementado | `gbuffers_terrain` recibe sombras PCF/PCSS y conserva textura, alpha cutout y lightmap; otros programas mantienen pass-through. |
| 7 | `deferred` | Ausente | Fase 1 posterior: SSAO, SSGI, luz coloreada/emisiva y tonemapping básico. |
| 8 | `gbuffers` translúcidos | Fallback pass-through | Agua, entidades, partículas, nubes y clima conservan la ruta vanilla disponible. |
| 9 | `composite` | Implementado | Copia `colortex0` a `colortex1` sin alterar el color. Fases 1–5 añadirán iluminación restante, atmósfera, agua, RT y post-procesado mediante pases separados. |
| 10 | `final` | Implementado | Copia `colortex1` al backbuffer; será la salida de pantalla de la cadena futura. |

### Flujo de buffers actual

```text
shadow           --profundidad--> shadowtex0 / shadowtex1
gbuffers_terrain --lee shadowtex1; escribe--> colortex0
gbuffers_*       --escribe--> colortex0
composite        --lee 0 / escribe 1--> colortex1
final            --lee 1--> backbuffer
```

El filtro manual usa `shadowtex1` con `shadowHardwareFiltering=false` para comparar profundidades
crudas. El atlas `gtexture` no está disponible en `shadow`, por lo que en este primer bloque los
recortes alfa conservan su apariencia en pantalla, pero pueden proyectar siluetas opacas. `water`
y `block_translucent` tienen pass-through explícito para no recibir sombra opaca. `RENDERTARGETS`
mantiene `colortex0` como salida de escena y `colortex1` como copia para `final`; no se configura
flipping ni se lee `colortex0` desde gbuffers.

## Plan de evolución por fases

| Fase | Pases principales | Resultado previsto |
|---|---|---|
| 0. Esqueleto | `gbuffers_*`, `composite`, `final` | Fase cerrada en 26.1.2; menú traducido sin perfiles vacíos. Los perfiles válidos se implementan en fase 5. |
| 1. Base, iluminación y sombras | `shadow`, `gbuffers_terrain`, después `deferred` | En curso: mapa direccional, distorsión y PCF/PCSS en terreno. Quedan iluminación solar/lunar completa, emisores por ID, SSAO/SSGI y tonemapping básico. |
| 2. Cielo, nubes, niebla y clima | `gbuffers_sky*`, `gbuffers_clouds`, `gbuffers_weather`, `composite*`, `final` | Dispersión Rayleigh/Mie, nubes 2D/3D, estrellas, halo lunar, niebla volumétrica, god rays, lluvia y tormenta. |
| 3. Agua y dimensiones | `gbuffers_water`, `gbuffers_hand_water`, `composite*`, `final` | Olas, refracción, absorción, espuma, SSR y paletas de Nether/End; bajo el agua usa absorción teal. |
| 4. Ray Tracing | `setup`, `shadow`, `prepare`, compute y `composite*` | Voxelización, DDA, GI, sombras puntuales/reflejos/AO y denoiser con fallback clásico. Se implementa solo después de verificar las macros y flags pendientes de Iris. |
| 5. Post-procesado, menú y presets | `composite*`, `final`, `shaders.properties` | Exposición, bloom, TAA/TAAU, DoF, motion blur, viñeta, corrección de color y seis presets medibles. |
| 6. Compatibilidad posterior | Validación y adaptaciones por versión | Tras completar las fases 0–5 en 26.1.2, comprobar 26.2 y 26.3 secuencialmente, sin abrir una segunda línea de desarrollo en paralelo. |

El orden concreto de las pasadas numeradas (`composite1`, `composite2`, etc.) se fijará cuando se
implemente cada fase, manteniendo el orden oficial del pipeline y sin leer/escribir el mismo destino
en una pasada. Cualquier uso de `flip.<program>.<buffer>` se añadirá junto al pase que lo necesite y
se verificará contra la documentación de Iris.

## Reparto previsto de `colortex`

Solo `colortex0` y `colortex1` se usan en fase 0. Los destinos de fases posteriores quedan reservados
con estas funciones para evitar reutilizaciones incompatibles:

| Buffer | Uso de fase 0 | Uso previsto desde fase 1 |
|---|---|---|
| `colortex0` | Color de escena producido por `gbuffers`. | Color/albedo de entrada del G-buffer. |
| `colortex1` | Copia temporal de escena que consume `final`. | Coordenadas/valores del lightmap para la iluminación diferida. |
| `colortex2` | Sin uso. | Normal codificada para sombras, SSAO, SSR y RT. |
| `colortex3` | Sin uso. | Datos de material y máscara emisiva. |
| `colortex4` | Sin uso. | Resultado de iluminación diferida / color de trabajo. |
| `colortex5` | Sin uso. | Buffer de trabajo alterno para niebla, nubes y composición. |
| `colortex6` | Sin uso. | Datos o resultado de reflejos/agua. |
| `colortex7` | Sin uso. | Historial temporal para TAA y acumulación, sujeto a validar persistencia y flipping. |
| `colortex8` | Sin uso. | Datos auxiliares del denoiser temporal de RT. |
| `colortex9`–`colortex15` | Sin uso. | Reservados; no se asignan hasta que una fase justifique su coste. |

La tabla define roles lógicos, no declara todavía formatos de imagen, tamaños ni flags de Iris. Esos
valores se documentarán y validarán cuando se creen los pases que los consumen. La voxelización del
modo RT usará recursos específicos opcionales (custom images/SSBO) y no se cuenta como un `colortex`
adicional.

## Parámetros visuales previstos en las referencias

Los nombres de esta tabla describen controles internos para fases futuras; no son opciones ni
`#define` de fase 0. Cuando se expongan al menú se declararán en el shader y en ambos `.lang`, con
tooltip de impacto en rendimiento.

| Rasgo | Controles que lo gobiernan | Referencias |
|---|---|---|
| Sombras direccionales | `shadowMapResolution` determina detalle y coste de memoria; `shadowDistance` cubre más mundo a menor detalle por texel; `SHADOW_DISTORTION` concentra resolución hacia el centro; `SHADOW_FILTER_MODE` elige PCF fijo o PCSS; `SHADOW_QUALITY` escala de 4 a 16 muestras; `SHADOW_PENUMBRA` controla la suavidad PCSS y `SHADOW_STRENGTH` la oscuridad sobre luz celeste. | 5, 6, 8 |
| Color de niebla | Color de dispersión Rayleigh/Mie y mezcla por hora, clima, bioma y dimensión. El matiz sale de esa mezcla: rojo/magenta al atardecer lluvioso, naranja en Nether, púrpura/gris en End, azul de noche y teal bajo el agua. | 1, 2, 4, 5, 9, 10 |
| Densidad y alcance de niebla | Densidad base, altura/capa, caída con distancia y aporte de lluvia; el modo submarino suma coeficientes de absorción por canal. | 1, 2, 4, 5, 7, 9, 10 |
| Forma de nubes | Cobertura determina cuánto cielo ocupan; escala/frecuencia fija tamaño; perfil vertical/espesor da volumen a los cúmulos; erosión/detalle controla bordes; viento desplaza la forma; iluminación/scattering crea sombreado suave y silver lining. | 1, 3, 4, 5, 7 |
| Luz de fuentes | Familia de emisor (IDs de `block.properties` o `entity.properties`), color/intensidad y radio/atenuación espacial. Los IDs no son niveles de luz ni activan iluminación en esta fase. | 1, 2, 4, 5, 8 |
| Lluvia y tormenta | Intensidad de lluvia para desaturación y densidad de bruma; intensidad/posición de relámpago para destellos en cielo y niebla. | 1, 9 |
| Agua | Absorción RGB dependiente de profundidad, refracción, normales de olas, espuma de borde y peso de reflejo. | 8, 10 |

Las escenas 1–10 están en `docs/spec/referencias-visuales/`; la fase 0 se compara con la 8 como
referencia de día despejado y, sobre todo, con el render vanilla sin cambios de color ni geometría.
