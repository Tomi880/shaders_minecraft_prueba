#version 330 compatibility

/* RENDERTARGETS: 0 */
in vec4 colorVertice;
layout(location = 0) out vec4 colorEscena;

void main() {
    colorEscena = colorVertice;
}
