require_relative "lib/erb_component/version"

Gem::Specification.new do |spec|
  spec.name          = "erb_component"
  spec.version       = ErbComponent::VERSION
  spec.authors       = ["Arthur Karganyan"]
  spec.email         = ["arthur.karganyan@gmail.com"]

  spec.summary       = "React-style front-end components but for ERB?"
  spec.description   = "React-style front-end components but for ERB?"
  spec.homepage      = "https://github.com/arthurkarganyan/erb_component"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/arthurkarganyan/erb_component"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
