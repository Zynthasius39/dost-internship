FROM golang:1.26.3-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o gopher main.go

FROM scratch

WORKDIR /

COPY --from=builder /app/gopher /gopher

EXPOSE 8080

ENTRYPOINT ["/gopher"]
