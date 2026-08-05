# Universal Rule Engine Roadmap

This document describes the direction for evolving Static Extract from a
Java-focused static extraction engine into a universal rule engine for
cross-language code facts.

本文档描述 Static Extract 的演进方向：从 Java 静态提取引擎，演进为面向多语言代码事实的通用规则引擎。

## Goal

The goal is not to hard-code every framework or project pattern into the engine.
The goal is to provide:

目标不是把所有框架和项目形态都写死进引擎，而是提供：

- A shared rule language skeleton.
- Pluggable language vocabularies.
- Extractor implementations for different source languages.
- Rulesets for popular frameworks and project-specific conventions.
- A stable extracted-record envelope that keeps rule-built fields intact.

- 统一的规则语言骨架。
- 可插拔的语言词汇。
- 面向不同源码语言的 extractor 实现。
- 面向主流框架和项目私有约定的规则包。
- 稳定的提取结果外壳，同时保持规则 `build` 字段不被改写。

The target shape is:

目标结构：

```text
SER Spec
  -> Java vocabulary + JDT extractor
  -> TSX vocabulary + TypeScript extractor
  -> Vue vocabulary + Vue extractor
  -> Rulesets
  -> Extracted records
```

## SER Spec

The SER spec should stay small and language-neutral. It should describe rule
structure, value extraction, tracing, output assembly, CLI shape, and JSON
output shape.

SER spec 应该保持小而中立。它只描述规则结构、取值、追踪、输出组装、CLI 形态和 JSON 输出形态。

Spec syntax:

规范语法：

```text
rule
fact
find
let
from
take
default
map
trace
when
build
normalize
```

An extractor parser should understand the shared rule shape and preserve
extractor-specific vocabulary. It should not need to know every source-language
element globally.

extractor parser 只需要理解共享规则结构并保留 extractor 专属词汇，不应该全局知道所有源码语言元素，比如 Java annotation、JSX prop 或 Vue slot。

## Vocabulary

A vocabulary is the set of language or framework words that an extractor knows how
to interpret.

词汇是 extractor 能解释的一组语言或框架相关名词和动作。

Examples:

示例：

```text
Java vocabulary:
  class, method, field, annotation, parameter, argument, return, call, new

TSX vocabulary:
  jsx, component, prop, children, event, handler, hook, import, route, call

Vue vocabulary:
  component, template, directive, slot, event, binding, script, route, call
```

The DSL skeleton is shared, but vocabularies are extractor-specific.

DSL 骨架统一，但词汇由 extractor 提供。

Example Java rule:

Java 规则示例：

```ser
rule "Spring MVC Endpoint"
fact backend_endpoint

find method with annotation @*Mapping

let path =
  from annotation on method @*Mapping take attr(value)

build {
  method: "GET"
  path: path
}
```

Example TSX rule:

TSX 规则示例：

```ser
rule "React Button Action"
fact ui_action

find jsx Button

let label =
  from children take text
  from prop title take value

let handler =
  from prop onClick take reference

build {
  label: label
  event: "click"
  handler: handler
}
```

In these examples, `rule`, `fact`, `find`, `let`, `from`, `take`, and `build`
belong to the SER spec. `method`, `annotation`, `jsx`, `children`, and `prop`
belong to extractor vocabularies.

在这些示例中，`rule`、`fact`、`find`、`let`、`from`、`take`、`build` 属于 SER spec；`method`、`annotation`、`jsx`、`children`、`prop` 属于 extractor 词汇。

## Extractor

An extractor executes rules for one source language or source representation.

extractor 负责在某一种源码语言或源码表示上执行规则。

Initial extractor targets:

初始 extractor 目标：

```text
java/jdt
  Java source through Eclipse JDT.

ts
  TypeScript and TSX through the TypeScript compiler API or ts-morph.

static-extract-extractor-vue
  Vue single-file components through a Vue parser plus TypeScript support.
```

Extractor responsibilities:

extractor 职责：

- Parse source files or receive parsed source units.
- Implement supported `find` kinds.
- Implement supported `from` sources.
- Implement supported `take` operations.
- Trace values when `take value` or equivalent semantic extraction is requested.
- Report diagnostics when a rule cannot be evaluated.

- 解析源码文件，或接收已经解析好的源码单元。
- 实现支持的 `find` 类型。
- 实现支持的 `from` 来源。
- 实现支持的 `take` 操作。
- 在 `take value` 或等价语义取值时追踪值。
- 当规则无法执行时返回诊断信息。

The language-neutral `spec/` should not contain Java classes or extractor code.
Each extractor implements the spec in its own language and validates its own
vocabulary.

语言无关的 `spec/` 不应该包含 Java class 或 extractor 代码。每个 extractor 用自己的语言实现 spec，并校验自己的词汇。

## Facts

SER uses `fact` as the general output type. HTTP endpoints, RPC calls, UI
actions, configuration keys, and other product concepts are all facts with
rule-built fields.

SER 使用 `fact` 作为通用输出类型。HTTP 端点、RPC 调用、UI action、配置 key 和其他产品概念，都是带规则字段的 fact。

Example fact types:

示例 fact 类型：

```text
ui_action
frontend_route
frontend_handler
frontend_api_call
backend_endpoint
config_key
permission
database_operation
message_operation
scheduled_job
```

Each extracted record should have a stable envelope plus flexible `fields`.
The `fields` object is still defined entirely by the SER `build` block.

每条提取结果应该包含稳定外壳和灵活的 `fields`。`fields` 仍然完全由 SER `build` 块定义。

