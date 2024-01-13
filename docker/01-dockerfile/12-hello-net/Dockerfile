### build stage ###
FROM golang:1.14 as builder
COPY . .
RUN go build \
  -ldflags "-linkmode external -extldflags -static" \
  -a server.go

### run stage ###
FROM alpine
RUN apk add --no-cache curl net-tools
COPY --from=builder /go/server ./server
ENV port 8080
CMD ["./server"]

# docker build -t brainupgrade/hello:net .