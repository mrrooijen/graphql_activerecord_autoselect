require_relative "lib/graphql_activerecord_autoselect/version"

Gem::Specification.new do |spec|
  spec.name = "graphql_activerecord_autoselect"
  spec.version = GraphQLActiveRecordAutoSelect::VERSION
  spec.authors = ["Michael van Rooijen"]
  spec.email = ["michael@vanrooijen.io"]
  spec.summary = "Automatic ActiveRecord column selection for GraphQL (Ruby) fields."
  spec.homepage = "https://github.com/mrrooijen/" + spec.name
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/blob/master/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = spec.homepage + "/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}"

  spec.files = `git ls-files -- lib README.md CHANGELOG.md LICENSE.txt`.split("\n")
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")
  spec.add_runtime_dependency "activerecord", ">= 6.0.0", "< 8.0.0"
  spec.add_runtime_dependency "graphql", ">= 1.9.0", "< 2.0.0"
  spec.add_development_dependency "rake", "13.0.6"
  spec.add_development_dependency "yard", "0.9.27"
  spec.add_development_dependency "minitest", "5.15.0"
  spec.add_development_dependency "simplecov", "0.21.2"
end
