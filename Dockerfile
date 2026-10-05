# Built by .github/workflows/deploy.yml (context ., file Dockerfile) and pushed
# to Artifact Registry.
#
# A job image, not a server: the default command runs scripts/check.sh
# (`consul validate config/`) and exits 0 when the configuration is valid.
# It starts no agent, publishes nothing and never listens on $PORT. To run the
# agent from this config instead: `consul agent -config-dir=/app/config`.

FROM hashicorp/consul:2.0.4 AS runtime
ARG BUILD_ID=""
ENV BUILD_ID=$BUILD_ID HOME=/home/app
RUN adduser -D -u 10001 -h /home/app app \
 && mkdir /app && chown app:app /app
WORKDIR /app
COPY --chown=app:app . .
USER app
# the base image's ENTRYPOINT starts an agent; the job is a script
ENTRYPOINT []
CMD ["sh", "scripts/check.sh"]
