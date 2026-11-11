# Changelog

All notable changes to this project will be documented in this file.

## [0.1.8] - 2026-11-11

### Changed
- asciichem floor consumed at 0.31.12 (the citation `sources:`
  allow-list). All shipped sources — PubChem, OPSIN, CAS Common
  Chemistry — now resolve by default (maintainer decision:
  CC BY-NC 4.0 acceptable on by default; attribution rides every
  record and bibitem).

### Added
- The `asciichem-sources` document attribute: a comma-separated
  allow-list limiting what the document's `@cite` annotations may
  resolve against (e.g. `:asciichem-sources: pubchem,opsin` keeps a
  document NC-free). Cited sources outside the list are skipped with
  a warning — no bibitem, build stays green.
- Prose framed for the Metanorma plugin contract (the host is
  Metanorma; extension registration is the host's).

## [0.1.7] - 2026-11-10

### Changed
- asciichem gem floor consumed at 0.31.11: `@cite` dataset bibitems
  now carry the resolver provenance as a note (retrieval source,
  version, and the source's required attribution — CAS Common
  Chemistry results carry the CC BY-NC 4.0 terms into the rendered
  document).

## [0.1.6] - 2026-11-05

### Changed
- moxml pinned to the 0.6 line from 0.6.1 (the follow-up to the 0.6
  forward-pin: resolves to 0.6.2; suite green against it).

## [0.1.4] - 2026-10-21

### Added
- Pilot document: `examples/pilot/aspirin.adoc` — aspirin end to end
  through standoc (a `[chem]` block rendering as MathML plus an
  `@cite` dataset bibitem), compiled in CI.

### Changed
- README: pilot document section.

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
