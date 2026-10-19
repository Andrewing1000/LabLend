#!/usr/bin/env bash
# Levanta el entorno publicado completo: base de datos, backend y la puerta de
# entrada nginx que sirve la aplicación Flutter ya compilada.
#
#   ./hosting/up.sh            levanta todo
#   ./hosting/up.sh --build    reconstruye antes la imagen del backend
#
# Requisitos previos, una sola vez:
#   - backend/.env completo (ver README, secciones 1 y 5)
#   - la aplicación web compilada en frontend/build/web:
#       cd frontend && flutter build web --release \
#         --dart-define=SERVER_URL=https://lablend.dontrisk.org
set -euo pipefail

raiz="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# El segundo archivo cambia runserver por Gunicorn (D8).
compose_backend=(docker compose -p lablend -f "$raiz/backend/docker-compose.yml"
                 -f "$raiz/hosting/compose.backend.yml"
                 --env-file "$raiz/backend/.env")

if [ ! -f "$raiz/backend/.env" ]; then
    echo "Falta backend/.env: créalo desde backend/.env.example (README, sección 1)." >&2
    exit 1
fi

# El contenedor monta ./app como volumen, así que sirve el árbol de trabajo:
# lo que esté en HEAD es lo que queda publicado.
rama="$(git -C "$raiz" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
if [ "$rama" != "seguridad" ]; then
    echo "Atención: el árbol de trabajo está en '$rama', no en 'seguridad'." >&2
    echo "El backend sirve el árbol montado, así que se publicaría esa rama." >&2
    read -r -p "¿Continuar de todas formas? [s/N] " r
    [ "$r" = "s" ] || exit 1
fi

if [ ! -f "$raiz/frontend/build/web/index.html" ]; then
    echo "Falta frontend/build/web: compila la aplicación web antes (ver arriba)." >&2
    exit 1
fi

# La base de datos primero: en el primer arranque PostgreSQL se reinicia para
# escuchar en TCP, y si el backend corre las migraciones en ese hueco, falla.
"${compose_backend[@]}" up -d "$@" db
until "${compose_backend[@]}" exec -T db pg_isready -q; do sleep 1; done

"${compose_backend[@]}" up -d "$@" app_new
"${compose_backend[@]}" exec -T app_new python manage.py collectstatic --noinput

docker compose -p lablend-web -f "$raiz/hosting/compose.yml" up -d

echo
echo "Listo. Comprobación: curl -s localhost:15185/health_check"
