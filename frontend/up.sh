#!/bin/bash

# Añadir todos los cambios al índice
git add .

# Realizar el commit con el mensaje proporcionado como argumento
git commit -m "$1"

# Enviar los cambios al repositorio remoto en la rama especificada
git push origin $2

