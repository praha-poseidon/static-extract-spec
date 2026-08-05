# SER Capabilities

The rule engine extracts facts from Java code shapes. Do not start from hard-coded framework recipes. Inspect the project first, then express the discovered shape with these primitives.

## Extraction Targets

Use the user's request to decide what product concepts to extract. Common product concepts include:

- HTTP inbound endpoints
- HTTP outbound calls
- Kafka producers and consumers
- database operations such as MySQL/JDBC/MyBatis/JPA
- Redis operations and keys
- scheduled jobs
- RPC clients and servers
- message queue producers and consumers

These are output goals, not fixed parsing recipes. The agent must discover how the project represents them in code.

## Observable Java Elements

SER rules can describe extraction around these Java elements:

- class
- method
- field
- annotation
- method call
- method argument
- return expression
- initializer
- object creation
- literal
- name
- type
- source text

Use these elements as the vocabulary for writing rules.

## Matching Anchors

Choose an anchor with `find`. The anchor is the code element that proves a record exists.

Examples:

```text
find method with annotation @SomeAnnotation
find class with annotation @SomeAnnotation
find field with annotation @SomeAnnotation
find call with method SomeType.someMethod
find call with method someMethod
```

The annotation or method names should come from the inspected project, not from this document.

## Value Sources

After finding an anchor, extract values with `let` and `from`.

Annotation values:

```text
from annotation on method @X take attr(value)
from annotation on class @X take attr(path)
from annotation on field @X take attr(value)
from annotation on method @X take name
```

Call values:

```text
from argument[0] take value
from argument[1] take source
```

Field and initializer values:

```text
from field take name
from field take type
from initializer take value
```

Constants:

```text
from literal SOME_VALUE take value
default ""
```

Multiple `from` lines mean fallback sources. The first source that produces a value wins.

## Build Fields

The `build` block defines the output field map. Field names are not validated by the CLI. Choose names that match the downstream graph or product model.

```text
build {
  system: "Kafka"
  direction: "outbound"
  topic: topic
  handler: handler
}
```

Useful operations:

```text
concat(a, b)
value | normalize slash
value | normalize pathVariable
value | normalize placeholderKey
value | normalize placeholderDefault
```

Use `map` when one extracted value needs to be translated into another:

```text
let method =
  from annotation on method @X take name
  map {
    Get: GET
    Post: POST
  }
```

## Trace Boundary

Trace is used when the Java value points to an extractor value instead of a literal.

Typical boundary forms include:

- an annotation attribute that contains a placeholder
- a field initialized by configuration
- a method argument that names an external config key
- an environment variable lookup

Do not hard-code these forms blindly. Inspect the code and write trace rules only for the forms that appear in the project.

## Unsupported Shapes

If a product concept is visible in files that SER/JDT cannot currently express, report:

- the target concept
- the concrete file and line
- the code shape
- the missing primitive or operation
