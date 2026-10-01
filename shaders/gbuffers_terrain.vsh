#version 330 compatibility
#include "/lib/gbuffers_vertex.glsl"

out vec2 coordenadaTextura;
out vec2 coordenadaMapaLuz;
out vec4 colorVertice;
out vec3 posicionVista;
out vec3 normalVista;

void main() {
    vec4 posicionVistaHomogenea = gl_ModelViewMatrix * gl_Vertex;
    gl_Position = posicionClipBase();
    coordenadaTextura = coordenadaAtlas();
    coordenadaMapaLuz = coordenadaLightmap();
    colorVertice = gl_Color;
    posicionVista = posicionVistaHomogenea.xyz;
    normalVista = normalize(gl_NormalMatrix * gl_Normal);
}
