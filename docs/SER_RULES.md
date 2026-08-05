# SER Rule Guide

SER describes code shapes and the fields you want to output.

SER 用来描述代码形态，以及最终要输出哪些字段。

It is not a dedicated endpoint format. HTTP endpoints, RPC calls, config keys,
message topics, UI text, and other static facts are all represented by
`factType` plus rule-built `fields`.

它不是专门的 endpoint 格式。HTTP 端点、RPC 调用、配置 key、消息 topic、UI 文案和其他静态事实，都通过 `factType` 加规则构建出来的 `fields` 表达。

## Extraction Rule Shape

提取规则结构。

```ser
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
    RequestMapping: GET
  }

build {
  kind: "http"
  method: httpMethod
  path: concat(basePath, "/", methodPath) | normalize slash
}
```

`rule` is only a readable name.

`rule` 只是规则名称，方便诊断和识别。

`fact` declares the standard fact type emitted by a rule, such as
`backend_endpoint`, `frontend_api_call`, `ui_action`, or `config_key`.

`fact` 声明规则输出的标准事实类型，例如 `backend_endpoint`、`frontend_api_call`、`ui_action` 或 `config_key`。

`endpoint` is a legacy compatibility header with two user-defined labels.

`endpoint` 是旧规则兼容头部，包含两个用户自定义标签。

The extract layer does not validate labels like `HTTP`, `CONFIG`, `inbound`, or `outbound`.

提取层不校验 `HTTP`、`CONFIG`、`inbound`、`outbound` 这些标签。

`endpoint` remains supported for compatibility and is exposed through
`classifiers`. New cross-language rules should use `fact`.

`endpoint` 会继续兼容，并输出到 `classifiers`。新的跨语言规则应该使用 `fact`。

SER has a shared syntax skeleton and extractor-specific vocabulary. The Java JDT
extractor currently implements Java words such as `method`, `annotation`,
`field`, `argument`, and `return`. The parser can also preserve future extractor
words such as `jsx`, `prop`, `children`, or `reference`, so TypeScript/Vue
extractors can interpret them without changing the core syntax.

SER 由统一语法骨架和 extractor 词汇组成。当前 Java JDT extractor 实现了 `method`、`annotation`、`field`、`argument`、`return` 等 Java 词汇。parser 也可以保留未来 extractor 的词汇，例如 `jsx`、`prop`、`children`、`reference`，这样 TypeScript/Vue extractor 可以在不改变 SER spec 的前提下解释它们。

Example fact rule:

fact 规则示例：

```ser
rule "Config Field"
fact config_key

find field with annotation @ConfigProperty

let fieldName =
  from field take name

build {
  key: fieldName | normalize kebab
}
```

`find` locates the Java node that anchors this rule.

`find` 负责找到当前规则要处理的 Java 位置。

`let` reads values from the anchor or related Java elements.

`let` 从锚点或相关 Java 元素上读取值。

`build` assembles the final output field map.

`build` 组装最终输出字段 Map。

## Find Forms

查找形态。

```ser
find class
find class with annotation @Controller
find method with annotation @GetMapping
find method with annotation @*Mapping
find method RestTemplate.[getForObject,postForObject,exchange]
find method Router.get
find field baseUrl
find field with annotation @ConfigProperty
```

`find method with annotation` finds method declarations.

`find method with annotation` 查找方法声明。

`find method Owner.name` finds method calls.

`find method Owner.name` 查找方法调用。

`find field baseUrl` finds a field by Java field name.

`find field baseUrl` 按 Java 字段名查找字段。

`find field with annotation @X` finds fields annotated with `@X`.

`find field with annotation @X` 查找带 `@X` 注解的字段。

`@*Mapping` means annotation name suffix matching, such as `@GetMapping` and `@RequestMapping`.

`@*Mapping` 表示按注解名后缀匹配，例如 `@GetMapping` 和 `@RequestMapping`。

## Quick Reference

速查表。

