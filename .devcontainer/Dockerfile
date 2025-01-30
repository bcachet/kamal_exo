FROM ghcr.io/astral-sh/uv:0.5.24 AS uv
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

## Setup
RUN <<EOF
wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update
EOF

## Kamal environment
RUN <<EOF
apt-get install -y --no-install-recommends \
    ruby-full \
    build-essential \
    terraform \
    python3 \
    golang
gem install kamal --version=2.4.0
EOF

## Bitwarden to access secrets
ADD https://vault.bitwarden.com/download/?app=cli&platform=linux /tmp/bw.zip
RUN <<EOF
unzip /tmp/bw.zip -d /usr/local/bin
EOF

## Cleanup
RUN rm -rf /var/lib/apt/lists/*

## Python environment for vote app (Flask)
ENV VIRTUAL_ENV=/opt/venv
ENV UV_CACHE_DIR=/opt/uv-cache/
RUN --mount=type=bind,from=uv,source=/uv,target=/uv \
    --mount=type=bind,source=./vote/requirements.txt,target=requirements.txt \
    --mount=type=cache,target=${UV_CACHE_DIR},uid=1000,gid=1000 \
    <<EOF
/uv venv --system ${VIRTUAL_ENV}
/uv pip install -r requirements.txt
EOF

RUN chown -R vscode:vscode /opt/venv

USER vscode

## Golang environment for worker app
RUN --mount=type=bind,source=./worker/src/go.sum,target=go.sum \
    --mount=type=bind,source=./worker/src/go.mod,target=go.mod \
    go mod download

ENV PATH="${VIRTUAL_ENV}/bin:$PATH"
