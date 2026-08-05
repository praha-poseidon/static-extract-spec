# SER Language Specification

SER is the Static Extract Rule language. The shared grammar (`Ser.g4`) defines
**structure only**. Free atoms after `find` / `from` / `when` / `take` are
interpreted by each extractor vocabulary. See `docs/CLEAN-G4.md`.

`Ser.g4` is the grammar source of truth. This document defines semantics that
grammar alone cannot express.

## Compatibility Terms

The words MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY are normative.

## File Types

SER has two top-level file types.

### Extraction Rule File

An extraction rule file MUST contain exactly one extraction rule:

```text
ruleDecl ruleTargetDecl findDecl whenDecl* letDecl* buildDecl EOF
```

Order is significant and MUST be:

```ser
rule "Readable Rule Name"
fact fact_type

find extractor selector

when optional extractor condition

let valueName =
  from extractor source take extractor value
  fallback "optional fallback"

build {
  fieldName: expression
}
```

`endpoint` MAY be used instead of `fact` for legacy endpoint rules, but new
cross-language rules SHOULD use `fact`.

### Trace Rule File

A trace rule file MUST contain one trace declaration and zero or more trace
entries:

```text
traceDecl traceEntry* EOF
```

Trace rules are extractor-specific extensions used to resolve external values or
language-specific value flows.

## Shared Syntax

These language constructs are shared by all extractors. They describe rule
structure and evaluation order; they do not parse source code by themselves.

```text
rule
fact
endpoint
find
when
let
from
take
default
map
build
concat
normalize
trace
regex
replace
```

Shared syntax defines structure only. Extractor vocabulary defines what a
selector means for a source language. Supporting TypeScript, Python, Java, or any
other language still requires a language-specific parser and extractor adapter.

## Extractor Vocabulary

Extractor vocabulary is the set of words an extractor understands inside `find`,
`from`, `take`, and `when`.

Examples:

```text
Java/JDT: method, class, field, annotation, argument, return, call, new
TS/TSX: jsx, component, prop, children, hook, import, route, call
Vue: component, template, directive, slot, event, binding, script
```

A SER parser MUST preserve vocabulary as structured names when the grammar
accepts it. An extractor MUST validate whether it supports that vocabulary before
or during execution. Unsupported vocabulary SHOULD produce a diagnostic. It MAY
produce an empty result only when no anchors matched; it MUST NOT silently produce
incorrect fields.

Extractor vocabulary SHOULD be declared with:

```text
schema/extractor-vocabulary.schema.json
```

The vocabulary manifest is a support matrix for docs, diagnostics, and
conformance. It is not a replacement for a source-language parser.

## Rule IR

Extractors MAY expose or internally use a language-neutral rule IR after parsing
SER. The shared IR schema is:

```text
schema/rule-ir.schema.json
```

The IR preserves extractor vocabulary as strings. It should not require a Java,
TypeScript, Python, or other language enum for every possible `find`, `from`,
`take`, or `when` word.

Example mapping:

```ser
find call fetch
```

```json
{
  "kind": "call",
  "name": "fetch",
  "conditions": []
}
```

Language adapters are responsible for mapping that selector onto their own AST:
TypeScript may map it to a `CallExpression`, Python may map it to `ast.Call` or
LibCST `Call`, and Java may map it to a JDT `MethodInvocation`.

## Rule Metadata

### `rule`

`rule` declares a human-readable name.

```ser
rule "React Button Action"
```

The rule name MUST be included in every emitted fact as `rule`.

### `fact`

`fact` declares the output fact type.

```ser
fact ui_action
```

The fact type MUST be included in every emitted fact as `factType`.

Fact type values are identifiers. The spec does not hard-code a closed list, but
extractors and rule packs SHOULD prefer stable, lower-case snake-case names.

### `endpoint`

`endpoint` is a legacy rule target:

```ser
endpoint HTTP inbound
```

Extractors MUST expose endpoint labels as classifiers:

```json
{
  "category": "HTTP",
  "direction": "inbound"
}
```

For compatibility, extractors MAY derive `factType` from endpoint labels. New
rules SHOULD use explicit `fact`.

## Find

`find` selects the anchor locations where a rule runs.

```ser
find method
when annotation @GetMapping on method

find call RestTemplate.getForObject
find jsx Button
find export [GET,POST]
```

Legacy sugar forms are **not** supported. Authors must use the clean surface in `docs/CLEAN-G4.md`.

Extractor vocabularies MAY support a bracketed name list after `find`. A list is
equivalent to running the same selector once per listed name and may emit
multiple facts from one rule.

Each matched anchor MAY emit zero, one, or multiple facts, depending on value
cardinality during `build`.

If `find` matches nothing, the rule emits no facts.

## When

`when` filters matched anchors or trace targets.

SER supports two compatible condition styles.

The legacy phrase style is intentionally small:

```ser
when call owner router
when call name get
when field type String
when annotation @Config on field
```

The expression style is used for general filtering:

```ser
when if call.owner == router
when if call.name in [get,post,put]
when if argument[0].value matches "^/api/"
when if prop.disabled exists
when if not prop.disabled exists
when if call.owner == router and call.name != delete
when if (call.owner == router or call.owner == app) and call.name in [get,post]
```

Supported expression operators are:

```text
and
or
not
==
!=
matches
contains
in
exists
```

Condition paths are extractor vocabulary paths. A SER parser preserves the path;
the extractor decides how to evaluate it against the current anchor or trace
target. For example, a TypeScript extractor may understand `prop.disabled`, while
a Python extractor may understand `keyword.timeout`.

