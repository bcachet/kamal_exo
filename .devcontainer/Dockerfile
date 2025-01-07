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

## Python environment
RUN <<EOF
apt-get install -y --no-install-recommends \
    python3=3.11.2-1+b1 \
    python3-venv=3.11.2-1+b1 \
    python3-pip=23.0.1+dfsg-1 \
    black=23.1.0-1 \
    flake8=5.0.4-4
python3 -m venv /opt/venv
EOF
COPY server/requirements.txt .
RUN /opt/venv/bin/pip install -r requirements.txt

## Cleanup
RUN rm -rf /var/lib/apt/lists/*

## Ensure vscode user use Python from venv
USER vscode
ENV PATH="/opt/venv/bin:$PATH"
