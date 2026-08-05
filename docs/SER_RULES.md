# SER Rule Guide

SER describes code shapes and output fields. The shared grammar is **structure
only** — see `docs/CLEAN-G4.md`.

Words after `find` / `from` / `when` / `take` are **free atoms**. Each extractor
interprets them via its vocabulary (Java/JDT, JS/TS, …).

## Extraction rule shape

```ser
rule "Readable Name"
fact fact_type

find <free atoms…>

when <free atoms…>          # optional, zero or more
when if <condition>         # optional expression form

let valueName =
  from <free atoms…> take <free atoms…>
  fallback "optional"

build {
  fieldName: expression
}
```

`endpoint LABEL DIRECTION` is still accepted as a rule target (legacy header).
Prefer `fact` for new rules.

## Structure vs vocabulary

| Structure (grammar) | Free atoms (vocabulary) |
|---|---|
| `rule` `fact` `find` `when` `let` `from` `take` `build` | `method` `jsx` `call` `annotation` `@GetMapping` `on` `attr` … |
| `fallback` `map` `concat` `normalize` | extractor-specific kinds and names |

## Java vocabulary examples

```ser
find method
when annotation @*Mapping on method

from annotation @RequestMapping on class take attr(value)
from argument[0] take value

find call RestTemplate.getForObject
find call RestTemplate.[getForObject,postForObject]
```

## JS/TS vocabulary examples

```ser
find jsx button
find call fetch
from prop onClick take value
from children take text
```

## Method declaration vs call

- Declaration: `find method` (+ optional `when annotation …`)
- Call site: `find call Owner.name` or `find call name`

See `docs/METHOD-VS-CALL.md`.

## Build

```ser
build {
  path: concat(a, b) | normalize slash
  method: httpMethod | map { GetMapping: GET }
}
```

## No compatibility layer

Old dialect forms (`find method with annotation`, `from annotation on method @X`,
`find method Owner.x` as sugar) are **rejected** by the public grammar. Rewrite
to the clean surface above.
