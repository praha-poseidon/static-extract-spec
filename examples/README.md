# Static Extract Spec Examples

These examples are executable compatibility fixtures for extractor
implementations. Each example contains:

- `input/`: source files used by the extractor.
- `rule.ser`: the SER rule under test.
- `expected.jsonl`: the expected extracted fact output.

Extractor test suites SHOULD run the examples for their supported languages and
compare the produced JSONL with `expected.jsonl`. Values in `expected.jsonl`
may use `${EXAMPLE_DIR}` for the absolute path of the example directory.

## Language Layout

Examples are grouped by extractor language:

- `java/`: examples that Java/JDT extractors are expected to execute.
- `ts/`: future examples for TypeScript-family extractors.
- `common/`: future parser and output examples that do not require a specific
  language AST.

Language-specific examples may use extractor-specific source vocabulary. The SER
grammar is shared, but words such as `method`, `field`, `jsx`, or `element`
only become meaningful when an extractor implements them.

