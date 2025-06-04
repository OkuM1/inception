FROM alpine:3.21

RUN apk add nginx tini --no-cache

COPY conf/default.conf /etc/nginx

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/bin/nginx", "-g", "daemon-off"]
