# Public SER grammar (final surface)

This is the **clean public** `Ser.g4` contract. Language extractors may desugar
legacy authoring forms before parse; those forms are **not** part of the shared
grammar.

## rule / trace skeleton

```text
rule "name"
fact type_name          # or: endpoint LABEL direction

find …
when …                  # zero or more
let … = from … take …
build { … }

trace "name"
from <traceTarget>
when …
let …
build { … }
```

## find (only two shapes)

```ser
find call Owner.name
find call Owner.[a,b,c]
find <kind> <selector>?
```

`<kind>` is vocabulary (e.g. `method`, `jsx`, `export`, `field`, `call`, …).

## from (only these shapes)

```ser
from annotation @Name on method|class|field|parameter
from decorator Name on method|class|field|parameter
from argument[0]
from new Qualified.Name
from literal "x"
from <kind> <name>?
```

## when (shared conditions)

```ser
when if <condition>
when annotation @X on method|class|field|parameter
when method Owner.name
when call Owner.name
when field name x | when field type T
when parameter name x | when parameter type T
when method name x | when call name x | when call owner Q
when assignment field x
```

These are **shared** extract/trace conditions, not Java-only dialect.

## take / build

```ser
take name | value | raw | type | owner | signature | attr(...)
build {
  field: expr | normalize ident | regex "…" group N | replace "a" "b" | map { … }
}
```

## Legacy (desugar only — Java and JS)

| Legacy text | Becomes |
|---|---|
| `find X with annotation @Y` | `find X` + `when annotation @Y on X` |
| `from annotation on elem @Y` | `from annotation @Y on elem` |
| `from decorator on elem Name` | `from decorator Name on elem` |
| `find method Owner.x` | `find call Owner.x` |

## Not in public g4

- `with` keyword (removed)
- Java-only exclusive find productions beyond the surface above
