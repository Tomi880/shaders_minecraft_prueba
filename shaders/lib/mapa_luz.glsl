// El sampler lightmap es la iluminación vanilla de cielo y fuentes de bloque.
uniform sampler2D lightmap;

// Multiplica el albedo por el lightmap para que el esqueleto conserve la luz original.
vec4 aplicarMapaLuzVanilla(vec4 albedo, vec2 coordenada) {
    vec3 iluminacion = texture(lightmap, coordenada).rgb;
    return vec4(albedo.rgb * iluminacion, albedo.a);
}
