# static-extract-spec

Language-neutral contracts for **Static Extract**: SER grammar, semantics, JSON
schemas, CLI shape, and shared conformance examples.

This repository is **not** a source-code parser. Java and JS extractors implement
this contract in their own runtimes.

最终对应独立 git 项目；当前与同级的 `static-extract-java`、`static-extract-js`
并排放在工作区中联调。

## Layout

```text
ser/
  Ser.g4              SER grammar (ANTLR source of truth)
  SER_SPEC.md         language semantics
schema/
  extracted-fact.schema.json
  rule-ir.schema.json
  rule-manifest.schema.json
  extractor-vocabulary.schema.json
  conformance-manifest.schema.json
cli/
  extractor-cli.md    CLI contract for all extractors
examples/
  java/               Java conformance fixtures
  ts/                 JS/TS conformance fixtures
skills/               Agent skills that author SER (optional tooling)
docs/                 SER / rule-engine docs
COMMON_LAYER.md       what belongs here vs language repos
```

## Sibling extractors

Expected workspace layout while developing:

```text
codeGraphProjects/
  static-extract-spec/    ← this repo
  static-extract-java/    Java/JDT extractor
  static-extract-js/      JS/TS extractor
```

Extractors resolve this package by:

1. Environment variable `STATIC_EXTRACT_SPEC`, or
2. Sibling path `../static-extract-spec`

## What this owns / does not own

**Owns:** SER structure, Rule IR shape, fact JSON envelope, vocabulary manifest
schema, CLI command shape, shared examples.

**Does not own:** JDT, ts-morph, AST traversal, language-specific sugar, framework
rule packs (Spring, React, …).

See `COMMON_LAYER.md` for the full boundary.

## Consumers

| Project | How it uses this repo |
|---|---|
| `static-extract-java` | Copies `ser/Ser.g4` at build time; tests read `schema/` and `examples/java/` |
| `static-extract-js` | Generates TS parser from `ser/Ser.g4`; tests read `schema/` and `examples/ts/` |

Stable cross-language integration is **JSON**, not a shared runtime jar.

## Grammar model

- **Structure only**: [docs/CLEAN-G4.md](docs/CLEAN-G4.md)
- **Common boundary**: [COMMON_LAYER.md](COMMON_LAYER.md)
- **Status**: [docs/SMALL-STEPS.md](docs/SMALL-STEPS.md)
- **Method vs call (vocabulary)**: [docs/METHOD-VS-CALL.md](docs/METHOD-VS-CALL.md)

`method` / `class` / `jsx` after `find` are **free atoms**, not grammar keywords.
Each extractor defines their meaning in its vocabulary.
