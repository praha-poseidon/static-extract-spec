# Static Extract Common Layer

Owns the **language-neutral** SER contract only:

- `ser/Ser.g4`, `ser/SER_SPEC.md`
- JSON schemas under `schema/`
- CLI contract, shared examples
- Public surface: `docs/CLEAN-G4.md`

Does **not** own:

- Language parsers (JDT, ts-morph, …)
- AST execution
- Compatibility shims for old SER dialects

Extractors implement the clean grammar directly. No shared desugar layer.