| Purpose | SER shape |
| --- | --- |
| Find every class | `find class` |
| Find annotated class | `find class with annotation @Controller` |
| Find annotated method | `find method with annotation @GetMapping` |
| Find annotation suffix | `find method with annotation @*Mapping` |
| Find method call | `find method RestTemplate.getForObject` |
| Find method calls | `find method RestTemplate.[getForObject,postForObject]` |
| Find named field | `find field baseUrl` |
| Find annotated field | `find field with annotation @ConfigProperty` |
| Read class annotation | `from annotation on class @X take attr(value)` |
| Read method annotation | `from annotation on method @X take attr(path)` |
| Read field annotation | `from annotation on field @X take attr(name)` |
| Read parameter annotation | `from annotation on parameter @X take attr(value)` |
| Read argument value | `from argument[0] take value` |
| Read call owner | `from call take owner` |
| Read return value | `from return take value` |
| Read field value | `from field take value` |
| Read named field value | `from field baseUrl take value` |
| Read parameter metadata | `from parameter userId take type` |
| Read new expression | `from new UserDto take type` |
| Emit constant | `kind: "http"` |
| Emit variable | `path: path` |
| Concatenate | `path: concat(basePath, "/", methodPath)` |
| Regex extract | `path: raw | regex "(.+)" group 1` |
| Replace | `path: raw | replace "\\s+" ""` |
| Map values | `method: annotationName | map { GetMapping: GET }` |
| Normalize slash | `path: path | normalize slash` |
| Normalize path variables | `path: path | normalize pathVariable` |
| Extract URL path | `path: url | normalize extractPath` |
| Extract placeholder lookup | `lookup: raw | normalize placeholderLookup` |
| Extract placeholder default | `default: raw | normalize placeholderDefault` |
| Kebab case | `key: fieldName | normalize kebab` |

| 用途 | SER 写法 |
| --- | --- |
| 查找所有类 | `find class` |
| 查找带注解的类 | `find class with annotation @Controller` |
| 查找带注解的方法 | `find method with annotation @GetMapping` |
| 按注解后缀查找 | `find method with annotation @*Mapping` |
| 查找方法调用 | `find method RestTemplate.getForObject` |
| 查找多个方法调用 | `find method RestTemplate.[getForObject,postForObject]` |
| 查找指定字段 | `find field baseUrl` |
| 查找带注解字段 | `find field with annotation @ConfigProperty` |
| 读类注解 | `from annotation on class @X take attr(value)` |
| 读方法注解 | `from annotation on method @X take attr(path)` |
| 读字段注解 | `from annotation on field @X take attr(name)` |
| 读参数注解 | `from annotation on parameter @X take attr(value)` |
| 读调用参数值 | `from argument[0] take value` |
| 读调用 owner | `from call take owner` |
| 读 return 值 | `from return take value` |
| 读字段值 | `from field take value` |
| 读指定字段值 | `from field baseUrl take value` |
| 读参数信息 | `from parameter userId take type` |
| 读 new 表达式 | `from new UserDto take type` |
| 输出常量 | `kind: "http"` |
| 输出变量 | `path: path` |
| 拼接 | `path: concat(basePath, "/", methodPath)` |
| 正则提取 | `path: raw | regex "(.+)" group 1` |
| 替换 | `path: raw | replace "\\s+" ""` |
| 映射值 | `method: annotationName | map { GetMapping: GET }` |
| 归一化斜杠 | `path: path | normalize slash` |
| 归一化路径变量 | `path: path | normalize pathVariable` |
| 从 URL 提取 path | `path: url | normalize extractPath` |
| 提取占位符 key | `lookup: raw | normalize placeholderLookup` |
| 提取占位符默认值 | `default: raw | normalize placeholderDefault` |
| 转 kebab-case | `key: fieldName | normalize kebab` |

## Let Sources

取值来源。

```ser
from annotation on class @X take attr(value)
from annotation on method @X take attr(path)
from annotation on field @X take attr(name)
from annotation on parameter @X take attr(value)

from class take name
from class take type
from method take name
from method take signature
from field take name
from field take type
from field take value
from parameter userId take name
from parameter userId take type
from argument[0] take value
from call take name
from call take owner
from call take raw
from return take value
from assignment take value
from new com.example.UserDto take type
from literal FIXED take value
```

`take name` reads a simple name.

`take name` 读取名称。

`take type` reads the Java type when the extractor can determine it.

`take type` 读取 Java 类型，前提是运行时能判断出来。

`take raw` reads the source code text.

`take raw` 读取源码文本。

`take attr(...)` reads annotation attributes in order.

`take attr(...)` 按顺序读取注解属性。

`take value` asks the extractor for the semantic value.

`take value` 表示让运行时读取语义值。

For Java source, `take value` traces string literals, local variables, fields, string concatenation, returns, assignments, and supported external value entries.

