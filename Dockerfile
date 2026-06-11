# syntax=docker/dockerfile:1

# 1. Generate the documentation + RDF serializations + .htaccess with WIDOCO.
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /src
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
COPY scripts/ scripts/
COPY vocabulary/ vocabulary/
RUN sh scripts/generate.sh

# 2. Serve the generated site with Apache content negotiation.
FROM httpd:2.4-alpine
# Enable the modules the WIDOCO .htaccess relies on.
RUN sed -i \
    -e 's|^#\(LoadModule rewrite_module .*\)|\1|' \
    -e 's|^#\(LoadModule negotiation_module .*\)|\1|' \
    -e 's|^#\(LoadModule headers_module .*\)|\1|' \
    conf/httpd.conf \
    && printf '\nInclude conf/extra/def.conf\n' >> conf/httpd.conf
COPY apache/def.conf conf/extra/def.conf
COPY --from=builder /src/build/ htdocs/
EXPOSE 80
