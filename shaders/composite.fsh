#version 330 compatibility
#include "/lib/espacio_color.glsl"
#include "/lib/utilidades.glsl"

uniform sampler2D colortex0;
in vec2 coordenadaPantalla;

/* RENDERTARGETS: 1 */
layout(location = 0) out vec4 colorTransferido;

void main() {
    // La fase 0 no altera el color: copia a otro buffer para evitar leer y escribir el mismo.
    colorTransferido = texture(colortex0, coordenadaPantalla);
}
