#version 330 compatibility

uniform sampler2D colortex1;
in vec2 coordenadaPantalla;
layout(location = 0) out vec4 colorFinal;

void main() {
    colorFinal = texture(colortex1, coordenadaPantalla);
}
