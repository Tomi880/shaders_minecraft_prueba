// Conserva la transformación de la quad de pantalla que entrega el pipeline.
vec4 posicionPantalla() {
    return ftransform();
}

// Reutiliza las UV de la quad para muestrear los buffers a resolución de pantalla.
vec2 uvPantalla() {
    return gl_MultiTexCoord0.st;
}
