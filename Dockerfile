FROM debian:bullseye

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG VERSION="dev"
ARG DJANGO_PATH="template"

RUN groupadd -r app && \
    useradd -r -g app app && \
    mkdir -p /app /virtualenv && \
    chown -R app: /app /virtualenv

WORKDIR /app
COPY . .

RUN set -ex \
    && buildDeps=( \
        g++ \
    ) \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        "${buildDeps[@]}" \
        python3 \
        python3-pip \
        git \
        shellcheck \
        sudo \
        supervisor \
    && printf "# pylint: skip-file\n\n__version__ = \"%s\"\n" "${VERSION}" > ${DJANGO_PATH}/__version__.py \
    && pip3 install --no-cache-dir poetry \
    && pip3 freeze \
    && ./app.sh dep-install \
    && apt-get purge -y --auto-remove "${buildDeps[@]}" \
    && rm -rf /var/lib/apt/lists/* \
    && ./app.sh build

ENTRYPOINT ["./entrypoint.sh"]

EXPOSE 8000
