// Muestrea el depth buffer de sombras en espacio de pantalla y lo convierte en visibilidad.
// PCF compara varias profundidades; PCSS busca bloqueadores y ensancha la penumbra con la separación.
uniform sampler2D shadowtex1;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;

#if SHADOW_QUALITY == 0
const int CANTIDAD_MUESTRAS_SOMBRA = 4;
const float RADIO_PCF_TEXELES = 0.85;
#elif SHADOW_QUALITY == 1
const int CANTIDAD_MUESTRAS_SOMBRA = 8;
const float RADIO_PCF_TEXELES = 1.25;
#else
const int CANTIDAD_MUESTRAS_SOMBRA = 16;
const float RADIO_PCF_TEXELES = 1.75;
#endif

// Distribuye las muestras en espiral áurea para cubrir el disco sin una tabla de offsets repetida.
vec2 generarMuestraDiscoSombra(int indice) {
    float fraccion = (float(indice) + 0.5) / float(CANTIDAD_MUESTRAS_SOMBRA);
    float radio = sqrt(fraccion);
    float angulo = float(indice) * 2.39996323;
    return vec2(cos(angulo), sin(angulo)) * radio;
}

// Proyecta la posición del gbuffer al mapa y aplica un pequeño sesgo normal para reducir acne.
vec3 calcularCoordenadaSombra(vec3 posicionVista, vec3 normalVista, out float sesgoProfundidad) {
    vec3 normal = normalize(normalVista);
    vec3 direccionLuz = normalize(shadowLightPosition);
    float incidencia = max(dot(normal, direccionLuz), 0.0);
    float pendiente = 1.0 - incidencia;
    sesgoProfundidad = 0.00020 + pendiente * 0.00065;

    vec3 posicionAjustada = posicionVista + normal * (0.012 + pendiente * 0.020);
    vec4 posicionMundo = gbufferModelViewInverse * vec4(posicionAjustada, 1.0);
    vec4 posicionClipSombra = shadowProjection * shadowModelView * posicionMundo;
    if (abs(posicionClipSombra.w) < 0.00001) {
        return vec3(-1.0);
    }

    vec3 posicionNdc = posicionClipSombra.xyz / posicionClipSombra.w;
    posicionNdc.xy = distorsionarCoordenadaSombra(posicionNdc.xy, SHADOW_DISTORTION);
    return posicionNdc * 0.5 + 0.5;
}

// Promedia las comparaciones de profundidad en un disco expresado en texeles del shadow map.
float filtrarProfundidadPCF(vec3 coordenadaSombra, float sesgo, float radioTexeles) {
    vec2 tamanoTexel = vec2(1.0 / float(shadowMapResolution));
    float visibilidad = 0.0;
    for (int indice = 0; indice < CANTIDAD_MUESTRAS_SOMBRA; ++indice) {
        vec2 uv = coordenadaSombra.xy
            + generarMuestraDiscoSombra(indice) * tamanoTexel * radioTexeles;
        float profundidadGuardada = texture(shadowtex1, uv).r;
        visibilidad += step(coordenadaSombra.z - sesgo, profundidadGuardada);
    }
    return visibilidad / float(CANTIDAD_MUESTRAS_SOMBRA);
}

// Busca profundidades más cercanas que el receptor; si no hay bloqueadores, la zona está iluminada.
float buscarProfundidadBloqueador(vec3 coordenadaSombra, float sesgo) {
    vec2 tamanoTexel = vec2(1.0 / float(shadowMapResolution));
    float radioBusqueda = 4.0 + 2.0 * SHADOW_PENUMBRA;
    float sumaProfundidad = 0.0;
    float cantidadBloqueadores = 0.0;

    for (int indice = 0; indice < CANTIDAD_MUESTRAS_SOMBRA; ++indice) {
        vec2 uv = coordenadaSombra.xy
            + generarMuestraDiscoSombra(indice) * tamanoTexel * radioBusqueda;
        float profundidadGuardada = texture(shadowtex1, uv).r;
        if (profundidadGuardada < coordenadaSombra.z - sesgo) {
            sumaProfundidad += profundidadGuardada;
            cantidadBloqueadores += 1.0;
        }
    }

    if (cantidadBloqueadores < 0.5) {
        return -1.0;
    }
    return sumaProfundidad / cantidadBloqueadores;
}

// El modo PCSS convierte la distancia entre receptor y bloqueador en un radio variable de PCF.
float filtrarProfundidadPCSS(vec3 coordenadaSombra, float sesgo) {
    float profundidadBloqueador = buscarProfundidadBloqueador(coordenadaSombra, sesgo);
    if (profundidadBloqueador < 0.0) {
        return 1.0;
    }

    float separacion = max(coordenadaSombra.z - profundidadBloqueador, 0.0);
    float radioPenumbra = (separacion / max(profundidadBloqueador, 0.05))
        * float(shadowMapResolution) * 0.20 * SHADOW_PENUMBRA;
    radioPenumbra = clamp(radioPenumbra, 0.75, 7.0);
    return filtrarProfundidadPCF(coordenadaSombra, sesgo, radioPenumbra);
}

// Devuelve iluminación completa fuera del mapa y selecciona el filtrado solicitado dentro de él.
float calcularVisibilidadSombra(vec3 posicionVista, vec3 normalVista) {
    float sesgo = 0.0;
    vec3 coordenadaSombra = calcularCoordenadaSombra(posicionVista, normalVista, sesgo);
    if (any(lessThan(coordenadaSombra, vec3(0.0)))
        || any(greaterThan(coordenadaSombra, vec3(1.0)))) {
        return 1.0;
    }

#if SHADOW_FILTER_MODE == 0
    return filtrarProfundidadPCF(coordenadaSombra, sesgo, RADIO_PCF_TEXELES);
#else
    return filtrarProfundidadPCSS(coordenadaSombra, sesgo);
#endif
}
