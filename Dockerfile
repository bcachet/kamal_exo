## Build stage from which venv will be created
FROM docker.io/library/debian:bookworm AS build

## Setup Python
RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends \
    python3=3.11.2-1+b1 \
    python3-venv=3.11.2-1+b1 \
    python3-pip=23.0.1+dfsg-1
python3 -m venv /opt/venv
EOF

WORKDIR /workdir

COPY server/requirements.txt .

RUN <<EOF
/opt/venv/bin/pip install -r requirements.txt
EOF

## Final stage that will be used to run application
FROM docker.io/library/debian:bookworm-slim AS final

RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends \
    python3=3.11.2-1+b1
rm -rf /var/lib/apt/lists/*
useradd -ms /bin/bash launcher
EOF

WORKDIR /app
COPY --chown=launcher server .
COPY --from=build --chown=launcher /opt/venv /opt/venv

USER launcher
ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT [ "/opt/venv/bin/python3" ]
CMD ["/app/app.py"]
