# Extractor CLI Contract

Each language extractor owns its own CLI. A Java CLI must not shell out to a
TypeScript extractor, and a TypeScript CLI must not depend on a Java jar.

## Naming

Extractor CLIs use this shape:

```text
static-extract-<extractor>
```

Examples:

```text
static-extract-java
static-extract-ts
static-extract-vue
```

## Commands

All extractor CLIs should expose these commands:

```text
init
try
diagnose
run
```

## Output

`run` writes newline-delimited JSON. Each line must validate against
`spec/schema/extracted-fact.schema.json`.

`try` may return a command report, but its `results` field must contain the same
`ExtractedFact` shape.

## Required Arguments

Each extractor can choose extractor-specific input flags, but these concepts must
exist:

```text
--project        project root
--source         source file or source directory
--rule           SER rule file
--rule-dir       SER rule directory
--out            JSONL output file
```

Extractor-specific examples:

```text
static-extract-java --classes target/classes --dependency target/dependency
static-extract-ts --tsconfig tsconfig.json
static-extract-vue --alias @=src
```

The extractor-specific flags affect extraction accuracy, not the output contract.

Extractors MAY keep older aliases such as `--rules` or `--file`, but
documentation and skills SHOULD prefer the shared names above.
