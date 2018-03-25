MRuby::Gem::Specification.new('mruby-smallhttp') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Nazarii Sheremet'

  spec.add_dependency('mruby-sprintf', :core => 'mruby-sprintf')
  spec.add_dependency('mruby-socket')
  spec.add_dependency('mruby-polarssl')
  spec.add_dependency('mruby-regexp-pcre')
  spec.add_dependency('mruby-json', :github => 'mattn/mruby-json')
end
