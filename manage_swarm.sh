#!/bin/bash

# Configuration
STACK_NAME="mlops-orquestadores"
SERVICE_NAME="${STACK_NAME}_app-traductor"
IMAGE_NAME="app-traductor:1.0.0"

# Function to show usage
usage() {
    echo "Uso: $0 [opciones]"
    echo "Opciones:"
    echo "  -b, --build    Construye la imagen localmente (necesario si cambió el código)"
    echo "  -u, --update   Fuerza la actualización del servicio (rolling restart)"
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

DO_BUILD=false
DO_UPDATE=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -b|--build)
            DO_BUILD=true
            ;;
        -u|--update)
            DO_UPDATE=true
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

if [ "$DO_BUILD" = true ]; then
    echo "Construyendo imagen Docker: $IMAGE_NAME..."
    docker build -t $IMAGE_NAME .
    if [ $? -ne 0 ]; then
        echo "Error al construir la imagen."
        exit 1
    fi
fi

echo "Desplegando stack en Swarm: $STACK_NAME..."
docker stack deploy -c docker-stack.yml $STACK_NAME

if [ "$DO_UPDATE" = true ]; then
    echo "Forzando actualización del servicio: $SERVICE_NAME..."
    docker service update --force $SERVICE_NAME
fi

echo "Operaciones finalizadas."