对于 Java 源码，`take value` 会追踪字符串字面量、局部变量、字段、字符串拼接、return、赋值，以及可描述的外部值入口。

Each `let` can have multiple `from` lines.

每个 `let` 可以写多个 `from`。

The first source that produces a value wins.

第一个能取到值的来源会生效。

```ser
let path =
  from annotation on method @GetMapping take attr(value)
  from annotation on method @GetMapping take attr(path)
  default ""
```

This is used when the same logical value may be written in several code shapes.

这用于同一个逻辑值可能有多种代码写法的场景。

## Build Fields

输出字段。

```ser
build {
  kind: "http"
  method: httpMethod
  path: concat(basePath, "/", methodPath) | normalize slash
}
```

Field names in `build` are user-defined.

`build` 里的字段名由用户定义。

The output protocol is `Map<String, String>` inside `StaticExtractResult`.

输出协议是 `StaticExtractResult` 里的 `Map<String, String>`。

The extracted fields are the values produced by the rule.

提取字段就是规则生成的结果。

```text
endpoint 标签 + build 字段 -> 调用方自己的领域对象
```

## Build Pipeline

build 管道。

```ser
path: concat(basePath, "/", methodPath) | normalize slash
urlPath: url | normalize extractPath
pathPattern: path | normalize pathVariable
configKey: rawValue | normalize placeholderLookup
defaultValue: rawValue | normalize placeholderDefault
fieldKey: fieldName | normalize kebab
route: raw | regex "/api/([^?]+)" group 1
clean: raw | replace "\\s+" ""
method: rawMethod | map {
  GetMapping: GET
  PostMapping: POST
}
```

`concat` combines values and string literals.

`concat` 拼接变量和字符串字面量。

`regex` extracts one regex group.

`regex` 提取一个正则分组。

`replace` applies Java regex replacement.

`replace` 使用 Java 正则替换。

`map` maps known values and leaves unknown values unchanged.

`map` 映射已知值，未知值保持原样。

`normalize` contains common reusable normalizers.

`normalize` 包含常用归一化能力。

## Trace Rules

trace 规则。

Trace rules are used only when `take value` cannot resolve a Java value directly.

trace 规则只在 `take value` 不能直接解析 Java 值时参与。

They describe external value entry points, not endpoint extraction.

它描述的是外部值入口，不是端点提取规则。

```ser
trace "MicroProfile Config Trace"

from field
when annotation @ConfigProperty on field

let lookupValue =
  from annotation on field @ConfigProperty take attr(name)

let defaultValue =
  from annotation on field @ConfigProperty take attr(defaultValue)

build {
  namespace: "config"
  lookup: lookupValue
  default: defaultValue
}
```

The extractor flow is:

运行流程是：

```text
take value gets stuck at a field
-> select trace entries with from field
-> evaluate when conditions
-> run let/build
-> query external values by namespace + lookup
```

```text
take value 追踪到字段后卡住
-> 选择 from field 的 trace entry
-> 判断 when 条件
-> 执行 let/build
-> 用 namespace + lookup 查询外部值
```

The engine does not hard-code `@Value`, `@ConfigProperty`, or `@ConfigurationProperties`.

引擎没有写死 `@Value`、`@ConfigProperty`、`@ConfigurationProperties`。

Those are ordinary annotation names written in trace rules.

这些都只是 trace 规则里写的普通注解名。

## External Values

外部值。

External values are provided by the caller as:

外部值由调用方提供：

```java
Map<String, Map<String, List<String>>> values = Map.of(
    "config", Map.of(
        "users.base-url", List.of("http://users"),
        "queue.name", List.of("orders")
    )
);
```

`namespace` chooses the outer map.

`namespace` 选择外层 Map。

`lookup` chooses the key inside that namespace.

`lookup` 选择命名空间里的 key。

When no external value is found, `default` is used if the trace rule built one.

如果查不到外部值，会使用 trace rule build 出来的 `default`。

When no value and no default exist, the extractor returns `{lookup}` as an unresolved marker.

如果既没有外部值也没有默认值，运行时返回 `{lookup}` 作为未解析标记。

## Identifier Rule

标识符规则。

`let` and `build` field names may use ordinary names or SER words such as `value`, `field`, `method`, and `class`.

`let` 和 `build` 字段名可以使用普通名称，也可以使用 `value`、`field`、`method`、`class` 这类 SER 词。

```ser
let value =
  from field take value

build {
  value: value
}
```
