# Functional matrix (clean SER)

Examples use structure keywords + free atoms. Paths refer to Java tests unless noted.

| Capability | Clean SER fragment | Coverage |
|---|---|---|
| Find annotated method | `find method` + `when annotation @OperationDoc on method` | FunctionalCapabilityMatrixTest |
| Find method call | `find call Gateway.submit` | FunctionalCapabilityMatrixTest |
| Class annotation attr | `from annotation @EntityDoc on class take attr(value)` | FunctionalCapabilityMatrixTest |
| Method annotation attr | `from annotation @OperationDoc on method take attr(name)` | FunctionalCapabilityMatrixTest |
| Parameter annotation | `from annotation @Input on parameter take attr(value)` | FunctionalCapabilityMatrixTest |
| Find annotated field | `find field` + `when annotation @ConfigProperty on field` | FunctionalCapabilityMatrixTest |
| Argument value | `from argument[0] take value` | multiple tests |
| JSX / fetch (JS) | `find jsx button` / `find call fetch` | static-extract-js examples |

Grammar: `docs/CLEAN-G4.md`.
