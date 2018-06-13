FROM alpine:3.7

RUN apk --no-cache add \
    bash \
    curl \
    ffmpeg

# Add entrypoint shell script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

## Make sure input and output folders exist
RUN mkdir -p /input /output

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
