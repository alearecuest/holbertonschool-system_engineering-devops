#!/bin/bash

read -p "Ingrese el nombre del archivo .py: " archivo

# Verifica si el archivo existe
if [[ ! -f "$archivo" ]]; then
    echo "El archivo '$archivo' no existe."
    exit 1
fi

# Verifica si tiene extensión .py
if [[ "$archivo" != *.py ]]; then
    echo "El archivo debe tener extensión .py"
    exit 1
fi

# Aplica permisos de ejecución
chmod u+x "$archivo"
echo "Permisos de ejecución añadidos a '$archivo'"