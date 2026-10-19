# Changelog

All notable changes to this project will be documented in this file.

## [0.1.3] - 2026-10-19

### Changed

- `asciichem` floor raised to `~> 0.30`, `>= 0.30.1` (moxml-based XML layer, CML group round-trip fix) and validated: the plugin suite passes against asciichem 0.30.1 with moxml 0.5.146 (the release carrying the namespace-bound XPath fix, lutaml/moxml#398).

- Runtime dependencies slimmed: `asciidoctor` and `nokogiri` are
  gone. The host provides asciidoctor (metanorma-standoc requires
  and registers the gem); the one direct XML touchpoint (setting
  the InChIKey anchor on the emitted bibitem) now goes through
  `moxml` (`~> 0.5`), the same adapter layer the rest of the
  lutaml ecosystem uses.

## [0.1.1] - 2026-09-22

### Changed

- Dependency floors raised to the suite-validated versions,
  pessimistically: `asciichem ~> 0.29, >= 0.29.2`, `nokogiri
  ~> 1.18`; `asciidoctor` unchanged.

## [0.1.0] - 2026-09-22

First release, published under the final name and namespace (the
rename from the pre-release `asciichem/metanorma-asciichem` layout
happened before anything shipped, so it is invisible to users).

### Added

- `[chem]` block: AsciiChem source parses to the semantic model and
  renders as a MathML stem (`<formula><stem type="MathML">` in
  Metanorma semantic XML). Block ids and titles carry over; invalid
  sources log an error and keep the block as sourcecode.
- `chem:[]` inline macro (target and attribute forms) for inline
  chemistry, emitting the core-stem node shape so metanorma
  converters dispatch it correctly.
- Substance citations: `@cite`-annotated molecules in `[chem]` blocks
  resolve through `AsciiChem::Citation` to dataset-type Relaton
  bibitems, one per (source, substance), deduplicated, anchored by
  InChIKey, appended as a `[bibliography]` section.
- `:asciichem-cache-dir:` document attribute for offline,
  reproducible citation resolution.
- End-to-end metanorma-standoc compile spec (`standoc_spec.rb`);
  per the plugin contract the gem exposes extension classes and the
  host (metanorma-standoc) registers them, as it does for
  lutaml/glossarist.
- Citation anchors are derived from the emitted bibitem XML (works
  under both relaton-bib major lines) instead of vendor object APIs.
