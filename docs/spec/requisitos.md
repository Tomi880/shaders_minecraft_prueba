# Requisitos del shaderpack

Fuente de verdad del *qué* (el *cómo* por fases está en `docs/plan/fases.md`). Estética
inspirada en Chocapic13 (https://www.curseforge.com/minecraft/shaders/chocapic13-shaders):
iluminación cálida y cinematográfica, niebla atmosférica densa, nubes volumétricas suaves, cielos
con fuerte dispersión de color al amanecer y atardecer, y una ambientación muy «moody». Se
replica el resultado visual con implementación propia; su licencia restringe redistribuir
versiones modificadas.

## Objetivos

1. Reproducir el look de las 10 referencias en todas las dimensiones y climas.
2. Menú de configuración completo con 6 presets: Very Low, Low, Medium, High, Very High y
   Extreme.
3. Dos modos de iluminación: clásico (rasterizado, estilo Chocapic) y Ray Tracing por software,
   activo por defecto desde Very High.
4. Escalar desde iGPU / GPUs antiguas hasta gama alta.
5. Funcionar en Iris, compatible con Sodium, Lithium y mods de optimización similares.

## 1. Referencias visuales

Imágenes en `docs/spec/referencias-visuales/` (ver su README para los nombres).

| # | Escena | Qué debe capturar |
|---|---|---|
| 1 | Aldea bajo lluvia al atardecer | Niebla densa teñida de rojo/magenta por el sol bajo, nubes rojizas difusas, visibilidad reducida, luz cálida de antorchas atravesando la niebla, estelas de lluvia visibles |
| 2 | Nether | Niebla volumétrica naranja muy densa, lava como fuente emisiva intensa que ilumina la niebla desde abajo, columnas de lava con bloom, gradiente de profundidad marcado |
| 3 | Atardecer despejado | Cúmulos volumétricos iluminados en naranja intenso por abajo (scattering), cielo que pasa a azul oscuro con estrellas, terreno casi en silueta, horizonte con resplandor púrpura |
| 4 | The End | Niebla púrpura/grisácea, cielo con nubes turbulentas, cristales del End como luz puntual cálida, pilares de obsidiana en silueta, ojos de Enderman emisivos |
| 5 | Noche despejada | Cielo azul marino con estrellas nítidas, luna con halo y nubes iluminadas por la luna, niebla baja azulada, fuerte contraste con la luz cálida (≈2700K) de antorchas |
| 6 | Tabla de calidad | Base para los presets (sección 3) |
| 7 | Día con neblina | Nubes volumétricas blancas con sombreado suave, bruma a distancia (aerial perspective), sombras suaves, niebla ligera junto al agua |
| 8 | Día despejado | Sombras nítidas y direccionales, colores saturados pero naturales, agua con reflejos y transparencia, hierba y hojas con waving, iluminación indirecta suave |
| 9 | Lluvia de día | Cielo gris uniforme, niebla gris densa, desaturación general, superficies mojadas, lluvia con partículas refractivas |
| 10 | Bajo el agua | Niebla teal con absorción exponencial, sol como disco brillante desde abajo, god rays submarinos, kelp en silueta, cáusticas en el fondo |

## 2. Características técnicas

### Iluminación y sombras

- Shadow mapping con distorsión y filtrado PCF/VPS (Variable Penumbra Shadows), con penumbra
  según distancia al oclusor.
- Screen-space shadows opcionales para detalle de contacto.
- SSAO y SSGI con calidad configurable.
- Luz de bloques con color por tipo de fuente (antorcha cálida, lava naranja, alma azul, cristal
  del End, etc.) vía `block.properties`.
- Materiales emisivos con bloom.

### Ray Tracing (modo opcional)

- Sin RT por hardware en OpenGL: ray tracing por software voxelizando la escena en el shadow pass
  (custom images / SSBOs de Iris) y trazando con DDA.
- Funciones: GI de uno o más rebotes, sombras de luces puntuales (antorchas), reflejos trazados
  con fallback a SSR, AO trazado.
- Acumulación temporal + denoiser espacial (SVGF simplificado o à-trous).
- Opciones: rebotes, rayos por píxel, radio de voxelización, calidad del denoiser.
- Si la GPU o el driver no soportan los requisitos: desactivación automática con fallback al
  modo clásico, sin crasheos.

### Cielo y atmósfera

- Cielo físico (Rayleigh + Mie) con transiciones suaves día / atardecer / noche.
- Nubes 2D (bajo rendimiento) y 3D por raymarching (calidad), con scattering direccional y
  «silver lining».
- Estrellas procedurales, luna con halo, respetando las texturas vanilla de sol y luna.
- Niebla volumétrica con god rays (sol y luna), con densidad y color según bioma, clima, hora y
  dimensión.

### Clima

- Lluvia: niebla más densa, desaturación, superficies mojadas con reflejos (charcos opcionales),
  partículas de lluvia refractivas.
- Tormenta: los rayos iluminan nubes y niebla.

### Agua

- Olas procedurales con normales animadas, SSR, refracción, absorción por profundidad, espuma en
  bordes.
- Bajo el agua: niebla teal, cáusticas, god rays, distorsión suave.

### Dimensiones

- Nether: niebla densa naranja, sin sombras solares, iluminación dominada por lava.
- End: cielo turbulento púrpura, niebla, iluminación tenue fría con acentos cálidos.

### Post-procesado

Tonemapping filmic/ACES configurable, exposición automática, bloom, TAA nativo y TAAU
(upscaling), profundidad de campo opcional, motion blur opcional, viñeta, aberración cromática
sutil opcional, corrección de color (saturación, contraste, temperatura).

### Animaciones

Waving de hierba, hojas, flores, cultivos y vides, configurable por tipo.

## 3. Presets

| Opción | Very Low | Low | Medium | High | Very High | Extreme |
|---|---|---|---|---|---|---|
| Nubes | 2D | Low | Low | High | High | High |
| Niebla volumétrica | Off (niebla simple) | Low | Medium | High | High | High |
| Filtrado de sombras | Hard | Low | VPS Low | VPS Medium | VPS Medium | VPS High |
| Calidad de sombras | Very Low (1024) | Low (1536) | Low (2048) | Medium (3072) | High (4096) | High (4096+) |
| SSGI | Off | Off | Off | Low | Off (lo reemplaza RT) | High (si RT off) |
| Screen-space shadows | Off | Off | Off | Off | Off | On |
| Translucidez | Low | Low | High | High | High | High |
| Calidad del agua | Very Low | Low | Medium | High | Ultra | Extreme |
| Calidad de imagen | TAAU 0.6x | TAAU 0.7x | TAAU 0.7x | TAAU 0.7x | TAA nativo | TAA nativo |
| Ray Tracing | Off | Off | Off | Off | On (1 rebote, 1 rpp) | On (2 rebotes, 2 rpp) |
| Reflejos | Sky only | Sky only | SSR Low | SSR | RT + fallback SSR | RT |

- Cada opción se puede modificar individualmente después de elegir un preset (`profile.*` en
  `shaders.properties`).
- Rendimiento orientativo a 1080p: Very Low ≥60 FPS en iGPU moderna; Medium ≥60 FPS en
  GTX 1060 / RX 580; Very High ≥60 FPS en RTX 3060 / RX 6600; Extreme para RTX 4070 o superior.
- Equipo de pruebas real: RTX 5060 8 GB + i5-13450HX. Anota los FPS medidos por preset en
  `docs/pruebas/registro.md`.

## 4. Menú de configuración

- Pantallas: Presets / Iluminación / Ray Tracing / Sombras / Cielo y Nubes / Niebla y Atmósfera /
  Agua / Clima / Dimensiones / Post-procesado / Animaciones / Colores / Debug.
- Sliders con rangos razonables y valores por defecto sensatos.
- Traducciones completas en `lang/es_es.lang` y `lang/en_us.lang`, con tooltips que indiquen el
  impacto en rendimiento (bajo/medio/alto).

## 5. Compatibilidad

- Iris para Minecraft Java 26.1, 26.2 y 26.3, sobre el renderer OpenGL. Requisitos declarados
  con `iris.features.required` / `iris.features.optional`, y comprobación de versión cuando haga
  falta.
- Sin romper el pipeline de Sodium ni depender de funciones exclusivas de OptiFine.
- Lithium y similares son lógica de servidor: verificar que no haya conflictos.
- Distant Horizons opcional, si Iris lo expone en esas versiones.
- Resource packs, incluidos normal y specular maps LabPBR como opción.
- NVIDIA, AMD e Intel; sin extensiones GLSL de un solo fabricante sin fallback.

## 6. Criterios de calidad

- Capturas en las mismas escenas comparables a las 10 referencias (paleta, densidad de niebla,
  forma e iluminación de nubes, contraste).
- Cero errores de compilación GLSL en los tres fabricantes; revisar el log de Iris.
- Sin artefactos graves: shadow acne, peter-panning, ghosting excesivo de TAA, banding en el
  cielo, fireflies en modo RT, fugas de luz a través de paredes.
- Transiciones suaves entre día/noche, clima y dimensión, sin saltos bruscos de exposición.
- Cambiar de preset debe notarse claramente en rendimiento y calidad.
- Código modular, comentado, organizado en `lib/`, sin duplicaciones.
- Implementación 100% original.

## 7. Entregables del proyecto

- El pack en `shaders/`, empaquetable con `scripts/empaquetar.sh`.
- `docs/arquitectura.md`: qué hace cada pase y en qué orden (se actualiza en cada fase).
- `docs/instalacion-y-pruebas.md`: instalación en Modrinth (elegir OpenGL en 26.2+), escenas para
  comparar con cada referencia y cómo leer los errores de Iris.
- Tabla de rendimiento esperado por preset y lista de limitaciones conocidas.
