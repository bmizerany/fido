$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require 'fido'

GitDir = File.expand_path(File.dirname(__FILE__) + "/git")
TestRepo = GitDir + "/test-repo.git"

include FileUtils

describe "Fido" do

  before do
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
    Fido.clone(TestRepo)
    cd "test-repo" do
      `git branch`.should =~ /\* master/
    end
  end

  it "should checkout the first branch if available" do
    cd TestRepo do
      `git branch first`
    end
    Fido.clone(TestRepo, "first")
    cd "test-repo" do
      `git branch`.should =~ /\* first/
    end
  end

  it "should checkout the second branch if first is not available" do
    cd TestRepo do
      `git branch second`
    end
    Fido.clone(TestRepo, "first", "second")
    cd "test-repo" do
      `git branch`.should =~ /\* second/
    end
  end

end
