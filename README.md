# static-extract-spec

**Language-neutral SER contract only.** No Java, TypeScript, React, or other
language runtime code lives here.

## What this repo is

| Path | Role |
|---|---|
| `ser/Ser.g4` | DSL **structure** grammar (skeleton keywords only) |
| `ser/SER_SPEC.md` | Structure semantics |
| `docs/CLEAN-G4.md` | Human summary of the public surface |
| `schema/*.json` | Output / IR / vocabulary **shapes** (string names, no language hard-coding) |
| `cli/extractor-cli.md` | Abstract CLI command contract |
| `COMMON_LAYER.md` | Boundary: what belongs here vs extractors |

## What this repo is not

- Not a Java or JS parser  
- Not Spring / React rule packs  
- Not language vocabulary catalogs (those live in each extractor)  
- Not examples for a specific language  

## Extractors (separate repos)

| Repo | Responsibility |
|---|---|
| [static-extract-java](https://github.com/praha-poseidon/static-extract-java) | Java/JDT free-atom vocabulary + execution + Java examples/skills |
| [static-extract-js](https://github.com/praha-poseidon/static-extract-js) | TS/JS free-atom vocabulary + execution + TS examples/skills |

Local sibling layout for development:

```text
codeGraphProjects/
  static-extract-spec/
  static-extract-java/
  static-extract-js/
```

## Grammar model

```text
Ser.g4 structure keywords:  rule find when let from take build …
Free atoms after find/from/when/take:  interpreted by each extractor
```

Details: [`docs/CLEAN-G4.md`](docs/CLEAN-G4.md)
