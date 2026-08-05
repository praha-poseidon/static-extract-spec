# Extractor CLI contract

Each language extractor owns its CLI binary. This document only defines the
shared **command shape**.

## Naming

```text
static-extract-<extractor-id>
```

## Commands

```text
init
try
diagnose
run
```

## Shared arguments (concepts)

```text
--project        project root
--source         source file or directory
--rule           SER rule file
--rule-dir       SER rule directory
--out            JSONL output file
```

Extractor-specific flags (classpath, tsconfig, aliases, …) are defined by each
extractor, not by this package.

## Output

`run` writes newline-delimited JSON. Each line MUST validate against
`schema/extracted-fact.schema.json` in this repository.
