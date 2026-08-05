# Functional Capability Matrix

Static Extract's current Java extractor is designed around Java/JDT elements, not framework-specific code paths.

Static Extract 当前 Java extractor 的核心是 Java/JDT 元素能力，不是针对某个框架写死解析逻辑。

The table below lists the generic capabilities that are covered by functional tests.

下面的表列出当前已经用功能测试覆盖的通用能力。

| Capability | SER shape | Covered by |
| --- | --- | --- |
| Find method by annotation | `find method
when annotation @OperationDoc on method` | `FunctionalCapabilityMatrixTest.extractsGenericAnnotationFieldParameterReturnAndNewElements` |
| Find method call by owner/name | `find call Gateway.submit` | `FunctionalCapabilityMatrixTest.extractsGenericMethodCallArgumentsAndCallMetadata` |
| Read class annotation attribute | `from annotation @EntityDoc on class take attr(value)` | `FunctionalCapabilityMatrixTest.extractsGenericAnnotationFieldParameterReturnAndNewElements` |
| Read method annotation attribute | `from annotation @OperationDoc on method take attr(name)` | `FunctionalCapabilityMatrixTest.extractsGenericAnnotationFieldParameterReturnAndNewElements` |
| Read parameter annotation attribute | `from annotation @Input on parameter take attr(value)` | `FunctionalCapabilityMatrixTest.extractsGenericAnnotationFieldParameterReturnAndNewElements` |
| Read field value | `from field PREFIX take value` | `FunctionalCapabilityMatrixTest.extractsGenericAnnotationFieldParameterReturnAndNewElements` |
| Find field by name | `find field baseUrl` | `FunctionalCapabilityMatrixTest.findsFieldByNameWithoutFrameworkSpecificCode` |
| Find field by annotation | `find field
when annotation @ConfigProperty on field` | `FunctionalCapabilityMatrixTest.findsFieldsByAnnotationAndResolvesExternalDictionaryValues` |
| Read parameter metadata | `from parameter accountId take name` | `FunctionalCapabilityMatrixTest.extractsGenericAnnotationFieldParameterReturnAndNewElements` |
| Trace returned value | `from return take value` | `FunctionalCapabilityMatrixTest.extractsGenericAnnotationFieldParameterReturnAndNewElements` |
| Read new expression type | `from new AuditRecord take type` | `FunctionalCapabilityMatrixTest.extractsGenericAnnotationFieldParameterReturnAndNewElements` |
| Read call arguments | `from argument[0] take value` | `FunctionalCapabilityMatrixTest.extractsGenericMethodCallArgumentsAndCallMetadata` |
| Read call metadata | `from call take name`, `from call take owner`, `from call take raw` | `FunctionalCapabilityMatrixTest.extractsGenericMethodCallArgumentsAndCallMetadata` |
| Map output values | `value | map { create: CREATE }` | `FunctionalCapabilityMatrixTest.extractsGenericMethodCallArgumentsAndCallMetadata` |
| Normalize path variables | `value | normalize pathVariable` | `FunctionalCapabilityMatrixTest.extractsGenericMethodCallArgumentsAndCallMetadata` |
| Trace external field entry | `from field` + `when annotation @ConfigRef on field` | `FunctionalCapabilityMatrixTest.resolvesGenericExternalValuesFromFieldAnnotationAndMethodCallTraceRules` |
| Trace external call entry | `from call` + `when method ConfigStore.lookup` | `FunctionalCapabilityMatrixTest.resolvesGenericExternalValuesFromFieldAnnotationAndMethodCallTraceRules` |
| Resolve external dictionary value | `namespace` + `lookup` build fields | `FunctionalCapabilityMatrixTest.resolvesGenericExternalValuesFromFieldAnnotationAndMethodCallTraceRules` |
| Placeholder lookup/default split | `normalize placeholderLookup`, `normalize placeholderDefault` | `FunctionalCapabilityMatrixTest.resolvesGenericExternalValuesFromFieldAnnotationAndMethodCallTraceRules` |
| Concat string literals in build | `concat(basePath, "/", methodPath)` | `AntlrSerRuleParserTest.parsesSpringMvcInboundRuleShape` |

## Real Project Validation

A sibling consumer project verifies the Java extractor as an external dependency.

同级验证工程像普通用户一样引入 jar，从外部验证 Java extractor 能力。

It currently runs against:

当前已经跑过这些真实项目：

| Target | Rules | Last observed output |
| --- | --- | --- |
| Spring Petclinic | Spring MVC SER rules | 17 records |
| Quarkus Quickstarts | JAX-RS SER rules | 527 records |
| Quarkus Quickstarts | JAX-RS + ConfigProperty trace + external dictionary | 569 records, including 42 config field records |

The benchmark rules live in the consumer project, not in `java/jdt`.

这些验证规则放在 consumer 工程里，不内置到 `java/jdt`。

## What This Proves

These tests intentionally use custom demo classes and annotations such as `EntityDoc`, `OperationDoc`, `Gateway`, `ConfigRef`, and `ConfigStore`.

这些测试刻意使用自定义业务类和注解，例如 `EntityDoc`、`OperationDoc`、`Gateway`、`ConfigRef`、`ConfigStore`。

That makes the tests different from Spring MVC or RestTemplate examples: they prove the engine is extracting Java elements through the generic JDT model, and framework behavior is expected to be expressed by user SER rules.

这和 Spring MVC、RestTemplate 样例不同：它证明引擎是通过通用 JDT 模型提取 Java 元素，框架行为应该由用户自己的 SER 规则组合出来。

## Current Boundary

The engine does not execute runtime framework logic, reflection, dependency injection lifecycle, or expression languages.

当前引擎不执行运行时框架逻辑、反射、依赖注入生命周期或表达式语言。

When a value cannot be reduced to a Java literal through static tracing, SER trace rules can describe external value entry points and an `ExternalValueResolver` can provide values from configuration maps or user-defined sources.

当一个值无法通过静态追踪还原成 Java 字面量时，SER trace 规则可以描述外部值入口，`ExternalValueResolver` 可以从配置字典或用户自定义来源提供值。
