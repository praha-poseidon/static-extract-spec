# Public SER grammar (only supported surface)

There is **no legacy compatibility layer**. Rules must match this grammar exactly
or parsers will reject them.

## Skeleton

```text
rule "name"
fact type_name          # or: endpoint LABEL direction
find …
when …*                 # optional
let …*
build { … }

trace "name"
from <traceTarget>
when …*
let …*
build { … }
```

## find

```ser
find call Owner.name
find call Owner.[a,b]
find <kind> <selector>?
```

## from

```ser
from annotation @X on method|class|field|parameter
from decorator Name on method|class|field|parameter
from argument[i]
from new Qualified.Name
from literal "…"
from <kind> <name>?
```

## when

```ser
when if <condition>
when annotation @X on method|class|field|parameter
when method Owner.name | when call Owner.name
when field name x | when field type T
when parameter name x | when parameter type T
when method name x | when call name x | when call owner Q
when assignment field x
```

## Not supported (will fail parse)

```text
find method with annotation @X
from annotation on method @X
from decorator on class Name
find method Owner.name          # use: find call Owner.name
```

## take / build

Unchanged: `take name|value|raw|type|owner|signature|attr(...)`,
`build { … | normalize | regex | replace | map }`.
