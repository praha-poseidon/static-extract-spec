# Trace SER Rules

Trace rules describe what to do when Java value tracing gets stuck.

trace 规则描述的是：当 Java 值追踪卡住时，下一步应该怎么解释这个卡住点。

They do not scan the project by themselves. They are only used after an extract
rule asks for `take value` and normal Java tracing cannot produce a literal.

trace 规则不会自己扫描项目。只有提取规则用了 `take value`，并且普通 Java 追踪拿不到字面量时，trace 规则才会参与。

## Mental Model

心智模型。

```text
trace gets stuck
  -> decide the stuck point kind: field / call / parameter / return / assignment / method
  -> pick trace rules with matching from ...
  -> check when ...
  -> evaluate let ...
  -> evaluate build ...
  -> lookup external value by namespace + lookup
```

```text
trace 卡住
  -> 判断卡住点类型：field / call / parameter / return / assignment / method
  -> 找匹配 from ... 的 trace 规则
  -> 检查 when ...
  -> 计算 let ...
  -> 计算 build ...
  -> 用 namespace + lookup 查询外部值
```

`from field` means the current stuck point is a field. It does not mean scanning
all fields.

`from field` 的意思是当前卡住点是字段，不是去扫描所有字段。

`from call` means the current stuck point is a method call whose return value
cannot be resolved by normal Java tracing.

`from call` 的意思是当前卡住点是方法调用，并且这个调用的返回值无法通过普通 Java 追踪解析。

## File Location

文件位置。

Application trace rules should be placed under:

业务项目自己的 trace 规则建议放在：

```text
src/main/resources/static-extract/traces/index.txt
src/main/resources/static-extract/traces/**/*.ser
```

`index.txt` contains paths relative to `static-extract/traces/`.

`index.txt` 里面写的是相对 `static-extract/traces/` 的规则文件路径。

## Basic Shape

基本结构。

```ser
trace "Spring Config Trace"

from field
when annotation @Value on field

let rawValue =
  from annotation on field @Value take attr(value)

build {
  namespace: "config"
  lookup: rawValue | normalize placeholderLookup
  default: rawValue | normalize placeholderDefault
}

from call
when method Environment.getProperty

let configLookup =
  from argument[0] take value

build {
  namespace: "config"
  lookup: configLookup
}
```

## `trace`

`trace`。

Names a trace rule file.

给当前 trace 规则文件命名。

```ser
trace "Spring Config Trace"
```

The name is for diagnostics and organization.

这个名字主要用于诊断和组织规则。

## `from`

`from`。

Declares what kind of stuck point this rule handles.

声明这条规则处理哪种卡住点。

```ser
from field
```

Handles a value that was resolved to a field declaration.

处理已经追踪到字段声明上的值。

```ser
from call
```

Handles a method call return value that normal Java tracing cannot resolve.

处理普通 Java 追踪无法解析的方法调用返回值。

The model already reserves these stuck point kinds:
The trace model uses these stuck point kinds:

trace 模型使用这些卡住点类型：

```text
field
call
parameter
return
assignment
method
```

`annotation` is not a stuck point. It is metadata read through `when annotation
... on ...` or `from annotation on ...`.

`annotation` 不是卡住点。它是元信息，通过 `when annotation ... on ...` 或 `from annotation on ...` 读取。

## `when`

`when`。

Defines the condition that the stuck point must satisfy.

定义卡住点必须满足的条件。

For a field annotation:

字段注解条件：

```ser
when annotation @Value on field
```

This means the stuck field must have `@Value`.

意思是当前卡住的字段必须有 `@Value` 注解。

For a class annotation related to a stuck field:

字段所属类上的注解条件：

```ser
when annotation @ConfigurationProperties on class
```

This means the class that owns the stuck field must have
`@ConfigurationProperties`.

意思是当前卡住字段所在的类必须有 `@ConfigurationProperties`。

For a method call:

方法调用条件：

```ser
when method Environment.getProperty
```

This means the stuck call must match owner type `Environment` and method name
`getProperty`.

意思是当前卡住的方法调用必须匹配 owner 类型 `Environment` 和方法名 `getProperty`。

For field name or type:

字段名或字段类型条件：

```ser
when field name baseUrl
when field type String
```

This checks the current stuck field.

这会检查当前卡住的字段。

For parameter name or type:

参数名或参数类型条件：

```ser
when parameter name baseUrl
when parameter type String
```

This checks the current stuck parameter.

这会检查当前卡住的参数。

For assignment to a field:

字段赋值条件：

