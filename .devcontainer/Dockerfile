FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

## Setup
RUN apt-get update

## Kamal environment
RUN <<EOF
apt-get install -y --no-install-recommends \
    ruby-full=1:3.2~ubuntu1 \
    build-essential=12.10ubuntu1
gem install kamal
EOF

## Cleanup
RUN rm -rf /var/lib/apt/lists/*

USER vscode
