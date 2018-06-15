FROM alpine

RUN apk add --update \
    bash \
    openssh-client \
  && rm -rf /var/cache/apk/*

COPY deployrpms.sh /deployrpms.sh
