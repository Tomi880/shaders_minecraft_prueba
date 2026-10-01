Usa el agente shader-dev.

Empieza la fase 0 (esqueleto) de docs/plan/fases.md.

1. Lee AGENTS.md, docs/spec/requisitos.md y docs/referencia/.
2. Resuelve lo que la fase 0 necesite de «Por verificar» en docs/referencia/iris-y-versiones.md
   (sobre todo MC_VERSION para 26.x) consultando https://shaders.properties/ y anótalo con la URL.
3. Crea el esqueleto: shaders.properties con la estructura de pantallas del menú y los 6 perfiles
   (aunque aún tengan pocas opciones), programas gbuffers pass-through, composite y final
   simples, lib/ base, block.properties con los IDs de las fuentes de luz de la spec y los dos
   .lang.
4. Escribe docs/arquitectura.md con el pipeline previsto para todas las fases (qué hace cada pase
   y en qué orden) y cómo se reparten los colortex.
5. Valida con scripts/validar_glsl.py, sube VERSION a 0.1.0, actualiza CHANGELOG.md y empaqueta.
6. Dime qué probar en el PC para cerrar la fase.
