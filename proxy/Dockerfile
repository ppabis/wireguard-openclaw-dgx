FROM alpine:latest

RUN apk add tinyproxy
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
EXPOSE 8888
ENTRYPOINT ["/usr/bin/tinyproxy"]
CMD ["-d"]