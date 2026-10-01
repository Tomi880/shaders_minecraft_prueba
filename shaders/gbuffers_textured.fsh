#version 330 compatibility
#include "/lib/texturas_gbuffers.glsl"

/* RENDERTARGETS: 0 */
in vec2 coordenadaTextura;
in vec4 colorVertice;
layout(location = 0) out vec4 colorEscena;

void main() {
    vec4 albedo = muestrearAlbedo(coordenadaTextura, colorVertice);
    if (!superaCorteAlpha(albedo)) {
        discard;
    }

    colorEscena = albedo;
}
