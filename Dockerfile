# syntax=docker/dockerfile:1

## Build the application from source
FROM golang:1.19 AS build-stage

WORKDIR /app

COPY server/go.mod server/go.sum ./
RUN go mod download

COPY server/* ./
RUN CGO_ENABLED=0 GOOS=linux go build -o /http-server


## Run the tests in the container
FROM build-stage AS run-test-stage

RUN go test -v ./...


## Final stage that will be used to run application
FROM gcr.io/distroless/base-debian12

WORKDIR /

COPY --from=build-stage /http-server /http-server

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/http-server"]
