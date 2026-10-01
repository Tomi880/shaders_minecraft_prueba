# Formato del shaderpack de Iris: índice y datos clave

Documentación oficial: https://shaders.properties/ (repo: https://github.com/IrisShaders/DocsPage).
Antes de usar una directiva, uniform o feature, abre la página correspondiente.

## Páginas de referencia

| Tema | URL |
|---|---|
| Programas (orden y tipos) | https://shaders.properties/current/reference/programs/overview/ |
| gbuffers | https://shaders.properties/current/reference/programs/gbuffers/ |
| shadow / shadowcomp | https://shaders.properties/current/reference/programs/shadow/ |
| deferred / composite / final | https://shaders.properties/current/reference/programs/composite/ |
| setup / begin / prepare | https://shaders.properties/current/reference/programs/setup/ |
| Uniforms | https://shaders.properties/current/reference/uniforms/overview/ |
| Atributos (mc_Entity, at_tangent…) | https://shaders.properties/current/reference/attributes/overview/ |
| Buffers (colortex, depthtex, shadowtex, noisetex) | https://shaders.properties/current/reference/buffers/overview/ |
| Custom images | https://shaders.properties/current/reference/buffers/custom_images/ |
| SSBO | https://shaders.properties/current/reference/buffers/ssbo/ |
| shaders.properties (screen, sliders, profile, features, uniforms) | https://shaders.properties/current/reference/shadersproperties/overview/ |
| Constantes (RENDERTARGETS, shadowMapResolution…) | https://shaders.properties/current/reference/constants/overview/ |
| Macros (IS_IRIS, MC_VERSION, render stages…) | https://shaders.properties/current/reference/macros/overview/ |
| block.properties | https://shaders.properties/current/reference/miscellaneous/block_properties/ |
| entity.properties | https://shaders.properties/current/reference/miscellaneous/entity_properties/ |
| item.properties | https://shaders.properties/current/reference/miscellaneous/item_properties/ |
| dimension.properties | https://shaders.properties/current/reference/miscellaneous/dimension_properties/ |
| Distant Horizons | https://shaders.properties/current/reference/mod-support/distant_horizons/ |
| LabPBR (normal/specular) | https://shaderlabs.org/wiki/LabPBR_Material_Standard |

## Orden del pipeline

setup (solo compute, una vez al cargar o redimensionar) → begin → shadow → shadowcomp → prepare →
gbuffers opacos → deferred → gbuffers translúcidos → composite → final.

- Estilo composite (begin, shadowcomp, prepare, deferred, composite): programa base + sufijos
  1–99.
- Solo los programas estilo gbuffers acceden a la geometría (atributos) y admiten teselación.
- Extensiones: `.vsh` vertex, `.fsh` fragment, `.gsh` geometry, `.tcs`/`.tes` teselación,
  `.csh` compute.

## Contrato usado por el esqueleto de fase 0

- La guía oficial de gbuffers documenta el atlas `gtexture`, el mapa `lightmap`, las coordenadas
  `gl_TextureMatrix[0/1]`, el tinte `gl_Color` y el umbral `alphaTestRef`. El esqueleto usa solo
  estos valores para conservar texturas, tintes, luz y recortes alfa vanilla:
  https://shaders.properties/current/guides/your-first-shaderpack/2_gbuffers/
  https://shaders.properties/current/reference/uniforms/overview/
- La tabla oficial de fallbacks de gbuffers permite mantener los tres programas base
  `gbuffers_basic`, `gbuffers_textured` y `gbuffers_textured_lit` sin duplicar todos los programas
  equivalentes:
  https://shaders.properties/current/reference/programs/gbuffers/
- `RENDERTARGETS` asigna las salidas de fragmento a color buffers; la fase 0 lee `colortex0`, escribe
  la copia en `colortex1` desde `composite` y la envía al backbuffer desde `final`:
  https://shaders.properties/current/reference/constants/rendertargets/
  https://shaders.properties/current/reference/buffers/colortex/
