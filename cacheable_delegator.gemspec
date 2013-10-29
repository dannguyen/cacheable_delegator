# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "cacheable_delegator"
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Nguyen"]
  s.date = "2013-10-29"
  s.description = "Create a cache model for your active records"
  s.email = "dansonguyen@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "cacheable_delegator.gemspec",
    "lib/cacheable_delegator.rb",
    "spec/cacheable_delegator_spec.rb",
    "spec/mixin_active_record_inline_schema_spec.rb",
    "spec/spec_helper.rb",
    "spec/spec_records.rb"
  ]
  s.homepage = "http://github.com/dannguyen/cacheable_delegator"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.5"
  s.summary = "Create a cache model"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<pry>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.2.14"])
      s.add_runtime_dependency(%q<active_record_inline_schema>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.14.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_development_dependency(%q<activerecord>, ["~> 3.2.14"])
      s.add_development_dependency(%q<database_cleaner>, ["~> 1.0.1"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
    else
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<activesupport>, ["~> 3.2.14"])
      s.add_dependency(%q<active_record_inline_schema>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.14.1"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_dependency(%q<activerecord>, ["~> 3.2.14"])
      s.add_dependency(%q<database_cleaner>, ["~> 1.0.1"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
    end
  else
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<activesupport>, ["~> 3.2.14"])
    s.add_dependency(%q<active_record_inline_schema>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.14.1"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
    s.add_dependency(%q<activerecord>, ["~> 3.2.14"])
    s.add_dependency(%q<database_cleaner>, ["~> 1.0.1"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
  end
end

