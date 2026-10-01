// Conserva las transformaciones vanilla para la geometría que comparte los programas base.
vec4 posicionClipBase() {
    return ftransform();
}

// Aplica la matriz del atlas de Minecraft antes de muestrear gtexture.
vec2 coordenadaAtlas() {
    return (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

// Aplica la matriz del lightmap sin alterar su codificación vanilla.
vec2 coordenadaLightmap() {
    return (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
}
