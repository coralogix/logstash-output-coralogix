Gem::Specification.new do |s|
  s.name = 'logstash-output-coralogix'
  s.version = '1.0.0'
  s.licenses = ['Apache-2.0']
  s.summary = 'Deliever the logs to Coralogix service.'
  s.description = 'This gem is a Logstash output plugin to deliver the logs to Coralogix service.'
  s.homepage = 'https://coralogix.com/'
  s.authors = ['Coralogix']
  s.email = 'info@coralogix.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*', 'spec/**/*', 'vendor/**/*', '*.gemspec', '*.md', 'CONTRIBUTORS', 'Gemfile', 'LICENSE', 'NOTICE.TXT']

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = {'logstash_plugin' => 'true', 'logstash_group' => 'output'}

  # Gem dependencies
  s.add_runtime_dependency 'logstash-core-plugin-api', '~> 2.0'
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'centralized_ruby_logger', '>= 0.0.12'

  s.add_development_dependency 'logstash-devutils'
end
