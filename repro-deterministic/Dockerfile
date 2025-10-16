# Pinned, small, stable base
FROM debian:12.6-slim

# Deterministic environment
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    # fixed build time used by many tools
    SOURCE_DATE_EPOCH=1710000000

# Pin packages (avoid "latest") & avoid recommends
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates=20230311 && \
    rm -rf /var/lib/apt/lists/*

# Add content with fixed permissions/owner
WORKDIR /app
COPY --chown=0:0 reproducible.txt /app/reproducible.txt
RUN chmod 0644 /app/reproducible.txt
