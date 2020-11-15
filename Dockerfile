FROM golang:1.14-alpine AS development

ENV PROJECT_PATH=/chirpstack-network-server
ENV PATH=$PATH:$PROJECT_PATH/build
ENV CGO_ENABLED=0
ENV GO_EXTRA_BUILD_ARGS="-a -installsuffix cgo"

RUN apk add --no-cache ca-certificates tzdata make git bash protobuf

RUN mkdir -p $PROJECT_PATH
COPY . $PROJECT_PATH
WORKDIR $PROJECT_PATH

RUN make dev-requirements
RUN make

FROM alpine:3.11.2 AS production

RUN apk --no-cache add ca-certificates tzdata
COPY --from=development /chirpstack-network-server/build/chirpstack-network-server /usr/bin/chirpstack-network-server
RUN addgroup -S chirpstack_ns && adduser -S chirpstack_ns -G chirpstack_ns
USER chirpstack_ns
COPY configuration/chirpstack-network-server/chirpstack-network-server.toml /etc/chirpstack-network-server/chirpstack-network-server.toml
ENTRYPOINT ["/usr/bin/chirpstack-network-server"]
