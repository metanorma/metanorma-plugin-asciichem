# frozen_string_literal: true

require 'spec_helper'

# Full-document integration: a document that mixes chem blocks, an
# inline macro, an xref to a not-yet-emitted anchor, and citations
# resolved offline through a seeded resolver cache (the
# asciichem-cache-dir document attribute). Asserts the AST the
# standoc converter consumes (the standoc-side mechanisms - <math>
# detection typing stems MathML, [pass] bibitem unwrapping into
# <references> - are validated separately; see README
# "Compatibility").
RSpec.describe 'metanorma-asciichem document' do
  it 'renders chemistry and collects the substance bibliography offline' do
    require 'tmpdir'
    require 'asciichem/resolver'

    fixture = File.read(File.expand_path('../../../fixtures/pubchem-aspirin.json', __dir__))
    fetcher = Struct.new(:body) do
      def get(_url) = body
    end.new(fixture)
    cache = AsciiChem::Resolver::Cache.new(
      dir: File.join(Dir.tmpdir, "mn-asciichem-doc-#{rand(1e9)}")
    )
    AsciiChem::Resolver[:pubchem].new.resolve(value: 'aspirin', convention: 'name',
                                              fetch: fetcher, cache: cache)

    adoc = <<~ADOC
      = Aspirin monograph
      Author
      :asciichem-cache-dir: #{cache.dir}

      == Synthesis

      [chem]
      ----
      2H_2 + O_2 -> 2H_2O
      ----

      The structure is <<BSYNRYMUTXBXSQ-UHFFFAOYSA-N>>.

      [chem]
      ----
      CC(=O)OC1=CC=CC=C1C(=O)O @name("aspirin") @cite("pubchem")
      ----

      Inline water: chem:H_2O[] in prose.
    ADOC

    doc = Asciidoctor.load(adoc, safe: :safe)
    doc.convert

    stems = doc.find_by(context: :stem)
    expect(stems.length).to eq(2)
    expect(stems.map { |s| s.lines.join("\n") }).to all(start_with('<math'))

    biblio = doc.blocks.last
    expect(biblio).to be_a(Asciidoctor::Section)
    expect(biblio.style).to eq('bibliography')
    expect(biblio.title).to eq('Bibliography')

    entry = biblio.blocks.first
    expect(entry.context).to eq(:pass)
    expect(entry.lines.join).to include('id="BSYNRYMUTXBXSQ-UHFFFAOYSA-N"')
    expect(entry.lines.join).to include('PubChem CID 2244')
  ensure
    FileUtils.remove_entry(cache.dir) if cache
  end

  it 'limits sources with the asciichem-sources attribute' do
    require 'tmpdir'
    require 'asciichem/resolver'

    pubchem_body = File.read(File.expand_path('../../../fixtures/pubchem-aspirin.json', __dir__))
    cc_body = File.read(File.expand_path('../../../fixtures/common-chemistry-aspirin.json', __dir__))
    fetcher = Struct.new(:pubchem, :common_chemistry, keyword_init: true) do
      def get(url)
        url.include?('commonchemistry') ? common_chemistry : pubchem
      end
    end.new(pubchem: pubchem_body, common_chemistry: cc_body)
    cache = AsciiChem::Resolver::Cache.new(
      dir: File.join(Dir.tmpdir, "mn-asciichem-sources-#{rand(1e9)}")
    )
    # Seed both sources so the limiting (not the fetch) is what's under test.
    AsciiChem::Resolver[:pubchem].new.resolve(value: '50-78-2', convention: 'cas',
                                              fetch: fetcher, cache: cache)
    AsciiChem::Resolver[:common_chemistry].new.resolve(value: '50-78-2', convention: 'cas',
                                                       fetch: fetcher, cache: cache)

    adoc = <<~ADOC
      = Aspirin monograph
      Author
      :asciichem-cache-dir: #{cache.dir}
      :asciichem-sources: pubchem

      [chem]
      ----
      CC(=O)OC1=CC=CC=C1C(=O)O @cas("50-78-2") @cite("common_chemistry")
      ----
    ADOC

    doc = Asciidoctor.load(adoc, safe: :safe)
    doc.convert

    # common_chemistry is outside the allow-list: no bibliography section.
    expect(doc.blocks.last).not_to be_a(Asciidoctor::Section)
  ensure
    FileUtils.remove_entry(cache.dir) if cache
  end
end
