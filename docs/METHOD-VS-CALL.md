# Method declaration vs method call

Short glossary for SER authors (especially Java).

## Two different code shapes

### Method **declaration** (定义)

Where a method is **written** on a type:

```java
@GetMapping("/users")
public List<User> list() { ... }   // declaration
```

SER (canonical):

```ser
find method
when annotation @GetMapping on method
```

Meaning: find **method declarations** that carry that annotation.

### Method **call** / invocation (调用)

Where code **invokes** a method:

```java
restTemplate.getForObject(url, User.class);  // call
```

SER (canonical):

```ser
find call RestTemplate.getForObject
# or simple name:
find call fetch
```

Meaning: find **call sites**, not the place `getForObject` is defined.

## Historical confusion (F4)

Older Java rules often wrote:

```ser
find method RestTemplate.getForObject
```

That looks like “declaration”, but the **Java extractor has always treated
`Owner.name` / `Owner.[a,b]` patterns as call matching** (method invocations).

| Surface (old) | Runtime meaning (Java) | Prefer now |
|---|---|---|
| `find method` + annotation when | declaration | keep |
| `find method Owner.name` | **call** | `find call Owner.name` |
| `find method Owner.[a,b]` | **call** | `find call Owner.[a,b]` |
| `find call name` (JS-style) | call | keep |

## JS / TS

The JS vocabulary already separates them clearly:

- `find method save` — method in a class/object shape  
- `find call fetch` — call expression  

Prefer the same mental model on Java rules going forward.

## Desugar (Java)

`static-extract-java` rewrites legacy:

```text
find method RestTemplate.getForObject
→ find call RestTemplate.getForObject
```

so old rules keep working while public authoring uses `call`.
