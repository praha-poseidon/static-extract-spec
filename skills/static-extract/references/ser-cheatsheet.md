# SER Cheatsheet

## Basic Rule

```text
rule "Spring MVC HTTP Inbound"
fact backend_endpoint

find method with annotation @*Mapping

let basePath =
  from annotation on class @RequestMapping take attr(value)
  from annotation on class @RequestMapping take attr(path)
  default ""

let methodPath =
  from annotation on method @*Mapping take attr(value)
  from annotation on method @*Mapping take attr(path)
  default ""

let httpMethod =
  from annotation on method @*Mapping take name
  map {
    GetMapping: GET
    PostMapping: POST
    PutMapping: PUT
    DeleteMapping: DELETE
    PatchMapping: PATCH
    RequestMapping: GET
  }

build {
  httpMethod: httpMethod
  path: concat(basePath, methodPath) | normalize slash | normalize pathVariable
}
```

## Structure

- `rule "Name"`: human-readable rule name.
- `fact type_name`: output fact type, such as `backend_endpoint`, `api_call`, or `config_key`.
- `find ...`: choose the Java element that anchors extraction.
- `let name = ...`: define an intermediate value. Multiple `from` lines are fallback sources; the first matching value wins.
- `build { key: value }`: emit final fields. Downstream tools read this field map.

Legacy `endpoint TYPE DIRECTION` rules are still accepted for compatibility.
New rules should use `fact`.

## Common Find Clauses

```text
find class with annotation @Controller
find method with annotation @GetMapping
find field with annotation @Value
find call with method RestTemplate.getForObject
find call with method router.get
```

Use wildcards for annotation families:

```text
find method with annotation @*Mapping
```

## Common Sources

Annotation attributes:

```text
from annotation on method @GetMapping take attr(value)
from annotation on class @RequestMapping take attr(path)
from annotation on method @*Mapping take name
```

Call arguments:

```text
from argument[0] take value
from argument[1] take source
```

Field facts:

```text
from field take name
from field take type
from initializer take value
```

Constants:

```text
from literal GET take value
default ""
```

## Build Operations

Concatenate values:

```text
path: concat(basePath, methodPath)
```

Normalize paths:

```text
path: rawPath | normalize slash | normalize pathVariable
```

Map names to output values:

```text
let httpMethod =
  from annotation on method @*Mapping take name
  map {
    GetMapping: GET
    PostMapping: POST
  }
```

## Trace Rules

Trace rules describe external value entry points encountered when normal Java value tracing cannot continue.

Trace blocks can live in the same `.ser` file as extraction rules. Keep related `rule ...` and `trace ...` blocks together unless there is a reason to share one trace block across many files.

Example for Spring `@Value`:

```text
trace "Spring Value"
external config from field
when annotation @Value on field

let rawValue =
  from annotation on field @Value take attr(value)

build {
  namespace: "config"
  key: rawValue | normalize placeholderKey
  default: rawValue | normalize placeholderDefault
}
```

Then pass external values:

```bash
static-extract-java run \
  --project /my-project \
  --rule /my-project/.ser/generated/http.ser \
  --external-values /my-project/.ser/generated/external-values.json
```

## Repair Loop

If `try` returns zero results:

1. Run `diagnose`.
2. Check whether the expected annotation or method call appears in facts.
3. If facts show a different name, update `find`.
4. If `find` matches but fields are empty, update the relevant `from ... take ...`.
5. Re-run `try`.
