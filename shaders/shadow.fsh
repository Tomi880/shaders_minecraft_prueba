#version 330 compatibility

// Iris escribe automáticamente la profundidad de este pase en los shadow buffers.
// No se samplea gtexture: el atlas solo está disponible en gbuffers, por lo que los recortes
// alfa todavía proyectan una silueta opaca en este primer bloque de sombras.
void main() {
}
