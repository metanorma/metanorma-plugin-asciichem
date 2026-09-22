# frozen_string_literal: true

require_relative 'lib/metanorma/plugin/asciichem/version'

Gem::Specification.new do |spec|
  spec.name          = 'metanorma-plugin-asciichem'
  spec.version       = Metanorma::Plugin::Asciichem::VERSION
  spec.authors       = ['Ribose Inc.']
  spec.email         = ['open.source@ribose.com']

  spec.summary       = 'AsciiChem chemistry blocks and substance citations for Metanorma documents.'
  spec.description   = 'Adds [chem] blocks and chem:[] inline macros to Metanorma ' \
                       'AsciiDoc: chemistry written in AsciiChem parses to MathML ' \
                       'for rendering, and @cite-annotated molecules resolve to ' \
                       'dataset-type Relaton bibitems - one per (source, substance), ' \
                       'anchored by InChIKey - automatically collected into the ' \
                       "document's bibliography."

  spec.homepage      = 'https://www.asciichem.org'
  spec.license       = 'BSD-2-Clause'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/metanorma/metanorma-plugin-asciichem'
  spec.metadata['changelog_uri'] = 'https://github.com/metanorma/metanorma-plugin-asciichem/blob/main/CHANGELOG.md'
  spec.metadata['docs_uri'] = 'https://www.asciichem.org'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'asciichem', '~> 0.29', '>= 0.29.2'
  spec.add_dependency 'moxml', '~> 0.5'
end
