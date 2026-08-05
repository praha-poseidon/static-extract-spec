# Java/JDT Vocabulary

Source of truth: `java/jdt/vocabulary.md`.

Common supported examples:

```ser
find method with annotation @*Mapping
from annotation on method @*Mapping take attr(value)
from annotation on class @RequestMapping take attr(value)
```

```ser
find method RestTemplate.[getForObject,postForObject]
from argument[0] take value
from method take name
```

```ser
find field with annotation @Value
from annotation on field @Value take attr(value)
```

Use Java/JDT vocabulary for Spring endpoints, Java method calls, annotations,
fields, and config extraction.

