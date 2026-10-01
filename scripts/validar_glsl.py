#!/usr/bin/env python3
"""Valida la sintaxis GLSL de los programas del shaderpack con glslangValidator.

Expande los #include como lo hace Iris (rutas absolutas desde shaders/ o relativas al archivo),
define las macros típicas de Iris y compila cada programa según su extensión. Los errores se
reportan con el archivo y la línea originales (incluidos los de lib/).

No reemplaza la prueba en el juego: Iris transforma el código y cada driver es distinto. Sirve
para no mandar al PC un zip que ni siquiera compila.

Uso:
    python3 scripts/validar_glsl.py                  # valida todo shaders/
    python3 scripts/validar_glsl.py --vendor amd     # valida las ramas #ifdef de AMD
    python3 scripts/validar_glsl.py -D RT_ENABLED=1  # macros extra
    python3 scripts/validar_glsl.py shaders/composite1.fsh
"""
import argparse
import os
import re
import shutil
import subprocess
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHADERS = os.path.join(RAIZ, "shaders")

ETAPAS = {
    ".vsh": "vert",
    ".fsh": "frag",
    ".gsh": "geom",
    ".tcs": "tesc",
    ".tes": "tese",
    ".csh": "comp",
}

# Macros que Iris define al compilar. MC_VERSION usa el formato oficial 122;
# 260102 es el valor derivado para Minecraft 26.1.2, versión base activa
# (ver docs/referencia/iris-y-versiones.md).
MACROS_BASE = {
    "IS_IRIS": "1",
    "MC_VERSION": "260102",
    "MC_GL_VERSION": "460",
    "MC_GLSL_VERSION": "460",
    "MC_OS_WINDOWS": "1",
}

VENDORS = {
    "nvidia": "MC_GL_VENDOR_NVIDIA",
    "amd": "MC_GL_VENDOR_AMD",
    "intel": "MC_GL_VENDOR_INTEL",
}

PATRON_INCLUDE = re.compile(r'^\s*#\s*include\s+"([^"]+)"')
PATRON_ERROR = re.compile(r"^(ERROR|WARNING): (\d+):(\d+): (.*)$")


class ErrorInclude(Exception):
    pass


def expandir(ruta, pila=None):
    """Devuelve (lineas, origenes) con los #include expandidos.

    origenes[i] = (archivo, numero_de_linea) de la línea i del resultado.
    """
    pila = pila or []
    if ruta in pila:
        raise ErrorInclude("include circular: " + " -> ".join(pila + [ruta]))
    if not os.path.isfile(ruta):
        raise ErrorInclude("no existe el include: " + os.path.relpath(ruta, RAIZ))

    lineas, origenes = [], []
    with open(ruta, encoding="utf-8") as f:
        for numero, linea in enumerate(f, 1):
            coincidencia = PATRON_INCLUDE.match(linea)
            if not coincidencia:
                lineas.append(linea.rstrip("\n"))
                origenes.append((ruta, numero))
                continue
            destino = coincidencia.group(1)
            if destino.startswith("/"):
                incluido = os.path.join(SHADERS, destino.lstrip("/"))
            else:
                incluido = os.path.join(os.path.dirname(ruta), destino)
            sub_lineas, sub_origenes = expandir(os.path.normpath(incluido), pila + [ruta])
            lineas.extend(sub_lineas)
            origenes.extend(sub_origenes)
    return lineas, origenes


def programas(rutas):
    if rutas:
        return [os.path.abspath(r) for r in rutas]
    encontrados = []
    for carpeta, subcarpetas, archivos in os.walk(SHADERS):
        subcarpetas[:] = [d for d in subcarpetas if d != "lib"]
        for nombre in sorted(archivos):
            if os.path.splitext(nombre)[1] in ETAPAS:
                encontrados.append(os.path.join(carpeta, nombre))
    return sorted(encontrados)


def validar(ruta, macros, glslang):
    etapa = ETAPAS[os.path.splitext(ruta)[1]]
    try:
        lineas, origenes = expandir(ruta)
    except ErrorInclude as error:
        return ["ERROR  %s: %s" % (os.path.relpath(ruta, RAIZ), error)]

    # glslang 16.6 exige enlazado cuando recibe definiciones con -D.
    comando = [glslang, "--stdin", "-S", etapa, "-l"]
    comando += ["-D%s=%s" % (k, v) for k, v in sorted(macros.items())]
    proceso = subprocess.run(
        comando, input="\n".join(lineas) + "\n", capture_output=True, text=True
    )

    mensajes = []
    for salida in (proceso.stdout + proceso.stderr).splitlines():
        coincidencia = PATRON_ERROR.match(salida.strip())
        if not coincidencia:
            continue
        nivel, _, linea, texto = coincidencia.groups()
        indice = int(linea) - 1
        if 0 <= indice < len(origenes):
            archivo, linea_original = origenes[indice]
            lugar = "%s:%d" % (os.path.relpath(archivo, RAIZ), linea_original)
        else:
            lugar = os.path.relpath(ruta, RAIZ)
        mensajes.append("%-7s%s: %s  [programa: %s]" % (
            nivel, lugar, texto, os.path.relpath(ruta, RAIZ)))
    if proceso.returncode != 0 and not any(m.startswith("ERROR") for m in mensajes):
        mensajes.append("ERROR  %s: glslang falló sin mensaje reconocible:\n%s" % (
            os.path.relpath(ruta, RAIZ), proceso.stdout + proceso.stderr))
    return mensajes


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("rutas", nargs="*", help="programas concretos (por defecto, todos)")
    parser.add_argument("--vendor", choices=sorted(VENDORS), default="nvidia")
    parser.add_argument("-D", dest="macros", action="append", default=[],
                        metavar="NOMBRE[=VALOR]", help="macro extra")
    args = parser.parse_args()

    glslang = shutil.which("glslangValidator")
    if not glslang:
        print("Falta glslangValidator. Instálalo con: brew install glslang")
        return 2
    if not os.path.isdir(SHADERS) and not args.rutas:
        print("No existe la carpeta shaders/ todavía: nada que validar.")
        return 0

    macros = dict(MACROS_BASE)
    macros[VENDORS[args.vendor]] = "1"
    for macro in args.macros:
        nombre, _, valor = macro.partition("=")
        macros[nombre] = valor or "1"

    lista = programas(args.rutas)
    errores = avisos = 0
    for ruta in lista:
        for mensaje in validar(ruta, macros, glslang):
            print(mensaje)
            if mensaje.startswith("ERROR"):
                errores += 1
            else:
                avisos += 1

    print("\n%d programas, %d errores, %d avisos (vendor: %s)" % (
        len(lista), errores, avisos, args.vendor))
    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
