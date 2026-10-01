// Calcula luminancia Rec. 709; los coeficientes corresponden a RGB lineal.
float luminanciaRec709(vec3 rgbLineal) {
    return dot(rgbLineal, vec3(0.2126, 0.7152, 0.0722));
}

// Decodifica un canal sRGB para hacer mezclas y dispersión en espacio lineal.
float canalSrgbALineal(float canalSrgb) {
    float canal = max(canalSrgb, 0.0);
    if (canal <= 0.04045) {
        return canal / 12.92;
    }
    return pow((canal + 0.055) / 1.055, 2.4);
}

// Convierte RGB sRGB a RGB lineal canal por canal.
vec3 srgbALineal(vec3 rgbSrgb) {
    return vec3(canalSrgbALineal(rgbSrgb.r),
                canalSrgbALineal(rgbSrgb.g),
                canalSrgbALineal(rgbSrgb.b));
}

// Codifica un canal lineal en sRGB para presentar color en el monitor.
float canalLinealASrgb(float canalLineal) {
    float canal = max(canalLineal, 0.0);
    if (canal <= 0.0031308) {
        return canal * 12.92;
    }
    return 1.055 * pow(canal, 1.0 / 2.4) - 0.055;
}

// Convierte RGB lineal a sRGB al final de la cadena de color.
vec3 linealASrgb(vec3 rgbLineal) {
    return vec3(canalLinealASrgb(rgbLineal.r),
                canalLinealASrgb(rgbLineal.g),
                canalLinealASrgb(rgbLineal.b));
}
