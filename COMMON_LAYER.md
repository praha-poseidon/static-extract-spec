# Static Extract Common Layer

## Owns

- SER **skeleton** grammar: `ser/Ser.g4` (structure keywords only)
- Semantics of the skeleton: `ser/SER_SPEC.md`, `docs/CLEAN-G4.md`
- Output / IR / vocabulary **schemas** (shapes, not language words)
- Shared examples and CLI contract

## Does not own

- What `method`, `jsx`, `annotation`, `call`, … mean  
  → each extractor’s vocabulary + AST adapter
- Source parsers (JDT, ts-morph, …)
- Compatibility rewrites of old SER dialects

## Execution model

```text
.ser text
  → shared SER parse (structure + free atoms as text)
  → extractor vocabulary / free-form interpreter
  → language AST match
  → extracted facts (JSON)
```
