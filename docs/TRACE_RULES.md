# Trace rules

Trace SER uses the same **structure-only** grammar as extract rules
(`docs/CLEAN-G4.md`).

## Shape

```ser
trace "Name"

from field
when annotation @Value on field

let rawValue =
  from annotation @Value on field take attr(value)

build {
  namespace: config
  lookup: rawValue | normalize placeholderLookup
  default: rawValue | normalize placeholderDefault
}
```

- `trace` / `from` / `when` / `let` / `build` → structure  
- `field` / `annotation` / `@Value` / `on` → free atoms for the extractor  

## Java/JDT examples

```ser
from call
when method Environment.getProperty

let configLookup =
  from argument[0] take value
```

```ser
from field
when annotation @Value on field
```

## JS/TS examples

Trace targets use free atoms such as `call`, `field`, `parameter`, `assignment`,
`return`, `method` — see the TS vocabulary.

## External values

Pass a JSON dictionary with the CLI `--external-values` flag. Do not invent
remote config values in the skill.
