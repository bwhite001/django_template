#!/bin/bash -e

export APP PORT WEB_CONCURRENCY WORKER_CONCURRENCY
VIRTUALENV_BASE="${VIRTUALENV_BASE:-/virtualenv}"

case "$1" in
    build)
        . ./app.sh start-env
        ./manage.py collectstatic --noinput
        ;;

    deploy)
        ./manage.py copystatic  # Copy static files
        ./manage.py migrate --no-input  # Migrate database
        # Load fixtures, if any.
        ;;

    lint)
        . ./app.sh start-env
        pre-commit run --all-files
        ;;

    dep-install)
        . ./app.sh start-env
        poetry install --no-dev --no-interaction
        ;;

    dep-graph)
        . ./app.sh start-env
        poetry show --tree
        ;;

    start-env)
        if [ -z "$VIRTUAL_ENV" ]; then
            if [ ! -f "$VIRTUALENV_BASE/bin/activate" ]; then
                echo "Creating virtualenv"
                virtualenv -p "$(command -v python3)" --system-site-packages "$VIRTUALENV_BASE"
            fi
                # squash SC1090. We dont want to lint the source here
                # shellcheck source=/dev/null
                . "$VIRTUALENV_BASE/bin/activate"
        fi
        ;;

    *)
        echo Unknown command
        exit 1
        ;;
esac
