# Proxy for sandbox web traffic. claude-sandbox runs two: an open one for
# internet on, and one limited to /etc/tinyproxy/allow (FILTER=1) for off.
FROM alpine:3

RUN apk add --no-cache tinyproxy

COPY start.sh /start.sh
CMD ["/bin/sh", "/start.sh"]
