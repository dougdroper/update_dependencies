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

  it "matches a source" do
    Bundler.stub(:read_file)
    Bundler::Dsl.stub(:new => stub(:eval_gemfile => [stub(:groups => [:default], :name => "testgem", :autorequire => [])]))
    source = stub(:name => "testgem", :uri => "www.example.com", :ref => "33g6tw")
    Bundler::LockfileParser.stub(:new => stub(:sources => [source], :specs => [stub(:name => "testgem3")]))
    dependency = UpdateDependencies.new("")
    dependency.run_dependencies.should =~ /gem 'testgem', :require => false, :git => 'www.example.com', :ref => '33g6tw'/
  end
end

describe "UpdateDependencies::spec" do
  before do
    Bundler.stub(:read_file)
    Bundler::Dsl.stub(:new => stub(:eval_gemfile => [stub(:groups => [:default], :name => "testgem", :autorequire => [])]))
    source = stub(:name => "testgem2")
    spec = stub(:name => "testgem", :version => stub(:version => "0.1.0"))
    Bundler::LockfileParser.stub(:new => stub(:sources => [source], :specs => [spec]))
    @dependency = UpdateDependencies.new("")
  end

  it "matches a spec" do
    @dependency.run_dependencies.should =~ /gem 'testgem', '0.1.0', :require => false/
  end

  it "has no require when there is no autorequire" do
    @dependency.run_dependencies.should =~ /gem 'testgem', '0.1.0', :require => false/
  end
end