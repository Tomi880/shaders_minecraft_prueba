// Sampler y umbral documentados por Iris para conservar atlas y recortes alfa vanilla.
uniform sampler2D gtexture;
uniform float alphaTestRef;

// Combina el texel del atlas con el tinte recibido (por ejemplo, el del bioma).
vec4 muestrearAlbedo(vec2 coordenada, vec4 tinteVertice) {
    return texture(gtexture, coordenada) * tinteVertice;
}

// Mantiene los recortes alfa de hojas, hierba y otras texturas con transparencia.
bool superaCorteAlpha(vec4 albedo) {
    return albedo.a >= alphaTestRef;
}
