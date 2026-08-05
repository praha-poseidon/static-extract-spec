# Method declaration vs call (vocabulary)

This is **not** a grammar distinction in `Ser.g4`. Both are free atoms after
`find`. Extractors define the meaning.

## Declaration

Code that **defines** a method:

```ser
find method
when annotation @GetMapping on method
```

## Call

Code that **invokes** a method:

```ser
find call RestTemplate.getForObject
find call fetch
```

## Java/JDT note

Java vocabulary treats qualified patterns after `call` as invocation matching.
Prefer `find call Owner.name`, not `find method Owner.name`.