```ser
when assignment field baseUrl
```

This checks a stuck assignment such as `this.baseUrl = ...`.

这会检查类似 `this.baseUrl = ...` 的赋值卡住点。

## `let`

`let`。

Extracts named intermediate values from the stuck point and nearby Java
elements.

从卡住点以及相关 Java 元素中提取中间值。

From a field annotation:

从字段注解取值：

```ser
let rawValue =
  from annotation on field @Value take attr(value)
```

From a class annotation:

从类注解取值：

```ser
let prefix =
  from annotation on class @ConfigurationProperties take attr(prefix)
```

From the stuck field itself:

从当前卡住字段本身取值：

```ser
let fieldName =
  from field take name
```

From a method call argument:

从方法调用参数取值：

```ser
let configLookup =
  from argument[0] take value
```

`take value` continues Java value tracing, so arguments can be local variables
or constants.

`take value` 会继续做 Java 值追踪，所以参数可以是局部变量或常量。

From the stuck assignment:

从当前卡住的赋值取值：

```ser
let assignedValue =
  from assignment take value
```

From the stuck call:

从当前卡住的方法调用取值：

```ser
let callName =
  from call take name

let callOwner =
  from call take owner
```

From a parameter:

从当前卡住的参数取值：

```ser
let parameterName =
  from parameter take name

let parameterType =
  from parameter take type
```

## `build`

`build`。

Builds the external lookup request.

构建外部值查询请求。

```ser
build {
  namespace: "config"
  lookup: configLookup
}
```

`namespace` chooses which external value dictionary to query.

`namespace` 表示去哪个外部值字典里查。

`lookup` is the lookup name inside that namespace.

`lookup` 是这个命名空间里的查询名称。

`default` is optional. It is used when the external dictionary does not contain
the lookup.

`default` 是可选字段。当外部字典里没有这个 lookup 时，会使用默认值。

```ser
build {
  namespace: "config"
  lookup: rawValue | normalize placeholderLookup
  default: rawValue | normalize placeholderDefault
}
```

## Build Normalizers

build 阶段的 normalize。

`placeholderLookup` extracts the lookup name from a Spring-style placeholder.

`placeholderLookup` 从 Spring 风格占位符中提取查询名称。

```text
${users.base-url:http://fallback} -> users.base-url
```

`placeholderDefault` extracts the default value from a Spring-style placeholder.

`placeholderDefault` 从 Spring 风格占位符中提取默认值。

```text
${users.base-url:http://fallback} -> http://fallback
```

`kebab` converts camelCase or snake_case into kebab-case.

`kebab` 把 camelCase 或 snake_case 转成 kebab-case。

```text
baseUrl -> base-url
```

## Full Example

完整示例。

Trace file:

trace 文件：

```ser
trace "Spring Config Trace"

from field
when annotation @Value on field

let rawValue =
  from annotation on field @Value take attr(value)

build {
  namespace: "config"
  lookup: rawValue | normalize placeholderLookup
  default: rawValue | normalize placeholderDefault
}

from call
when method Environment.getProperty

let configLookup =
  from argument[0] take value

build {
  namespace: "config"
  lookup: configLookup
}
```

Java code:

Java 代码：

```java
class Client {
    @Value("${service.base-url:http://default}")
    private String baseUrl;

    String load(Environment environment) {
        String key = "service.path";
        return baseUrl + environment.getProperty(key);
    }
}
```

External values:

外部值：

```java
Map<String, Map<String, List<String>>> values = Map.of(
    "config", Map.of(
        "service.base-url", List.of("http://users"),
        "service.path", List.of("/api/users")
    )
);
```

Resolved values:

解析后的值：

```text
baseUrl -> http://users
environment.getProperty(key) -> /api/users
```

## Configuration Properties Direction

Configuration Properties 方向。

The new model can describe the common shape of `@ConfigurationProperties`:

新模型可以描述 `@ConfigurationProperties` 的常见形态：

```ser
trace "Configuration Properties"

from field
when annotation @ConfigurationProperties on class

let prefix =
  from annotation on class @ConfigurationProperties take attr(prefix)

let fieldName =
  from field take name

build {
  namespace: "config"
  lookup: concat(prefix, ".", fieldName) | normalize kebab
}
```

This is a rule-level description of `prefix + field name`. More complex Spring
binding behavior can still be implemented with `JdtTraceResolver`.

这描述的是 `prefix + 字段名` 这种规则级逻辑。更复杂的 Spring 绑定行为仍然可以用 `JdtTraceResolver` 扩展。
