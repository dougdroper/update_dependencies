module Bundler
  class Dsl
    def gemspec
      puts "gemspec \n\n"
    end
  end
end

class UpdateDependencies
  attr_reader :dependency_gemfile
  def initialize(path_to_gemfile)
    raise "Needs a location of a dependent Gemfile" unless path_to_gemfile
    puts "source 'http://rubygems.org' \n\n"
    @dependency_gemfile = Bundler::Dsl.new.eval_gemfile(path_to_gemfile)
  end

  def run_dependencies
    dependency_gemfile.group_by {|g| g.groups.first }.each do |group, gem_sources|
      in_group(group.to_s) do
        gem_sources.each do |gem_source|
          print_dependent_sources(gem_source, group)
          print_version_sources(gem_source, group)
        end
      end
    end
  end

  private

  def spaces(group)
    group.to_s == "default" ? "" : "  "
  end

  def ref(source)
    source.ref == "master" ? "" : ", ref => '" + source.ref + "'"
  end

  def in_group(group)
    puts  "\ngroup :" + group + " do" unless group == "default"
    yield
    puts "end" unless group == "default"
  end

  def locked_gemfile
    @locked ||= Bundler::LockfileParser.new(Bundler.read_file("Gemfile.lock"))
  end

  def print_dependent_sources(gem_source, group)
    locked_gemfile.sources.select {|s| gem_source.name == s.name}.
    map {|s| puts spaces(group) + "gem '" + s.name + "', :git => '" + s.uri + "'" + ref(s)}
  end

  def print_version_sources(gem_source, group)
    locked_gemfile.specs.reject {|s| locked_gemfile.sources.map(&:name).include?(s.name)}.
    select {|s| s.name == gem_source.name}.
    map {|s| puts spaces(group) + "gem '" + s.name + "', '" + s.version.version + "'"}
  end
end