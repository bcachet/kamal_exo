FROM docker.io/library/debian:bookworm AS dev

RUN useradd -ms /bin/bash vscode

RUN apt update

## Setup kamal
RUN <<EOF
apt install -y ruby-full build-essential
gem install kamal
EOF

## Setup Python
RUN <<EOF
apt install -y python3 python3-pip python3-venv
python3 -m venv /opt/venv
EOF


ENV PATH="/opt/venv/bin:$PATH"

FROM dev AS build

WORKDIR /workdir

COPY server/requirements.txt .

RUN <<EOF
/opt/venv/bin/pip install -r requirements.txt
EOF

COPY server .

FROM docker.io/library/debian:bookworm-slim AS deploy

RUN <<EOF
apt update
apt install -y python3
EOF

RUN useradd -ms /bin/bash launcher

WORKDIR /app
COPY --from=build --chown=launcher /opt/venv /opt/venv
COPY --from=build --chown=launcher /workdir .

USER launcher
ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT [ "/opt/venv/bin/python3" ]
CMD ["/app/app.py"]