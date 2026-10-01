# Registro de pruebas en el PC

Equipo: Windows, i5-13450HX, RTX 5060 8 GB. Launcher: Modrinth App. API gráfica: OpenGL.

Una entrada por zip probado, la más reciente arriba.

### v0.2.0 — 2026-10-01

- **Entorno**: Minecraft 26.1.2 Fabric, Iris 1.11.4+mc26.1.2, Sodium Renderer 0.9.2+mc26.1.2, Windows 11, OpenGL 3.3.0, NVIDIA 617.14, RTX 5060 Laptop GPU, i5-13450HX, 1920×1080. Pack seleccionado: `ShaderChocapic13Reborn-v0.2.0.zip`; perfil `Custom` (+1 opción cambiada por el usuario).
- **FPS**: 361 en la captura PCF, 376 en la captura PCSS diurna y 355 en la captura PCSS nocturna. El usuario estima aproximadamente 350 FPS habituales.
- **Capturas** (`docs/pruebas/capturas/`): `2026-10-01_18.15.17.png` (día, PCF); `2026-10-01_18.15.56.png` (día, PCSS); `2026-10-01_18.22.20.png` (noche, PCSS). La segunda imagen se recibió agrupada con las nocturnas, pero visualmente sigue siendo de día; el cambio de hora se registra en el log a las 18:21:15.
- **Carga y cambio de filtro**: el pack aparece activo a las 18:14:13 y el pipeline del Overworld se crea a las 18:14:18. A las 18:15:43 Iris destruye y recrea el pipeline con `Custom (+1 option changed by user)`, coincidiendo con el cambio de PCF a PCSS.
- **`latest.log`** (`docs/pruebas/latest.log`, 553 líneas): cero entradas con etiqueta `[.../ERROR]` y 37 con `[.../WARN]`. No aparecen avisos `Invalid pack option`, errores `Deleting stream buffers` ni `No DH shader found`. Las advertencias son de carga/configuración de otros mods, clases opcionales ausentes, Sodium/driver y sonidos; no se atribuyen al shaderpack. Las dos órdenes de cambio de hora rechazadas desde el cliente tampoco son errores del shader; la noche finalmente queda configurada a las 18:21:15.
- **Resultado**: PCF y PCSS cargan y se pudo cambiar de modo sin errores de Iris registrados. Las capturas muestran ejecución estable alrededor de 350 FPS. La prueba no es una comparación A/B controlada; quedan por evaluar la suavidad de las penumbras y la calidad de sombras en más escenas.

### v0.1.1 — 2026-09-29

| Campo | Valor |
|---|---|
| Minecraft / Iris / Sodium | Minecraft 26.1.2 Fabric / Iris 1.11.4+mc26.1.2 / Sodium Renderer 0.9.2+mc26.1.2 |
| Driver de GPU | NVIDIA 617.14; OpenGL 3.3.0 |
| Preset y resolución | Custom (+0 opciones modificadas) / 1920×1080 |
| FPS (escena y valor) | 300–500 FPS según el usuario; las capturas muestran 10 FPS por el instante de captura y no representan el rendimiento normal. |

- **Carga**: OK; el shaderpack se seleccionó, cargó el mundo y se cambió a BSL antes de cerrar el juego.
- **Errores de `latest.log`**: cero líneas `[ERROR]`, cero `Invalid pack option:` y cero `Deleting stream buffers: Invalid operation.`. Solo aparece `No DH shader found in this pack.`; el pack no implementa programas opcionales de Distant Horizons. Los avisos de configuración de Bliss/BSL no se atribuyen a este pack.
- **Comparación con referencias**: las capturas muestran el mundo con el pack activo; no se hizo una comparación A/B formal con vanilla. El usuario acepta avanzar a la siguiente fase.
- **Artefactos**: el menú muestra `Custom` y no ofrece perfiles guardados; es intencional. La prueba diferencial confirma que retirar las seis declaraciones de perfil vacías elimina los avisos de Iris.
- **Acciones**: fase 0 cerrada. Probar el siguiente bloque funcional, v0.2.0 (sombras direccionales), solo en Minecraft 26.1.2. Mantener 26.2/26.3 diferidas hasta completar fases 0–5.

### v0.1.0 — 2026-09-29

| Campo | Valor |
|---|---|
| Minecraft / Iris / Sodium | Minecraft 26.1.2 Fabric / Iris 1.11.4+mc26.1.2 / Sodium Renderer 0.9.2+mc26.1.2 |
| Driver de GPU | NVIDIA 617.14; OpenGL 3.3.0 |
| Preset y resolución | VERY_LOW (0 opciones cambiadas) / 1920×1080 |
| FPS (escena y valor) | 300–500 FPS según el usuario; sin medición separada por escena. La captura muestra 10 FPS por el instante de captura y no representa el rendimiento normal. |

- **Carga**: OK; el shaderpack aparece y se puede seleccionar.
- **Errores de `latest.log`**: el pipeline del pack se crea en tres cargas y el log no muestra errores explícitos de compilación GLSL del pack. Aparecen seis avisos `Invalid pack option:` por intento y siete errores `Deleting stream buffers: Invalid operation.` al cambiar de shader. La prueba diferencial posterior en v0.1.1 elimina los avisos de opciones; los errores de buffers no se reprodujeron y su causa queda sin confirmar.
- **Comparación con referencias**: escena de terreno diurna sin número de referencia confirmado; el usuario observa solo un pequeño cambio de tonalidad y poco más.
- **Artefactos**: las pantallas de opciones estaban vacías y se cargó `VERY_LOW`; los perfiles vacíos se retiraron tras confirmar que Iris los rechazaba.
- **Acciones**: seguimiento en v0.1.1; fase 0 cerrada con aceptación del usuario, dejando anotado que no hubo A/B formal. No probar 26.2/26.3 hasta terminar las fases 0–5 en 26.1.2.

## Plantilla

### vX.Y.Z — AAAA-MM-DD

| Campo | Valor |
|---|---|
| Minecraft / Iris / Sodium | 26.x / 1.11.x / … |
| Driver de GPU | … |
| Preset y resolución | … |
| FPS (escena y valor) | … |

- **Carga**: OK / error.
- **Errores de `latest.log`**: pegar el extracto relevante.
- **Comparación con referencias**: qué se parece y qué no (número de referencia).
- **Artefactos**: …
- **Acciones**: qué corregir.
