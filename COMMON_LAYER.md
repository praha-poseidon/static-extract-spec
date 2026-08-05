# Static Extract Common Layer

This document defines the reusable layer that can later live in a standalone
`static-extract-spec` repository.

The common layer is intentionally small. It lets Java, TypeScript, Python, and
future extractors share rules, output contracts, fixtures, and conformance tests
without sharing one source parser or one runtime.

## Owns

The common layer owns these stable contracts:

- SER grammar: `ser/Ser.g4`
- SER semantics: `ser/SER_SPEC.md`
- Rule IR schema: `schema/rule-ir.schema.json`
- Extracted fact schema: `schema/extracted-fact.schema.json`
- Rule pack manifest schema: `schema/rule-manifest.schema.json`
- Extractor vocabulary schema: `schema/extractor-vocabulary.schema.json`
- Conformance manifest schema: `schema/conformance-manifest.schema.json`
- CLI contract: `cli/extractor-cli.md`
- Cross-extractor examples: `examples/`

## Does Not Own

The common layer must not contain:

- Java/JDT, TypeScript, Python, Vue, or other source parser implementations.
- AST traversal code.
- Type checker or symbol resolver integrations.
- Language-specific value tracing.
- Runtime framework simulation.
- Extractor-private rule packs that cannot run anywhere else.

## Execution Model

```text
SER file
  -> SER parser
  -> Rule IR
  -> extractor vocabulary validation
  -> language parser and language adapter
  -> extracted facts
```

SER describes extraction intent. A language extractor decides how vocabulary such
as `method`, `call`, `jsx`, `prop`, `decorator`, `argument`, or `keyword` maps to
its own AST and semantic model.

**Note:** `ser/Ser.g4` still contains some Java-oriented sugar productions
(`find method with annotation …`, `from annotation on method …`, etc.). Those are
scheduled to move to `static-extract-java` desugar. See
`docs/CORE-VS-JAVA-DIALECT.md` and `docs/SMALL-STEPS.md`.

## Rule IR

The rule IR is the language-neutral shape produced after parsing SER. It should
preserve extractor vocabulary as strings instead of converting every term to a
Java, TypeScript, or Python enum.

Extractor implementations may use richer internal models, but they should be
able to explain or export the same logical structure:

```json
{
  "kind": "rule",
  "name": "Fetch API Call",
  "target": {
    "type": "fact",
    "factType": "frontend_api_call"
  },
  "find": {
    "kind": "call",
    "name": "fetch",
    "conditions": [
      {
        "kind": "compare",
        "path": ["argument", 0, "value"],
        "op": "matches",
        "value": "^/api/"
      }
    ]
  },
  "lets": [
    {
      "name": "path",
      "sources": [
        {
          "kind": "argument",
          "index": 0,
          "take": {
            "kind": "value"
          }
        }
      ]
    }
  ],
  "build": {
    "fields": [
      {
        "name": "path",
        "expression": {
          "kind": "reference",
          "value": "path"
        },
        "pipeline": []
      }
    ]
  }
}
```

Condition expressions are part of the common IR. They are still evaluated by each
extractor because paths such as `call.owner`, `prop.disabled`, `argument[0].value`,
or `keyword.timeout` are vocabulary-specific.

## Vocabulary Contract

Each extractor should publish a vocabulary manifest. The manifest is not a parser;
it is a support matrix for diagnostics, docs, and conformance.

Example:

```json
{
  "extractor": "python-libcst",
  "version": "0.1.0",
  "language": "python",
  "find": [
    {
      "name": "call",
      "selectors": ["name", "qualified-name"],
      "takes": ["name", "owner", "raw", "value"]
    },
    {
      "name": "function",
      "selectors": ["name"],
      "takes": ["name", "raw"]
    }
  ],
  "source": [
    {
      "name": "argument",
      "selectors": ["index"],
      "takes": ["value", "raw"]
    },
    {
      "name": "keyword",
      "selectors": ["name"],
      "takes": ["value", "raw"]
    }
  ],
  "take": [
    { "name": "name" },
    { "name": "value" },
    { "name": "raw" }
  ]
}
```

Unsupported vocabulary should produce diagnostics. It should not silently become
an empty result when the rule matched anchors and the user likely made a spelling
or vocabulary mistake.

## Conformance

Shared fixtures under `examples/` are compatibility tests, not documentation-only
samples. An extractor should publish a conformance manifest that lists the
fixtures it supports:

```json
{
  "extractor": "ts",
  "specVersion": "0.1.0",
  "fixtures": [
    { "path": "ts/api-call", "status": "required" },
    { "path": "ts/react-button-text", "status": "required" },
    { "path": "java/annotation-fact", "status": "unsupported", "reason": "Different source language" }
  ]
}
```

This keeps extractor repositories independent while still tying them to one
machine-checkable spec.

## Repository Split

If the project is split later, the recommended shape is:

```text
static-extract-spec
  spec files, schemas, examples, conformance runner

static-extract-java-jdt
  Java/JDT parser adapter and CLI

static-extract-ts
  TypeScript parser adapter and CLI

static-extract-python
  Python parser adapter and CLI
```

The spec repository can be packaged for multiple ecosystems as resource-only
artifacts. The important part is that all packages contain the same versioned
spec files.
