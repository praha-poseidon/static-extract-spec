# SER = DSL skeleton only

`Ser.g4` defines **structure keywords**. It does not define what any programming
language element means.

## Structure keywords

```text
rule  fact  endpoint  find  where  when  let  from  take  fallback  map  build  trace
if  and  or  not  exists  matches  contains  in
concat  normalize  regex  replace  group
```

Filter keywords are **not** the same:

| keyword | role |
|---------|------|
| **find** | what shape to select |
| **where** | **scope** — where it lives (enclosing class / class annotation / package / file) |
| **when** | **anchor** — predicates on the selected element (method annotation, call owner, field type, …) |

Order in a rule file: `find` → `where*` → `when*` → `let*` → `build` → optional `trace { }`.

Plus punctuation and `when if` condition operators.

`default` is not a structure keyword for default values — use `fallback`.
The word `default` may appear as a free atom (extractor vocabulary).

## Free atoms

After `find` / `when` / `from` / `take`, tokens are **free atoms** (identifiers,
`@Name`, `a.b`, `[a,b]`, `argument[0]`, …).

The shared grammar only tokenizes them. **Each extractor** decides which atoms
it understands (its vocabulary).

## Shape (structure only)

```ser
rule "Name"
fact some_fact_type

find <free-atoms…>

when <free-atoms…>
when if <condition>

let name =
  from <free-atoms…> take <free-atoms…>
  fallback <free-atom>

build {
  field: <expr> | normalize <ident> | …
}

# optional value-trace for this rule's find only
trace {
  from <target>
  when <free-atoms…>
  let name =
    from <free-atoms…> take <free-atoms…>
  build { … }
}
```

No standalone `trace "name"` files. Patches are only the optional `trace { }` block.

There is no language name (Java, React, …) in this contract.
