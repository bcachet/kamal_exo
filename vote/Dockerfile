FROM ghcr.io/astral-sh/uv:0.5.24 AS uv
FROM python:3.9-alpine3.18 AS base
WORKDIR /app

ENV VIRTUAL_ENV=/opt/venv
ENV UV_CACHE_DIR=/opt/uv-cache/
RUN --mount=type=bind,from=uv,source=/uv,target=/uv \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    --mount=type=cache,target=${UV_CACHE_DIR} \
    <<EOF
/uv venv --system --seed ${VIRTUAL_ENV}
/uv pip install -r requirements.txt
EOF
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"

COPY . .
EXPOSE 5000

FROM base AS dev
ENV FLASK_DEBUG=1
ENV FLASK_ENV=development
CMD ["flask", "run", "--host=0.0.0.0"]

FROM base AS production
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:5000", "--log-file", "-", "--access-logfile", "-", "--workers", "2", "--keep-alive", "0", "--timeout", "600"]