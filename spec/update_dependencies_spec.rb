require 'spec_helper'

describe UpdateDependencies do
  it "raises an error with no Gemfile" do
    expect { UpdateDependencies.new }.to raise_error(RuntimeError, "Needs a location of a dependent Gemfile")
  end

  it "raises when it can't find a Gemfile" do
    expect { UpdateDependencies.new("") }.to raise_error(Errno::ENOENT)
  end

  it "has rubygems as a default source" do
    Bundler::Dsl.stub(:new => stub(:eval_gemfile => ""))
    UpdateDependencies.new("").gemfile.should == "source 'http://rubygems.org' \n\n"
  end
end

describe "UpdateDependencies::source" do
  before do
    Bundler.stub(:read_file)
    Bundler::Dsl.stub(:new => stub(:eval_gemfile => [stub(:groups => [:default], :name => "testgem", :autorequire => [])]))
    @source = stub(:name => "testgem", :uri => "www.example.com", :ref => "33g6tw", :version => nil)
    Bundler::LockfileParser.stub(:new => stub(:sources => [@source], :specs => [stub(:name => "testgem3")]))
    @dependency = UpdateDependencies.new("")
  end

  it "matches a source" do
    @dependency.run_dependencies.should =~ /gem 'testgem', :require => false, :git => 'www.example.com', :ref => '33g6tw'/
  end

  it "has a version in the source" do
    @source.stub(:version => "0")
    @dependency.run_dependencies.should =~ /gem 'testgem', '0', :require => false, :git => 'www.example.com', :ref => '33g6tw'/
  end
end

describe "UpdateDependencies::spec" do
  before do
    Bundler.stub(:read_file)
    @evaled_gemfile = stub(:groups => [:default], :name => "testgem", :autorequire => [])
    Bundler::Dsl.stub(:new => stub(:eval_gemfile => [@evaled_gemfile]))
    source = stub(:name => "testgem2")
    @version = stub(:version => "0.1.0")
    spec = stub(:name => "testgem", :version => @version)
    Bundler::LockfileParser.stub(:new => stub(:sources => [source], :specs => [spec]))
    @dependency = UpdateDependencies.new("")
  end

  it "matches a spec" do
    @dependency.run_dependencies.should =~ /gem 'testgem', '0.1.0', :require => false/
  end

  it "has no require when there is no autorequire" do
    @evaled_gemfile.stub(:autorequire => nil)
    @dependency.run_dependencies.should =~ /gem 'testgem', '0.1.0'/
  end

  it "has a specific require" do
    @evaled_gemfile.stub(:autorequire => ["test_gem"])
    @dependency.run_dependencies.should =~ /gem 'testgem', '0.1.0', :require => 'test_gem'/
  end

  it "has a version of 0" do
    @version.stub(:version => "0")
    @dependency.run_dependencies.should =~ /gem 'testgem', '0', :require => false/
  end
end