- `block.properties` acepta IDs signed 16-bit para bloques y block entities; `entity.properties`
  usa IDs unsigned 16-bit para entidades. Por eso el cristal del End se clasifica en
  `entity.properties`, separado de las fuentes de luz de bloque:
  https://shaders.properties/current/reference/miscellaneous/block_properties/
  https://shaders.properties/current/reference/miscellaneous/entity_properties/

## Sombras direccionales de fase 1

- `shadow.vsh` y `shadow.fsh` dibujan la geometría desde la cámara del sol o la luna; el shadow pass
  escribe profundidad automáticamente. El primer bloque aplica la misma distorsión a la posición
  del caster y a la coordenada del receptor:
  https://shaders.properties/current/reference/programs/shadow/
  https://shaders.properties/current/reference/uniforms/matrices/
- `shadowLightPosition` entrega la dirección del cuerpo celeste más alto en view space. El receptor
  transforma la posición con `gbufferModelViewInverse`, `shadowModelView` y `shadowProjection`:
  https://shaders.properties/current/reference/uniforms/world/
  https://shaders.properties/current/how-to/coordinate_spaces/
- `shadowtex1` excluye geometría transparente y contiene profundidad cruda si
  `shadowHardwareFiltering=false`; PCF/PCSS la comparan manualmente. `shadowMapResolution` y
  `shadowDistance` se exponen como constantes de opción documentadas:
  https://shaders.properties/current/reference/buffers/shadowtex/
  https://shaders.properties/current/reference/constants/shadowhardwarefiltering/
  https://shaders.properties/current/reference/constants/shadowmapresolution/
  https://shaders.properties/current/reference/constants/shadowdistance/
- `gtexture` solo está bound en gbuffers. Por ahora `shadow.fsh` no puede conservar el alpha del
  atlas: las superficies recortadas pueden proyectar sombras opacas hasta que se valide una textura
  auxiliar para el pase shadow:
  https://shaders.properties/current/reference/buffers/atlases/
- `mc_Entity` solo está disponible en `gbuffers_terrain.vsh`, `gbuffers_water.vsh` y `shadow.vsh`;
  su componente `.x` es el ID configurado en `block.properties`. No usarlo como ID de block entity:
  https://shaders.properties/current/reference/attributes/mc_entity/
- Las opciones del menú usan `#define` o constantes con listas de valores; las opciones numéricas
  incluidas en `sliders` aparecen como controles deslizantes. No declarar perfiles vacíos:
  https://shaders.properties/current/reference/shadersproperties/shader_settings/

## Features de Iris (modo Ray Tracing)

- Se declaran en `shaders.properties`: `iris.features.required` (sin ellas el pack no carga) o
  `iris.features.optional` (se activan si hay soporte). Flags vistos en la doc: `CUSTOM_IMAGES`,
  `COMPUTE_SHADERS`, `SSBO`, `REVERSED_CULLING`. Revisa la lista completa en la página de
  shaders.properties.
- Para el fallback sin crasheos, el modo RT debe usar **optional**, nunca required.
- Custom images: `image.<nombre> = <sampler> <format> <internalFormat> <pixelType> <limpiarCadaFrame> <relativa> <x> <y> [<z>]`.
  Máximo 16. En GLSL: `layout(rgba8) uniform image2D nombre;` con `imageLoad`/`imageStore`,
  o el sampler para lectura filtrada. Requieren OpenGL 4.2+.
- Imágenes 3D (con Z) sirven para voxelizar la escena en el shadow pass.

## Distant Horizons

Programas `dh_terrain`, `dh_water` y `dh_shadow`; uniforms `dhNearPlane`, `dhFarPlane`,
`dhRenderDistance`, `dhProjection`; texturas `dhDepthTex0/1`; macro `DISTANT_HORIZONS` cuando DH
está activo; materiales vía `dhMaterialId` (`DH_BLOCK_LEAVES`, `DH_BLOCK_WATER`…).
