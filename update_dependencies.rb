module Bundler
  class Dsl
    def gemspec
      puts "gemspec \n\n"
    end
  end
end

class UpdateDependencies
  attr_reader :dependency_gemfile, :gemfile
  def initialize(path_to_gemfile=nil)
    raise "Needs a location of a dependent Gemfile" unless path_to_gemfile
    @gemfile = "source 'http://rubygems.org' \n\n"
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
    gemfile
  end

  private

  def spaces(group)
    group.to_s == "default" ? "" : "  "
  end

  def ref(source)
    source.ref == "master" ? "" : ", :ref => '" + source.ref + "'"
  end

  def in_group(group)
    gemfile << "\ngroup :" + group + " do\n" unless group == "default"
    yield
    gemfile << "end\n\n" unless group == "default"
  end

  def locked_gemfile
    @locked ||= Bundler::LockfileParser.new(Bundler.read_file("Gemfile.lock"))
  end

  def source_version(source)
    source.version ? ", '" + source.version + "'" : ""
  end

  def print_dependent_sources(gem_source, group)
    locked_gemfile.sources.select {|s| gem_source.name == s.name}.
    map {|s| gemfile << spaces(group) + "gem '" + s.name + "'" + source_version(s) + required(gem_source) + ", :git => '" + s.uri + "'" + ref(s) + "\n"}
  end

  def print_version_sources(gem_source, group)
    locked_gemfile.specs.reject {|s| locked_gemfile.sources.map(&:name).include?(s.name)}.
    select {|s| s.name == gem_source.name}.
    map {|s| gemfile << spaces(group) + "gem '" + s.name + "', '" + s.version.version + "'" + required(gem_source) + "\n"}
  end

  def required(source)
    return "" if source.autorequire.nil?
    source.autorequire.first.nil? ? ", :require => false" : ", :require => '#{source.autorequire.first}'"
  end
end