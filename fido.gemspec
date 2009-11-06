Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'fido'
  s.version = '0.2.0'
  s.date = '2009-10-30'

  s.description = "Fido - he fetches"
  s.summary     = s.description

  s.authors = ["Blake Mizerany"]
  s.email = "blake.mizerany@gmail.com"

  s.files = %w[
    README.md
    fido.gemspec
    lib/fido.rb
    bin/fido
    spec/fido_spec.rb
  ]
  s.executables = ['fido']

  s.add_dependency 'guns', '>= 0.1.3'

  s.extra_rdoc_files = %w[README.md]

  s.homepage = "http://github.com/bmizerany/fido/"
  s.require_paths = %w[lib]
  s.rubygems_version = '1.1.1'
end
