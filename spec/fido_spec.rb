$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require 'fido'
require 'recho'

GitDir = File.expand_path(File.dirname(__FILE__) + "/git")
TestRepo = GitDir + "/test-repo.git"

include FileUtils

describe "Fido" do

  before do
    @fido = if $DEBUG
      Fido.new(Logger.new(STDOUT))
    else
      Fido.new
    end

    @pwd = pwd

    mkdir_p TestRepo

    cd TestRepo do
      `git init`
      echo("foo!") > "FOO"
      `git add FOO`
      `git commit -m 'foo'`
    end

    cd GitDir
  end

  after { cd @pwd ; rm_rf GitDir }

  it "should clone a repo and leave it at master by default" do
    @fido.clone(TestRepo)
    cd "test-repo" do
      `git branch`.should =~ /\* master/
    end
  end

  it "should checkout the first branch if available" do
    cd TestRepo do
      `git branch first`
    end
    @fido.clone(TestRepo, "first")
    cd "test-repo" do
      `git branch`.should =~ /\* first/
    end
  end

  it "should checkout the second branch if first is not available" do
    cd TestRepo do
      `git branch second`
    end
    @fido.clone(TestRepo, "first", "second")
    cd "test-repo" do
      `git branch`.should =~ /\* second/
    end
  end

  it "should checkout the local branch if exists" do
    mkdir "test-repo"
    cd "test-repo" do
      `git init`
      echo("foo") > "FOO"
      `git add FOO`
      `git commit -m 'foo'`
      `git branch second`
    end
    @fido.clone(TestRepo, "first", "second")
    cd "test-repo" do
      `git branch`.should =~ /\* second/
    end
  end

  it "should drop a FIDO file one clone" do
    @fido.clone(TestRepo)
    cd "test-repo" do
      File.exists?(".git/FIDO").should == true
    end
  end
end
