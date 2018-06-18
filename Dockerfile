FROM alpine

RUN apk add --update \
    bash \
    openssh-client \
  && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh

CMD "/entrypoint.sh"
