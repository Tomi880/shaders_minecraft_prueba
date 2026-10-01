# AGENTS.md — Shaderpack para Minecraft Java (Iris)

Shaderpack original para **Minecraft Java 26.1 – 26.3** sobre **Iris Shaders**, con estética
inspirada en Chocapic13 (cálida, cinematográfica, niebla densa, nubes volumétricas, cielos con
fuerte dispersión al amanecer/atardecer). Implementación 100% propia: **nunca copies código de
Chocapic13 ni de otros packs** con licencia restrictiva.

- Requisitos completos (referencias visuales, features, presets, menú, compatibilidad, calidad):
  `docs/spec/requisitos.md`. Es la fuente de verdad del *qué*.
- Plan por fases con criterios de término: `docs/plan/fases.md`.
- Referencia técnica verificada de Iris y versiones: `docs/referencia/`.
- Registro de pruebas en el PC: `docs/pruebas/registro.md`.

## Plataforma objetivo (verificado en `docs/referencia/iris-y-versiones.md`)

| Componente | Valor |
|---|---|
| Minecraft | Java 26.1–26.3 (Fabric; objetivo final) |
| Mod de shaders | Iris 1.10.x / 1.11.x para 26.x, con Sodium |
| Launcher de pruebas | Modrinth App |
| API gráfica | **OpenGL**. Desde 26.2 Minecraft trae un renderer Vulkan opcional con el que Iris **no funciona**: en Opciones de video hay que elegir OpenGL. |
| GPUs soportadas | NVIDIA, AMD e Intel, de iGPU a gama alta |

- **Versión base activa para desarrollo y pruebas:** Minecraft 26.1.2. Mantén las fases 0–5
  enfocadas en esta versión. Solo al completar la fase 5 se inicia la compatibilidad posterior,
  probando 26.2 y 26.3 secuencialmente, una versión a la vez.
- Iris está anunciado como descontinuado a favor de **Aperture** (Vulkan). Este pack apunta a
  Iris/OpenGL, pero escribe las funciones de `lib/` como GLSL puro (matemática, ruido,
  atmósfera, BRDF), sin depender de uniforms de Iris, para que un port futuro sea viable.
- No afirmes nada sobre APIs de Iris (uniforms, directivas, feature flags, macros) que no esté en
  `docs/referencia/` o en la documentación oficial (https://shaders.properties/). Si dudas,
  consulta la página y anótalo en `docs/referencia/`. Minecraft 26.x es reciente: tu conocimiento
  previo puede estar desactualizado.

## Entorno de trabajo

- **El código se escribe en una Mac y se prueba en otro PC** (Windows, i5-13450HX, RTX 5060 de
  8 GB). Esta Mac **no** es la plataforma objetivo: no le apliques sus límites.
- Ciclo de prueba (lento, por eso hay que validar antes):
  1. `python3 scripts/validar_glsl.py` → cero errores.
  2. `bash scripts/empaquetar.sh` → genera `dist/<nombre>-v<versión>.zip`.
  3. El usuario sube el zip a Google Drive, lo descarga en el PC, lo copia a la carpeta
     `shaderpacks` de la instancia de Modrinth y lo prueba.
  4. El usuario vuelve con capturas, FPS y el extracto de `logs/latest.log` → regístralo en
     `docs/pruebas/registro.md` y corrige.
- Sube la versión en `VERSION` en cada zip que se mande a probar, y anota qué cambió en
  `CHANGELOG.md`, para que cada prueba se asocie a una versión exacta.

## Estructura

```text
shaders/                 # raíz del pack dentro del zip
  shaders.properties     # menú, presets (profile.*), features, programas
  block.properties  item.properties  entity.properties
  dimension.properties   # mapeo de dimensiones (Iris)
  lang/en_us.lang  lang/es_es.lang
  lib/                   # funciones reutilizables (.glsl), sin duplicaciones
  *.vsh *.fsh *.gsh *.csh
docs/  scripts/  dist/ (ignorado)
```

## Convenciones de código

- Cada programa declara su `#version` en la primera línea. Base: `#version 330 compatibility`.
  Lo que necesite compute, custom images o SSBO (modo Ray Tracing) va en programas `430`+ y
  detrás de `iris.features.optional`, con fallback al modo clásico si no hay soporte.
- Includes con ruta absoluta desde `shaders/`: `#include "/lib/atmosfera.glsl"`.
- Opciones del menú como `#define NOMBRE valor // [v1 v2 v3]` y declaradas en
  `shaders.properties`. Cada opción nueva lleva su texto y tooltip (con impacto en rendimiento
  bajo/medio/alto) en **los dos** `.lang`.
- Nada de extensiones GLSL de un solo fabricante sin fallback.
- Comentarios en español, explicando el porqué de cada técnica y sus parámetros.
- Nada de `TODO` ni pseudocódigo: cada fase deja el pack compilando y funcional.

## Reglas

- Trabaja por fases (`docs/plan/fases.md`). No empieces una fase sin que la anterior haya pasado
  su prueba en el PC.
- Antes de entregar: `validar_glsl.py` sin errores y revisar que cada opción nueva esté en
  `shaders.properties` y en los dos `.lang`.
- Los errores que reporte el usuario desde `latest.log` mandan sobre el validador local: Iris
  transforma el código y el driver del PC puede rechazar cosas que glslang acepta.
- Si aprendes una trampa de Iris o del driver, anótala en `docs/referencia/trampas.md`.
