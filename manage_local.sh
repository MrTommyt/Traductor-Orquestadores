#!/bin/bash

# Function to show usage
usage() {
    echo "Uso: $0 [opciones]"
    echo "Opciones:"
    echo "  -b, --build    Construye la imagen antes de iniciar los contenedores"
    echo "  -d, --detach   Ejecuta en modo background (detached)"
    echo "  -h, --help     Muestra esta ayuda"
    exit 1
}

# Load .env variables into the shell environment
if [ -f .env ]; then
    echo "Cargando variables desde .env..."
    set -a
    source .env
    set +a
else
    echo "No se encontró el archivo .env"
fi

BUILD_FLAG=""
DETACH_FLAG=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -b|--build)
            BUILD_FLAG="--build"
            ;;
        -d|--detach)
            DETACH_FLAG="-d"
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Opción desconocida: $1"
            usage
            ;;
    esac
    shift
done

echo "Iniciando entorno local con Docker Compose..."
docker-compose up $BUILD_FLAG $DETACH_FLAG

