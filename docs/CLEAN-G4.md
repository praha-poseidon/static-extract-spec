# SER public grammar = DSL skeleton only

`Ser.g4` defines **structure**, not language vocabulary.

## Structure keywords (grammar cares)

```text
rule  fact  endpoint  find  when  let  from  take  fallback  map  build  trace
if  and  or  not  exists  matches  contains  in
concat  normalize  regex  replace  group
```

Plus punctuation and `when if` condition operators.

(`default` is **not** a structure keyword for default values — use `fallback`.
The word `default` may appear as a free atom, e.g. `from export default`.)

## Free content (grammar does **not** interpret)

Everything after `find` / `when` / `from` / `take` (except structure keywords) is a
sequence of **free atoms**. Meaning is defined by each extractor’s **vocabulary**.

Examples of free atoms (grammar treats them as opaque text):

```text
method  class  field  call  jsx  prop  annotation  decorator  argument
@GetMapping  @*Mapping  RestTemplate.getForObject  Owner.[a,b]
on  name  value  attr  default  …
```

## Shape

```ser
rule "Name"
fact some_fact

find method
when annotation @RouteGet on method

let path =
  from annotation @RouteGet on method take attr(value)
  fallback ""

build {
  path: path
}
```

- `find` / `when` / `from` / `take` / `build` / `fallback` → structure  
- `method` / `annotation` / `@RouteGet` / `on` / `attr` → free atoms (Java vocabulary)  
- `find jsx button` → same structure, JS vocabulary  

## No compatibility layer

No compatibility rewrites. Wrong structure → parse error. Unknown vocabulary → extractor error.