Language extractors should expose this shape through the spec contract instead of
inventing extractor-specific output envelopes.

各语言 extractor 应该通过 spec contract 暴露这个结构，而不是各自发明一套输出外壳。

```json
{
  "rule": "Axios API Call",
  "factType": "frontend_api_call",
  "classifiers": {},
  "fields": {
    "method": "POST",
    "path": "/api/users"
  },
  "projectFilePath": "src/pages/UserPage.tsx",
  "absoluteFilePath": "/repo/src/pages/UserPage.tsx",
  "startLine": 42,
  "endLine": 42,
  "enclosingSymbol": "handleSubmit"
}
```

Older `endpoint TYPE DIRECTION` declarations are treated as a rule-header
classification and are exposed through `classifiers`, for example
`{"category":"HTTP","direction":"inbound"}`. New rules should prefer `fact`.

旧的 `endpoint TYPE DIRECTION` 声明会作为规则头部分类输出到 `classifiers`，例如 `{"category":"HTTP","direction":"inbound"}`。新规则应优先使用 `fact`。

## Frontend Trace

Frontend code often hides visible UI text and API paths behind variables,
functions, object maps, i18n calls, generated clients, or wrapper APIs.

前端代码经常把可见文案和接口路径藏在变量、函数、对象映射、i18n 调用、生成 client 或封装 API 后面。

The first TSX extractor should support value tracing for:

第一版 TSX extractor 应支持这些值追踪：

```text
string literals
const variables
function return values
object properties
enum-like maps
template strings
simple conditional expressions
i18n calls such as t("user.submit")
imported constants
```

Example target cases:

目标示例：

```tsx
<Button>提交</Button>

const label = "提交";
<Button>{label}</Button>

function submitText() {
  return "提交";
}
<Button>{submitText()}</Button>

<Button>{t("user.submit")}</Button>
```

## Rulesets

Rulesets should be first-class assets. The engine should not try to know every
framework in code.

规则包应该是一等资产。引擎不应该在代码里认识所有框架。

Proposed layout:

建议目录结构：

```text
rulesets/
  frontend/
    react/
      ruleset.yaml
      rules/
      traces/
      examples/
      expected/
    axios/
  java/
    spring-web/
    spring-config/
    rest-template/
    feign/
```

Example `ruleset.yaml`:

示例 `ruleset.yaml`：

```yaml
id: frontend/react
language: typescript
extractor: tsx
facts:
  - ui_action
  - frontend_handler
```

The CLI should eventually support:

CLI 后续应支持：

```bash
static-extract-java run \
  --project /my-project \
  --ruleset frontend/react \
  --ruleset frontend/axios \
  --ruleset java/spring-web \
  --out facts.jsonl
```

Project-specific rules should be composable with official rulesets:

项目私有规则应该可以和官方规则包组合：

```bash
static-extract-java run \
  --project /my-project \
  --ruleset frontend/react \
  --rules ./company-rules \
  --out facts.jsonl
```

## Discovery

Rulesets cannot cover every company-specific framework or wrapper. The system
should support discovery so users and AI agents can identify project-specific
patterns.

规则包无法覆盖所有公司私有框架或封装。系统应该支持 discovery，帮助用户和 AI agent 发现项目私有模式。

Future command:

未来命令：

```bash
static-extract-java discover --project /my-project --language typescript
```

Possible output:

可能输出：

```json
{
  "components": ["Button", "CompanyButton", "TableAction"],
  "events": ["onClick", "onSubmit"],
  "requestWrappers": ["request", "httpClient", "apiClient"],
  "i18nCalls": ["t", "intl.formatMessage"],
  "candidateRules": []
}
```

Discovery is where AI agents can help most:

discovery 是 AI agent 最能发挥作用的地方：

```text
inspect project
-> discover common wrappers
-> generate SER rules
-> try
-> diagnose
-> adjust
-> run
```

## Implementation Roadmap

Suggested order:

建议顺序：

1. Add `fact` to the DSL while preserving `endpoint`.
2. Make element kinds and take kinds extractor-extensible where practical.
3. Define the stable extracted-record envelope and JSONL output.
4. Add ruleset metadata and CLI loading by `--ruleset`.
5. Build a minimal TSX extractor for React button, event handler, and axios call extraction.
6. Add frontend diagnostics for unresolved label, handler, and API path values.
7. Add discovery for frontend components, request wrappers, and i18n calls.
8. Expand official rulesets after the record envelope and extractor vocabulary stabilize.

1. 给 DSL 增加 `fact`，同时保留 `endpoint` 兼容。
2. 在可行范围内让 element kind 和 take kind 可由 extractor 扩展。
3. 定义稳定的提取结果外壳和 JSONL 输出。
4. 增加 ruleset 元数据和 CLI `--ruleset` 加载。
5. 做最小 TSX extractor，支持 React Button、事件 handler、axios 调用提取。
6. 增加前端诊断，解释文案、handler、API path 无法解析的原因。
7. 增加 discovery，发现前端组件、request 封装和 i18n 调用。
8. 等提取结果外壳和 extractor vocabulary 稳定后，再扩展官方 rulesets。

## Near-Term Minimal Loop

The first milestone should be a small but complete frontend extraction loop:

第一个里程碑应该是一个小而完整的前端提取闭环：

```text
React TSX Button
  -> onClick handler
  -> axios/request call
  -> extracted records JSONL
```

This loop proves the multi-language extraction direction with a concrete
end-to-end extraction result.

这个闭环用一个具体的端到端提取结果证明多语言提取方向。
