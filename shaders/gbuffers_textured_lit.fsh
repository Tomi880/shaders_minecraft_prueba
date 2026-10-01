#version 330 compatibility
#include "/lib/texturas_gbuffers.glsl"
#include "/lib/mapa_luz.glsl"

/* RENDERTARGETS: 0 */
in vec2 coordenadaTextura;
in vec2 coordenadaMapaLuz;
in vec4 colorVertice;
layout(location = 0) out vec4 colorEscena;

void main() {
    vec4 albedo = muestrearAlbedo(coordenadaTextura, colorVertice);
    if (!superaCorteAlpha(albedo)) {
        discard;
    }

    // Se conserva la iluminación vanilla del lightmap hasta implementar la luz propia.
    colorEscena = aplicarMapaLuzVanilla(albedo, coordenadaMapaLuz);
}
