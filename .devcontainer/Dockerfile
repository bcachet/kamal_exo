FROM mcr.microsoft.com/devcontainers/base:bookworm

## Setup
RUN apt-get update

## Kamal environment
RUN <<EOF
apt-get install -y --no-install-recommends \
    ruby-full=1:3.1 \
    build-essential=12.9
gem install kamal
EOF

## Golang environment
RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends \
    golang=2:1.19~1 \
    gopls=1:0.5.0+ds-1 \
    delve=1.20.2-1
EOF

## Cleanup
RUN rm -rf /var/lib/apt/lists/*

USER vscode
