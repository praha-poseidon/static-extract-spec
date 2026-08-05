# Core SER vs Java dialect sugar

This document freezes the **boundary** for purifying `ser/Ser.g4`.

- **Core SER**: structure shared by all extractors; vocabulary is open-ended strings.
- **Java dialect sugar**: convenience forms that today are hard-coded in `Ser.g4`.
  They will move to `static-extract-java` desugar (steps B*) before sugar is
  removed from the public grammar (steps C*).

Status as of **step-C3**: `find … with annotation …` (F1–F3) **removed** from
`ser/Ser.g4`. Java authors may still write the sugar; `static-extract-java`
`JavaSerDesugarer` rewrites it before ANTLR parse.

---

## 1. Core SER (must stay language-neutral)

These are **structure keywords** (rule skeleton), not “Java concepts”:

| Construct | Role |
|---|---|
| `rule` / `fact` / `endpoint` | metadata / output type |
| `find` | anchor selection |
| `when` / `when if` | conditions |
| `let` / `from` / `take` / `default` / `map` | value extraction |
| `build` / `concat` / pipelines (`normalize`, `regex`, `replace`) | output assembly |
| `trace` + trace entries | external / flow continuation |
| `and` / `or` / `not` / `exists` / compare ops | condition expression |

### Canonical (target) surface shape

```ser
rule "Name"
fact some_fact_type

find <kind> <selector>?

when if <path> <op> <value>
when <kind> ...                 # free-form when payload; validated by vocabulary

let name =
  from <kind> <selector>? take <take>
  default "..."

build {
  field: expr | normalize slash
}
```

- `<kind>` is an identifier string (`method`, `call`, `jsx`, `annotation`, …).
- Extractors declare which kinds they support via vocabulary manifests.
- Spec does **not** hard-code “annotation means Java”.

### Already-generic forms (keep; used by JS today)

```ser
find jsx button
find call fetch
find export [GET,POST]
from argument[0] take value
from prop onClick take value
when if call.owner == router
```

---

## 2. Java dialect sugar (currently first-class in Ser.g4)

These productions prefer Java authoring habits. They are **not** required for TS/JS
rules; they inflate the shared grammar.

### 2.1 `find` sugar

| # | Current sugar (in g4) | Target canonical form | Notes |
|---|---|---|---|
| F1 | `find method with annotation @X` | `find method` + `when annotation @X on method` | **Removed from g4 (C3)**; Java desugar B2 |
| F2 | `find class with annotation @X` | `find class` + `when annotation @X on class` | **Removed from g4 (C3)**; Java desugar B2 |
| F3 | `find field with annotation @X` | `find field` + `when annotation @X on field` | **Removed from g4 (C3)**; Java desugar B2 |
| F4 | `find method Owner.name` | `find call Owner.name` | **Desugared (F4 step)**; g4 accepts both `find call` and legacy `find method` patterns |
| F5 | `find method Owner.[a,b]` | same as F4 with list | |
| F6 | `find class` (bare keyword production) | `find class` via generic `find nameItem` | Duplicate of generic path |
| F7 | `find field name` | `find field name` via generic | Duplicate of generic path |

Generic fallback already in g4:

```text
FIND genericFindKind=nameItem genericFindName=findName?
```

### 2.2 `from` sugar

| # | Current sugar | Target canonical form |
|---|---|---|
| S1 | `from annotation on method @X` | **Preferred:** `from annotation @X on method` (both in g4 as of step-E1) |
| S2 | `from annotation on class @X` | **Preferred:** `from annotation @X on class` |
| S3 | `from annotation on field @X` | **Preferred:** `from annotation @X on field` |
| S4 | `from decorator on …` | TS-oriented; prefer generic `from decorator …` |
| S5 | bare `from method` / `from call` / … keyword alts | `from method` via generic source kind |
| S6 | `from new Qualified.Name` | `from new Qualified.Name` as generic + selector |
| S7 | `from argument[i]` | keep as core or shared convenience (used by Java and JS) — **candidate for core** |

### 2.3 `when` sugar

| # | Current sugar | Target canonical form |
|---|---|---|
| W1 | `when annotation @X on method` | `when annotation @X` (+ optional on) |
| W2 | `when method Owner.name` | `when method …` / `when call …` via generic payload |
| W3 | `when call Owner.name` | same |
| W4 | `when field name X` / `when field type T` | generic path or `when if` |
| W5 | `when parameter name/type …` | same |
| W6 | `when method name X` / `when call name/owner …` | same |
| W7 | `when assignment field X` | same |
| W0 | `when if <conditionExpr>` | **core** — keep |

### 2.4 Tokens that are soft vocabulary (not structure)

Lexer keywords such as `annotation`, `method`, `class`, `field`, `jsx` (as IDENT via nameItem),
`decorator` may remain **allowed as names**, but should not require exclusive
parser productions for every language.

---

## 3. Desugar mapping (contract for step B*)

Java `JavaSerDesugarer` (future) rewrites **text or parse tree** so the core parser
only needs generic forms. Normative examples:

### F1

```ser
# sugar
find method with annotation @GetMapping

# after desugar (target text or equivalent IR)
find method
when annotation @GetMapping
```

### S1

```ser
# sugar
from annotation on method @GetMapping take attr(value)

# after desugar (illustrative IR fields)
from:
  kind: annotation
  ref: @GetMapping
  on: method
take:
  kind: attr
  args: [value]
```

Exact IR field names will align with `schema/rule-ir.schema.json` in a later step;
this table is the **intent**, not yet a schema change.

### F4 ambiguity (flagged for B2 discussion)

```ser
find method RestTemplate.getForObject
```

Historically this often means a **method call / invocation**, not a method
declaration. Desugar may map to:

```ser
find call RestTemplate.getForObject
```

or keep `find method` with Java vocabulary semantics “call pattern”.  
**Do not change behavior in A/B without a dedicated step and tests.**

---

## 4. What must not enter core g4 later

- New language-only sugar (`with annotation`, framework names, JSX-only exclusive
  productions if they can be generic kinds).
- JDT / TypeScript AST types.
- Framework rule packs (Spring, React) — stay in language repos.

---

Also see `docs/METHOD-VS-CALL.md`.

## 5. Source of truth today

| Item | Location |
|---|---|
| Grammar (still mixed) | `ser/Ser.g4` |
| Semantics | `ser/SER_SPEC.md` |
| This boundary | `docs/CORE-VS-JAVA-DIALECT.md` |
| Step plan | `docs/SMALL-STEPS.md` |

---

## 6. Checklist for step A2 (done)

- [x] List structure keywords (core)
- [x] List hard-coded find sugar F1–F7
- [x] List from sugar S1–S7
- [x] List when sugar W0–W7
- [x] Give desugar intent for main Java forms
- [x] Flag F4 method-vs-call ambiguity for later steps
