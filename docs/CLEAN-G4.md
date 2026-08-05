# Clean public Ser.g4 surface

After grammar cleanup, the **shared** grammar is intentionally small.

## find

```text
find call Owner.name
find call Owner.[a,b]
find <kind> <selector>?
```

Examples: `find method`, `find jsx button`, `find call fetch`, `find field url`.

Removed from public g4 (desugared by Java/JS when needed):

- `find X with annotation @Y`
- `find method Owner.name` (→ `find call Owner.name`)
- dedicated `find class` / `find field name` productions (use generic `find class` / `find field name`)

## from

```text
from annotation @X on method|class|field|parameter
from decorator Name on class|method|…
from argument[i]
from new Qualified.Name
from literal …
from <kind> <name>?
```

Removed legacy on-first annotation/decorator orders from public g4.

## when

Still includes specialized forms used by extract/trace (`when annotation`, `when method`,
`when if`, …). These are **shared condition vocabulary**, not Java-only sugar.
Further unification to only `when if` is optional future work.

## Desugar

| Form | Java | JS |
|---|---|---|
| `find X with annotation @Y` | yes | yes |
| `from annotation on elem @Y` | yes | yes |
| `from decorator on elem Name` | yes | yes |
| `find method Owner.x` | yes | yes |
