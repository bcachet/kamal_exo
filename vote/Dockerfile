FROM python:3.9-alpine3.18 AS base
WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000

FROM base AS dev
ENV FLASK_DEBUG=1
ENV FLASK_ENV=development
CMD ["flask", "run", "--host=0.0.0.0"]

FROM base as production
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:5000", "--log-file", "-", "--access-logfile", "-", "--workers", "2", "--keep-alive", "0", "--timeout", "600"]