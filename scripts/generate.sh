#!/usr/bin/env sh
# Generate human-readable documentation and RDF serializations for every
# vocabulary module under vocabulary/, plus a per-module .htaccess that
# content-negotiates between HTML and the RDF serializations.
set -eu

WIDOCO_VERSION="1.4.25"
WIDOCO_JAR="widoco-${WIDOCO_VERSION}-jar-with-dependencies_JDK-17.jar"
WIDOCO_URL="https://github.com/dgarijo/Widoco/releases/download/v${WIDOCO_VERSION}/${WIDOCO_JAR}"

ROOT="$(CDPATH= cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

mkdir -p .widoco build
if [ ! -f ".widoco/${WIDOCO_JAR}" ]; then
  echo "Downloading WIDOCO ${WIDOCO_VERSION}..."
  curl -fsSL -o ".widoco/${WIDOCO_JAR}" "${WIDOCO_URL}"
fi

for ontology in vocabulary/*.ttl; do
  module="$(basename "${ontology}" .ttl)"
  echo "Generating documentation for ${module}..."
  rm -rf "build/${module}"
  java -jar ".widoco/${WIDOCO_JAR}" \
    -ontFile "${ontology}" \
    -outFolder "build/${module}" \
    -rewriteAll \
    -htaccess \
    -uniteSections \
    -includeAnnotationProperties \
    -lang en \
    -noPlaceHolderText \
    -webVowl
done

echo "Done. Generated documentation in build/."
