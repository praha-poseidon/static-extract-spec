# Language vocabulary vs shared grammar

The shared grammar is frozen in `CLEAN-G4.md`. There is **no dialect sugar** in
`Ser.g4` and **no compatibility rewrite** in extractors.

- **Shared**: rule/find/from/take/when/build structure (`Ser.g4`)
- **Per extractor**: which `find`/`from` kind words work (vocabulary.md)

Java uses kinds like `method`, `annotation`, `call`.  
JS/TS uses kinds like `jsx`, `call`, `export`, `decorator`.

Unsupported legacy text must be edited to the clean surface; parsers will reject it.
