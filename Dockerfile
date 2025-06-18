FROM golang:1.23-alpine

WORKDIR /app
COPY . .

RUN go build -o proxy_server

CMD ["./proxy_server"]