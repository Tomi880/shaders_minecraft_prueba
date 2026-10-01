// Concentra más texeles en el centro del mapa sin sacar del frustum sus bordes.
// La misma función se aplica al dibujar y al consultar sombras para conservar la correspondencia.
vec2 distorsionarCoordenadaSombra(vec2 coordenadaNdc, float intensidad) {
    float distanciaAlBorde = max(abs(coordenadaNdc.x), abs(coordenadaNdc.y));
    float concentracionCentral = 0.40 * clamp(intensidad, 0.0, 1.0);
    float escala = 1.0 + concentracionCentral * (1.0 - distanciaAlBorde);
    return coordenadaNdc * escala;
}
