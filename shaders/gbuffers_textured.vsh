#version 330 compatibility
#include "/lib/gbuffers_vertex.glsl"

out vec2 coordenadaTextura;
out vec4 colorVertice;

void main() {
    gl_Position = posicionClipBase();
    coordenadaTextura = coordenadaAtlas();
    colorVertice = gl_Color;
}
