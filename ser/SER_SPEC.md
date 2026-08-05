# SER Language Specification (structure)

Normative terms: MUST, MUST NOT, SHOULD, SHOULD NOT, MAY.

## Role of the shared grammar

`Ser.g4` defines **file shape and structure keywords only**.

It MUST NOT encode language-specific notions (what any programming-language construct is). Those meanings are defined by each extractor’s vocabulary.

Free atoms after `find`, `when`, `from`, and `take` MUST be preserved as opaque
token sequences for the extractor.

## File types

### Extraction rule

```text
ruleDecl ruleTargetDecl findDecl whenDecl* letDecl* buildDecl EOF
```

```ser
rule "Readable name"
fact fact_type

find <free-atoms>

when <free-atoms>
when if <condition>

let name =
  from <free-atoms> take <free-atoms>
  fallback <free-atom>

build {
  field: expression
}
```

`endpoint LABEL DIRECTION` MAY be used instead of `fact` for older rule headers.
New rules SHOULD use `fact`.

### Trace rule

```text
traceDecl traceEntry* EOF
```

Each `traceEntry` is:

```text
FROM free-atoms whenDecl* letDecl* buildDecl
```

## Shared structure constructs

The shared layer defines evaluation order for:

- ordered `from` fallbacks in a `let`
- `build` field assembly, `concat`, and pipeline steps (`normalize`, `regex`,
  `replace`, `map`)
- `when if` boolean expressions over free paths

It does **not** define which free-atom paths exist; extractors do.

## Output

Extractors MUST emit records conforming to `schema/extracted-fact.schema.json`.

## Conformance

An extractor is conformant if it:

1. Parses `Ser.g4` structure correctly  
2. Rejects invalid structure  
3. Interprets free atoms only through a declared vocabulary  
4. Emits valid extracted-fact JSON  

Language-specific fixtures live in the extractor repositories, not here.
