#!/bin/bash

# All sh files shellchecked separately, not necessary to follow source
# shellcheck disable=SC1091

if [ ! -f /.dockerenv ] && [ ! -f ./dockerinit ]; then
    echo This script must be run inside a Docker container.
    exit 1
fi

APP_USER="app"

if [ "x${RUN_AS_USER:-false}" != "xtrue" ] && [ "x$(whoami)" != "x$APP_USER" ]; then
    if [ "$1" != "serve" ]; then
        for dir in /static /storage; do
            CURRENT_OWNER="$(stat --format '%U' $dir)"

            if [ "$CURRENT_OWNER" != "$APP_USER" ]; then
                find $dir \! -user $APP_USER -print -exec chown $APP_USER {} \;
            fi
        done
    fi
fi

: "${WEB_CONCURRENCY:=1}"
: "${WORKER_CONCURRENCY:=1}"
: "${PORT:=8000}"

export APP PORT WEB_CONCURRENCY WORKER_CONCURRENCY HTTP_PROXY
export HTTPS_PROXY="$HTTP_PROXY"
export NEW_RELIC_ENVIRONMENT="$ENVIRONMENT"
export NEW_RELIC_PROXY_HOST="$HTTP_PROXY"
export NEW_RELIC_CONFIG_FILE=configs/newrelic.ini
export SSL_CA_FILE=/etc/ssl/certs/ca-certificates.crt
export REQUESTS_CA_BUNDLE="$SSL_CA_FILE"

. ./docker/app.sh start-env

case "$1" in
    deploy)
        shift
        exec ./docker/app.sh deploy
        ;;

    serve)
        # Start services via supervisor
        exec supervisord -c configs/supervisord.conf -n
        ;;

    test)
        shift
        exec ./docker/entrypoint.sh lint
        exec ./docker/entrypoint.sh unit-tests "$@"
        ;;

    lint)
        exec ./docker/app.sh lint
        ;;

    unit-tests)
        shift
        poetry install --no-interaction
        coverage run ./manage.py test "$@" || exit 1
        coverage xml
        coverage html
        coverage report
        ;;

    *)
        bash -c "poetry install && $*"
        ;;
esac
