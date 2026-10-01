#version 330 compatibility
#define SHADOW_DISTORTION 0.70 // [0.00 0.35 0.70 0.85] Concentración de texeles hacia el centro del mapa
#include "/lib/distorsion_sombras.glsl"

void main() {
    vec4 posicionClip = ftransform();
    if (abs(posicionClip.w) > 0.00001) {
        vec2 posicionNdc = posicionClip.xy / posicionClip.w;
        posicionClip.xy = distorsionarCoordenadaSombra(posicionNdc, SHADOW_DISTORTION)
            * posicionClip.w;
    }
    gl_Position = posicionClip;
}
