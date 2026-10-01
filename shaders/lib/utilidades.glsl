// Limita escalares a [0, 1], rango común para máscaras y mezclas de efectos.
float limitarUnitario(float valor) {
    return clamp(valor, 0.0, 1.0);
}

// Remapea un rango y limita el factor para evitar extrapolaciones en máscaras.
float remapearLimitado(float valor, float origenMin, float origenMax,
                       float destinoMin, float destinoMax) {
    float amplitud = origenMax - origenMin;
    if (abs(amplitud) < 0.000001) {
        return destinoMin;
    }

    float factor = limitarUnitario((valor - origenMin) / amplitud);
    return mix(destinoMin, destinoMax, factor);
}
