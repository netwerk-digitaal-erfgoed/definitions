# NDE definitions (def.nde.nl)

Source for the RDF vocabularies published under
[`https://def.nde.nl/`](https://def.nde.nl/) by
[Netwerk Digitaal Erfgoed](https://netwerkdigitaalerfgoed.nl/).

Each module is a small vocabulary whose terms are minted and used by the
[dataset knowledge graph](https://github.com/netwerk-digitaal-erfgoed/dataset-knowledge-graph):

| Module | Namespace | What it covers |
| --- | --- | --- |
| `probe` | `https://def.nde.nl/probe#` | Capabilities detected in a dataset (e.g. whether it exposes media). |
| `metric` | `https://def.nde.nl/metric#` | DQV quality metrics computed per dataset. |
| `pid-scheme` | `https://def.nde.nl/pid-scheme#` | Persistent identifier schemes recognised in subject URIs. |
| `iiif` | `https://def.nde.nl/iiif#` | Terms used when sampling and validating IIIF resources. |
| `failure` | `https://def.nde.nl/failure#` | The `failure:reason` predicate recording why an individual sampled resource failed. |
| `subject-resolution-failure` | `https://def.nde.nl/subject-resolution-failure#` | Reasons a sampled subject URI failed to resolve. |
| `manifest-validation-failure` | `https://def.nde.nl/manifest-validation-failure#` | Reasons a sampled IIIF manifest failed validation (mirrors the `@lde/iiif-validator` reason enum). |

The vocabularies use **hash URIs**, so each module is a single document: the
term `probe#detects` is defined in the document served at `/probe`, and the
fragment selects the term in the page.

## How it is published

`scripts/generate.sh` runs [WIDOCO](https://github.com/dgarijo/Widoco) over
each `vocabulary/*.ttl` file to produce, per module:

- a human-readable HTML specification (with a description per term),
- RDF serializations: Turtle, N-Triples, RDF/XML and JSON-LD,
- a `.htaccess` that content-negotiates between them on the `Accept` header.

The `Dockerfile` runs that generation and serves the result with Apache, which
honours the generated `.htaccess` so that a browser gets HTML while a client
asking for `text/turtle`, `application/rdf+xml`, `application/n-triples` or
`application/ld+json` gets that serialization. The image is built and pushed to
`ghcr.io/netwerk-digitaal-erfgoed/definitions` by CI and deployed to the SURF
Kubernetes cluster behind `def.nde.nl`.

## Local development

Generate the documentation (requires Java 17 or newer):

```sh
sh scripts/generate.sh
```

Output appears in `build/<module>/`; open `build/probe/index-en.html` in a
browser to preview.

Build and run the full server locally:

```sh
docker build -t definitions .
docker run --rm -p 8080:80 definitions
```

Then negotiate against a module, for example:

```sh
curl -H 'Accept: text/turtle' http://localhost:8080/probe/
curl -H 'Accept: application/ld+json' http://localhost:8080/probe/
```

## Adding or changing a term

1. Edit the relevant `vocabulary/*.ttl` file (or add a new module file).
2. Give every term an `rdfs:label` and a description (`rdfs:comment`, or
   `skos:definition` for SKOS concepts and DQV metrics) – these become the
   human-readable text in the generated page.
3. Bump `owl:versionInfo` on the module’s `owl:Ontology`.
4. Open a pull request; CI rebuilds the image.
