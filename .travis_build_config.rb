MRuby::Build.new do |conf|
  toolchain :gcc
  conf.gembox 'default'
  conf.gem :mgem => 'mruby-smallhttp'
  conf.enable_test
end