Unsupported condition paths or operators SHOULD produce diagnostics. They MUST
NOT silently include anchors that should have been filtered out.

## Let

`let` declares a named value.

```ser
let path =
  from annotation @GetMapping on method take attr(value)
  from annotation @GetMapping on method take attr(path)
  fallback ""
```

Each `let` MUST contain one or more `from ... take ...` sources.

Sources are evaluated in order. The first source that yields one or more values
wins. Later sources MUST NOT be evaluated for the same `let` after a value is
found, except for diagnostics.

If no source yields a value and `default` is present, the default value is used.
If no source yields a value and no `default` is present, the value is empty.

## From

`from` selects a source relative to the current anchor.

```ser
from annotation @Route on method take attr(value)
from argument[0] take value
from children take text
from prop onClick take reference
```

The grammar currently includes compatibility forms for common Java-oriented
sources and generic forms for extractor vocabulary. Non-Java extractors SHOULD
use generic forms when their vocabulary is not represented by a compatibility
branch. Future SER versions should prefer the generic IR model over adding a
dedicated grammar branch for every language feature.

## Take

`take` selects what to read from a source.

Shared take names include:

```text
name
value
raw
type
owner
signature
attr(...)
```

Extractor-specific take names are allowed:

```ser
from children take text
from prop onClick take reference
```

`take raw` MUST mean source text or extractor-native surface representation.

`take value` MUST mean semantic value after extractor-supported static tracing.
The tracing depth and language features are extractor-specific, but extractors MUST
document their supported value tracing behavior.

`take attr(a,b,c)` MUST try attributes in the listed order and return the first
attribute that exists and has a value.

## Map

A `map` block on a `let` maps raw extracted values to normalized values.

```ser
let httpMethod =
  from annotation @*Mapping on method take name
  map {
    GetMapping: GET
    PostMapping: POST
  }
```

If a value exists in the map, it MUST be replaced with the mapped value.
If a value does not exist in the map, it SHOULD remain unchanged.

Pipeline `map` has the same value-mapping semantics and applies at build time.

## Build

`build` declares output fields.

```ser
build {
  method: httpMethod
  path: concat(basePath, "/", methodPath) | normalize slash
}
```

Only fields declared in `build` appear inside the emitted fact's `fields`
object. Extractors MUST NOT add framework-specific fields to `fields` unless the
rule declared them.

Build field names are identifiers. Values are strings. An extractor MAY skip a
field when the expression resolves to no value, but it MUST NOT invent a value.

If a build expression produces multiple values, extractors MAY emit multiple
facts. All emitted facts MUST preserve the same stable envelope and differ only
where expression values differ.

## Expressions

Build expressions are:

```text
string literal
let reference
concat(...)
```

`concat` joins string values in order. If any input has multiple values,
extractors SHOULD produce the cross-product in stable order.

## Pipelines

Pipeline steps transform build expression values:

```ser
path: raw | regex "path=(.*)" group 1 | replace "\\s+" "" | normalize slash
```

Pipeline steps run left to right.

Supported shared pipeline operators are:

```text
normalize IDENT
regex STRING group INT
replace STRING STRING
map { ... }
```

Normalizer names are extractor-defined. An extractor MUST document its supported
normalizers. Unsupported normalizers MUST produce a diagnostic or leave the value
unchanged with a warning; they MUST NOT corrupt the value silently.

## Comments And Whitespace

Whitespace separates tokens and is otherwise not semantically significant.

Line comments start with `#` or `//`.

Block comments use `/* ... */`.

Comments MUST NOT affect rule semantics.

## Output Contract

Every emitted fact MUST validate against:

```text
schema/extracted-fact.schema.json
```

The stable envelope is:

```json
{
  "rule": "Rule Name",
  "factType": "fact_type",
  "classifiers": {},
  "fields": {},
  "projectFilePath": "relative/path",
  "absoluteFilePath": "/absolute/path",
  "startLine": 1,
  "endLine": 1,
  "enclosingSymbol": "symbolName"
}
```

`classifiers` contains rule target labels and other stable classification data.
`fields` contains only rule-built fields.

## Diagnostics

Extractors SHOULD provide diagnostics when:

- the parser rejects a SER file;
- an extractor vocabulary item is unsupported;
- a `take` operation is unsupported for a matched source;
- a pipeline operator or normalizer is unsupported;
- a rule matches anchors but cannot build any fields.

Diagnostics are extractor-specific and are not part of the extracted fact schema.

## Conformance Fixtures

Shared examples under `spec/examples/` are executable compatibility fixtures.
An extractor SHOULD publish a conformance manifest listing the fixtures it
supports:

```text
schema/conformance-manifest.schema.json
```

Extractors SHOULD run supported fixtures in CI and compare produced JSONL with
`expected.jsonl`. A fixture for another source language MAY be marked
`unsupported`; a fixture for the extractor's own language SHOULD be either
`required` or accompanied by a clear reason.

## Conformance

An extractor conforms to this spec when it:

- parses `ser/Ser.g4` or a grammar generated from it;
- preserves and validates extractor vocabulary;
- can map SER into the language-neutral rule concepts described by
  `schema/rule-ir.schema.json`;
- follows the `let`, `default`, `map`, `build`, and pipeline semantics in this
  document;
- emits JSONL records that validate against
  `schema/extracted-fact.schema.json`;
- exposes a CLI compatible with `spec/cli/extractor-cli.md`.
