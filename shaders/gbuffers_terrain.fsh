#version 330 compatibility

#define SHADOW_FILTER_MODE 0 // [0 1] 0 = PCF de radio fijo; 1 = PCSS con penumbra variable
#define SHADOW_QUALITY 1 // [0 1 2] 4, 8 o 16 muestras por búsqueda
#define SHADOW_STRENGTH 0.78 // [0.50 0.65 0.78 0.90] Fracción de luz celeste que se oscurece
#define SHADOW_PENUMBRA 1.00 // [0.50 1.00 1.50 2.00] Escala de la búsqueda y penumbra PCSS
#define SHADOW_DISTORTION 0.70 // [0.00 0.35 0.70 0.85] Concentración de texeles hacia el centro

const int shadowMapResolution = 2048; // [512 1024 2048 4096] Resolución cuadrada del shadow map
const float shadowDistance = 128.0; // [64.0 96.0 128.0 160.0] Alcance del mapa en bloques

// El filtro manual PCF/PCSS compara profundidad cruda; el filtrado hardware convertiría el sampler.
const bool shadowHardwareFiltering = false;

#include "/lib/texturas_gbuffers.glsl"
#include "/lib/mapa_luz.glsl"
#include "/lib/distorsion_sombras.glsl"
#include "/lib/sombras_receptor.glsl"

in vec2 coordenadaTextura;
in vec2 coordenadaMapaLuz;
in vec4 colorVertice;
in vec3 posicionVista;
in vec3 normalVista;
layout(location = 0) out vec4 colorEscena;

void main() {
    vec4 albedo = muestrearAlbedo(coordenadaTextura, colorVertice);
    if (!superaCorteAlpha(albedo)) {
        discard;
    }

    vec4 colorVanilla = aplicarMapaLuzVanilla(albedo, coordenadaMapaLuz);
    float visibilidad = calcularVisibilidadSombra(posicionVista, normalVista);

    // Las sombras afectan a la luz del cielo; la luz de bloque cercana conserva su aporte vanilla.
    float luzCielo = smoothstep(0.12, 0.78, coordenadaMapaLuz.y);
    float luzBloque = smoothstep(0.03, 0.32, coordenadaMapaLuz.x);
    float pesoLuzDireccional = luzCielo * (1.0 - 0.90 * luzBloque);
    float factorSombra = mix(1.0 - SHADOW_STRENGTH, 1.0, visibilidad);
    float factorFinal = mix(1.0, factorSombra, pesoLuzDireccional);

    colorEscena = vec4(colorVanilla.rgb * factorFinal, colorVanilla.a);
}
