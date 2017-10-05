require File.expand_path('../lib/smart_proxy_dns_f5/dns_f5_version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_dns_f5'
  s.version     = Proxy::Dns::F5::VERSION
  s.date        = Date.today.to_s
  s.license     = 'GPL-3.0'
  s.authors     = ['Doug Forster']
  s.email       = ['doug.forster@gmail.com']
  s.homepage    = 'https://github.com/dforste/smart_proxy_dns_f5'

  s.summary     = "DNS provider plugin for Foreman's smart proxy"
  s.description = "DNS provider plugin for Foreman's smart proxy"

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']

  s.add_development_dependency('rake')
  s.add_development_dependency('mocha')
  s.add_development_dependency('test-unit')
end
