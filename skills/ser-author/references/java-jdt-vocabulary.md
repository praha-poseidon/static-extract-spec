# Java/JDT Vocabulary

Source of truth: `java/jdt/vocabulary.md`.

Common supported examples:

```ser
find method
when annotation @*Mapping on method
from annotation @*Mapping on method take attr(value)
from annotation @RequestMapping on class take attr(value)
```

```ser
find call RestTemplate.[getForObject,postForObject]
from argument[0] take value
from method take name
```

```ser
find field
when annotation @Value on field
from annotation @Value on field take attr(value)
```

Use Java/JDT vocabulary for Spring endpoints, Java method calls, annotations,
fields, and config extraction.

