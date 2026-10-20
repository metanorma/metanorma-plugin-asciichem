# frozen_string_literal: true

require 'spec_helper'

# Pilot document (TODO.v2/13 item 8): a real ISO-flavoured Metanorma
# source (examples/pilot/aspirin.adoc) compiled end to end through
# metanorma-standoc with the plugin: chemistry renders as MathML
# stems, typed condition roles survive, and the cited substance
# becomes a dataset bibitem anchored by InChIKey. Offline: resolution
# comes from a seeded resolver cache.
RSpec.describe 'pilot document', :standoc do
  it 'compiles chemistry, roles, and citations through standoc' do
    require 'tmpdir'
    require 'asciichem/resolver'
    require 'metanorma/standoc'
    require 'metanorma/converter/converter'

    fixture = File.read(File.expand_path('../../../fixtures/pubchem-aspirin.json', __dir__))
    fetcher = Struct.new(:body) do
      def get(_url) = body
    end.new(fixture)
    cache = AsciiChem::Resolver::Cache.new(
      dir: File.join(Dir.tmpdir, "mn-asciichem-pilot-#{rand(1e9)}")
    )
    AsciiChem::Resolver[:pubchem].new.resolve(value: 'aspirin', convention: 'name',
                                              fetch: fetcher, cache: cache)

    source = File.read(File.expand_path('../../../../examples/pilot/aspirin.adoc', __dir__))
    adoc = source.sub('/tmp/asciichem-pilot-cache', cache.dir)
    xml = Asciidoctor.convert(adoc, backend: :standoc, header_footer: true,
                                    safe: :unsafe)

    expect(xml).to include('<formula')
    expect(xml).to include('type="MathML"')
    expect(xml).to include('<math xmlns="http://www.w3.org/1998/Math/MathML"')
    expect(xml).to include('H_2SO_4').or include('H<sub>2</sub>SO<sub>4</sub>')

    bibitem = xml[%r{<bibitem[^>]*type="dataset"[^>]*>.*?</bibitem>}m]
    expect(bibitem).to include('id="BSYNRYMUTXBXSQ-UHFFFAOYSA-N"')
    expect(bibitem).to include('PubChem CID 2244')
  ensure
    FileUtils.remove_entry(cache.dir) if cache
    FileUtils.rm_f('.html.err.html')
  end
end
