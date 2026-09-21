#!/usr/bin/env sh
# Publish the Schema.org JSON-LD context that the Dataset Register reads dataset
# descriptions with, at https://def.nde.nl/context.jsonld.
#
# Schema.org release 30.1 removed the type coercions from its own published context, so
# `mainEntityOfPage` and `license` stopped expanding to IRIs and the date properties to
# dates. Because a JSON-LD parser fetches that context while parsing, the change reached
# every consumer without anyone deploying anything. This context carries the coercions
# itself and imports nothing, so that cannot happen again through it.
#
# The file has one source of truth: `packages/core/src/schema-org-context.json` in the
# dataset-register repository, where the SHACL shapes it pairs with live. We fetch it here
# rather than keeping a second copy, so the two cannot drift.
#
# It is pinned to a commit on purpose. Anything that imports this context – the NDE
# Schema.org application profile, and third parties validating their own descriptions –
# would otherwise see its parsing semantics change the moment the register's copy changed.
# Bumping CONTEXT_REF is how a change here becomes deliberate: it is a commit, a pull
# request and an image build, not a silent update.
set -eu

CONTEXT_REPO="netwerk-digitaal-erfgoed/dataset-register"
CONTEXT_REF="3d3af40a8d8cb807e1da1478b794b9ddfb2e890f"
CONTEXT_PATH="packages/core/src/schema-org-context.json"

ROOT="$(CDPATH= cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

mkdir -p build
echo "Fetching ${CONTEXT_PATH} from ${CONTEXT_REPO}@${CONTEXT_REF}..."
curl -fsSL \
  -o build/context.jsonld \
  "https://raw.githubusercontent.com/${CONTEXT_REPO}/${CONTEXT_REF}/${CONTEXT_PATH}"

# A 404 from raw.githubusercontent.com is caught by `curl -f`, but a ref that resolves to
# something that is not our context would not be. Fail the build rather than publish it.
for required in '"@vocab": "https://schema.org/"' '"mainEntityOfPage"' '"@type": "@id"'; do
  if ! grep -qF "${required}" build/context.jsonld; then
    echo "ERROR: build/context.jsonld does not contain ${required}" >&2
    exit 1
  fi
done
if grep -qF '"@import"' build/context.jsonld; then
  echo "ERROR: build/context.jsonld has an @import; it must resolve on its own" >&2
  exit 1
fi

echo "Done. Published as /context.jsonld."
