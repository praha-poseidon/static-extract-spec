# Small-step plan: purify SER + language extractors

Working style: **one git commit ≈ one reviewable step**.  
Prefer green tests after every step. Prefer docs-only or additive changes before
breaking grammar changes.

Repos live in:

| Repo | Role |
|---|---|
| `static-extract-spec` | grammar, schemas, shared examples, this plan |
| `static-extract-java` | Java sugar desugar + JDT execution |
| `static-extract-js` | TS/JS execution (consume purified grammar) |

---

## Principles

1. **Visible on git** — each step has a clear commit message (`step-N: ...`).
2. **Small** — ideally < 1 day of risk; easy to revert one commit.
3. **Compatible first** — keep old Java sugar working with the clean grammar until rules migrate.
4. **Tests gate** — do not merge a step that fails `mvn test` / `npm test`.

---

## Step list (in order)

### Phase A — contract & inventory (no behavior change)

| Step | Repo | What | Done when | Status |
|---|---|---|---|---|
| **A1** | spec | This plan file | Plan merged | **done** (`step-A1`) |
| **A2** | spec | Document “core SER vs Java dialect sugar” table | See `CORE-VS-JAVA-DIALECT.md` | **done** (`step-A2`) |
| **A3** | java | Inventory: list all `.ser` using sugar | Checklist in java repo | **done** (`static-extract-java` `step-A3`, `docs/SUGAR-INVENTORY.md`) |
| **A4** | js | Confirm TS rules already use generic `find` only | Short note in js README | **done** (`static-extract-js` `step-A4`) |

### Phase B — the clean grammar safety net (still no g4 break)

| Step | Repo | What | Done when |
|---|---|---|---|
| **B1** | java | Add `JavaSerDesugarer` that is identity (pass-through) + unit test | Wired but no rewrites yet | **done** |
| **B2** | java | Desugar `find X with annotation @Y` → generic + when | Parser tests green for old sugar text | **done** |
| **B3** | java | Desugar `from annotation on element @Y` | Pass-through until g4 expands source form | **done** (pass-through) |
| **B4** | java | Desugar specialized `when annotation ...` / method patterns as needed | Pass-through for trace when | **done** (pass-through) |
| **B5** | java | Route all SER parse entry points through desugar | CLI + tests use one path | **done** |

### Phase C — purify shared grammar

| Step | Repo | What | Done when |
|---|---|---|---|
| **C1** | spec | Prefer generic find; document dual path | Docs + comments | **done** (via C3 docs) |
| **C2** | java + js | Regenerate ANTLR parsers; tests green | Both extractors build | **done** |
| **C3** | spec | Remove F1–F3 `find with annotation` from g4 | Old sugar only via the clean grammar | **done** |
| **C4** | java + js | Regenerate parsers again; full tests | No sugar left in public g4 |

### Phase D — migrate surface syntax & docs

| Step | Repo | What | Done when |
|---|---|---|---|
| **D1** | spec | Rewrite `examples/java/*` to canonical (non-sugar) form | Examples still pass via java CLI | **done** |
| **D2** | java | Rewrite builtin `.ser` to canonical form (desugar becomes back-compat only) | spring-mvc uses find+when; rest-template still F4 | **done** |
| **D3** | spec | Update `SER_SPEC.md` / `SER_RULES.md`: core vs Java dialect appendix | Docs match g4 | **done** |
| **D4** | java | Mark desugar as compatibility layer; log/metrics optional | Documented |

### Phase E — optional cleanup

| Step | Repo | What |
|---|---|---|
| **E1** | java | Align internal model toward Rule IR strings (less `JavaElementKind` in parse layer) |
| **E2** | all | Release notes / version bump when public g4 sugar is gone |

---

## Commit message convention

```text
step-A1: add small-step purify plan

step-B2: desugar find-with-annotation to generic find+when

step-C3: remove Java sugar productions from Ser.g4
```

One step → one commit (or one PR with a single logical commit).  
If a step grows large, split into `step-B2a`, `step-B2b`.

---

## Current position

- Repos split and pushed: **done**
- **A1** plan: **done**
- **A2** core vs Java dialect table: **done** (`docs/CORE-VS-JAVA-DIALECT.md`)
- **A3** java sugar inventory: **done** (`static-extract-java/docs/SUGAR-INVENTORY.md`)
- **A4** js generic find: **done**
- Phase B desugar safety net: **done** (B1–B5)
- Phase C F1–F3 g4 removal: **done** (C3/C4)
- Phase D1–D3 canonical authoring + docs: **done**
- Phase E annotation source order: **done**
- Phase F4 method-vs-call: **done**
- Phase clean-g4: **done** (see `CLEAN-G4.md`)
- Final cleanup: **done** (dead tokens removed, tests/docs canonical, CI added)
- Remaining optional: IR model unification only (not public syntax)


---

## How we work day-to-day

1. Pick the next open step from this file.
2. Implement only that step.
3. Run the relevant tests.
4. Commit with `step-XX: ...`.
5. Push that repo’s `main` (or open a small PR).
6. Check the step as done in this table (edit in a follow-up micro-commit if needed).
