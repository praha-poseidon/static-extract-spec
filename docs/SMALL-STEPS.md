# Project status

## Done

- Split into `static-extract-spec`, `static-extract-java`, `static-extract-js`
- Public `Ser.g4` is **structure-only** (free atoms for vocabulary)
- No SER dialect clean grammar / compatibility layer
- Skills, examples, and main docs aligned to `CLEAN-G4.md`

## Canonical docs

| Doc | Purpose |
|---|---|
| `docs/CLEAN-G4.md` | Public grammar surface |
| `COMMON_LAYER.md` | What the common layer owns |
| `schema/*` | IR / fact / vocabulary schemas (vocabulary names are strings) |
| `cli/extractor-cli.md` | CLI contract |
| `skills/**` | Agent authoring helpers |

## Optional later

- Publish extractor-vocabulary JSON manifests next to each CLI
- Unify Java internal models to export Rule IR JSON 1:1
- CI workflows (requires GitHub token with `workflow` scope)
