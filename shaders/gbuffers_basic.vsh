#version 330 compatibility

out vec4 colorVertice;

void main() {
    gl_Position = ftransform();
    colorVertice = gl_Color;
}
