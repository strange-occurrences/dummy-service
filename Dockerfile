FROM alpine:3.19

RUN apk add --no-cache curl bash

COPY bin/webhook /usr/local/bin/webhook
COPY hooks/ /etc/webhook/hooks/

EXPOSE 9000

ENTRYPOINT ["webhook"]
CMD ["-hooks", "/etc/webhook/hooks", "-port", "9000"]
