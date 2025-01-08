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

## Golang environment
RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends \
    golang=2:1.22~2build1 \
    gopls=1:0.18.0+ds-1ubuntu0.24.04.2 \
    delve=1.22.1-1
EOF

## Cleanup
RUN rm -rf /var/lib/apt/lists/*

USER vscode
