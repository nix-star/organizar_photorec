#!/bin/bash

# Uso:
# ./organizar_photorec.sh [--copy] [--no-subdir] <origen> [destino]

COPY=false
NOSUBDIR=false
ARGS=()

# Analizar flags
for arg in "$@"; do
    case "$arg" in
        --copy) COPY=true ;;
        --no-subdir) NOSUBDIR=true ;;
        *) ARGS+=("$arg") ;;
    esac
done

# Verificar argumentos obligatorios
if [ ${#ARGS[@]} -lt 1 ]; then
    echo "Uso: $0 [--copy] [--no-subdir] <origen> [destino]"
    exit 1
fi

ORIGEN="${ARGS[0]}"
DESTINO="${ARGS[1]}"

# Verificar existencia del origen
if [ ! -d "$ORIGEN" ]; then
    echo "Error: el directorio origen no existe."
    exit 1
fi

# Si no se especifica destino, generar uno con hash
if [ -z "$DESTINO" ]; then
    HASH=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c8)
    DESTINO="folder-$HASH"
fi

mkdir -p "$DESTINO"
LOGFILE="$DESTINO/log.txt"
LOGFAIL="$DESTINO/log-fail.txt"
touch "$LOGFILE"

TOTAL_OK=0
TOTAL_FAIL=0

# Función para obtener timestamp
timestamp() {
    date "+[%Y-%m-%d %H:%M:%S]"
}

# Función para mover o copiar archivo con control de duplicados
procesar_archivo() {
    local archivo="$1"
    local subdir_relativo="$2"
    local nombre_archivo=$(basename "$archivo")
    local extension="${nombre_archivo##*.}"

    # Detectar si no tiene extensión o es .other
    if [[ "$nombre_archivo" == "$extension" ]] || [[ "$extension" == "other" ]]; then
        extension="other"
    fi

    # Crear carpeta de extensión
    carpeta_destino="$DESTINO/$extension"
    if [ "$NOSUBDIR" = false ]; then
        carpeta_destino="$carpeta_destino/$subdir_relativo"
    fi
    mkdir -p "$carpeta_destino"

    destino_base="$carpeta_destino/$nombre_archivo"
    destino_final="$destino_base"

    # Asegurarse de no sobrescribir
    contador=1
    while [ -e "$destino_final" ]; do
        base_sin_ext="${nombre_archivo%.*}"
        ext="${nombre_archivo##*.}"
        if [ "$base_sin_ext" == "$ext" ]; then
            destino_final="$carpeta_destino/${nombre_archivo}-${contador}"
        else
            destino_final="$carpeta_destino/${base_sin_ext}-${contador}.${ext}"
        fi
        ((contador++))
    done

    # Realizar la operación con control de errores
    if [ "$COPY" = true ]; then
        if cp "$archivo" "$destino_final" 2>/dev/null; then
            echo "$(timestamp) [COPIADO] $archivo -> $destino_final" >> "$LOGFILE"
            ((TOTAL_OK++))
        else
            echo "$(timestamp) [ERROR] No se pudo copiar: $archivo" >> "$LOGFILE"
            echo "$(timestamp) $archivo" >> "$LOGFAIL"
            ((TOTAL_FAIL++))
        fi
    else
        if mv "$archivo" "$destino_final" 2>/dev/null; then
            echo "$(timestamp) [MOVIDO] $archivo -> $destino_final" >> "$LOGFILE"
            ((TOTAL_OK++))
        else
            echo "$(timestamp) [ERROR] No se pudo mover: $archivo" >> "$LOGFILE"
            echo "$(timestamp) $archivo" >> "$LOGFAIL"
            ((TOTAL_FAIL++))
        fi
    fi
}

# Buscar todos los archivos en origen
find "$ORIGEN" -type f | while read -r archivo; do
    dir_actual=$(dirname "$archivo")
    subdir_relativo=$(basename "$dir_actual")

    if [ "$NOSUBDIR" = true ]; then
        subdir_relativo=""
    fi

    procesar_archivo "$archivo" "$subdir_relativo"
done

# Agregar resumen final al log
echo "" >> "$LOGFILE"
echo "$(timestamp) Resumen final:" >> "$LOGFILE"
echo "$(timestamp) Archivos procesados con éxito: $TOTAL_OK" >> "$LOGFILE"
echo "$(timestamp) Archivos que fallaron: $TOTAL_FAIL" >> "$LOGFILE"

# Eliminar log-fail.txt si no hubo errores
if [ "$TOTAL_FAIL" -eq 0 ]; then
    rm -f "$LOGFAIL"
fi

echo "Procesamiento completado en '$DESTINO'"
echo "Log principal: $LOGFILE"
if [ -f "$LOGFAIL" ]; then
    echo "Algunos archivos fallaron. Ver detalles en: $LOGFAIL"
fi
