#version 330 compatibility
#include "/lib/pantalla.glsl"

out vec2 coordenadaPantalla;

void main() {
    gl_Position = posicionPantalla();
    coordenadaPantalla = uvPantalla();
}
