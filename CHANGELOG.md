# Changelog

Una entrada por versión enviada a probar al PC, la más reciente arriba.

## 0.2.0 — 2026-09-29

- Inicia fase 1 con sombras direccionales para terreno: shadow pass con distorsión y recepción PCF/PCSS.
- Añadidos controles de resolución/distancia, filtro, calidad de muestras, penumbra, distorsión e intensidad con traducciones y tooltips.
- `shadowtex1` conserva profundidad cruda para el filtro manual; agua y bloques translúcidos mantienen pass-through vanilla.
- Pendiente de prueba en Minecraft 26.1.2. Los recortes alfa pueden proyectar siluetas opacas; limitación documentada.

## 0.1.1 — 2026-09-29 (diagnóstico)

- Se omiten temporalmente las seis declaraciones de perfiles vacías para aislar los avisos `Invalid pack option:` observados en Iris; no se agregan opciones ficticias.
- Build de diagnóstico para Minecraft 26.1.2. La prueba diferencial confirma que las declaraciones de perfiles vacías causaban los avisos de Iris; al retirarlas, v0.1.1 pasa el criterio de carga de fase 0. Los perfiles funcionales se incorporan en fase 5.

## 0.1.0 — 2026-09-29

- Añadido el esqueleto GLSL de fase 0: gbuffers con fallbacks, composite y final pass-through.
- Añadidos menú traducido, seis perfiles vacíos, bibliotecas GLSL base e IDs para emisores.
- Documentados el pipeline, los buffers previstos y el formato `MC_VERSION` para Minecraft 26.x.
- Prueba inicial en PC con Minecraft 26.1.2 e Iris 1.11.4: el pipeline carga sin errores GLSL explícitos; quedan avisos/errores del log por atribuir y la fase 0 sigue abierta.
- Desarrollo de las fases 0–5 centrado en 26.1.2; compatibilidad con 26.2/26.3 se abordará secuencialmente después de terminar el shader.

## 0.0.1

- Estructura del proyecto (harness): AGENTS.md, spec, plan por fases, referencia de Iris, scripts.
