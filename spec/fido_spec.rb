$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require 'fido'
require 'recho'

GitDir = File.expand_path(File.dirname(__FILE__) + "/git")
TestRepo = GitDir + "/test-repo.git"

include FileUtils

describe "Fido" do

  def lastSHA
    `git log --format=%H | head -n1`.chomp
  end

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

  it "clones a repo and leaves it at master by default" do
    @fido.clone(TestRepo)
    cd "test-repo" do
      `git branch`.should =~ /\* master/
    end
  end

  it "does a checkout of the first branch if available" do
    cd TestRepo do
      `git branch first`
    end
    @fido.clone(TestRepo, "first")
    cd "test-repo" do
      `git branch`.should =~ /\* first/
    end
  end

  it "does a checkout of the second branch if first is not available" do
    cd TestRepo do
      `git branch second`
    end
    @fido.clone(TestRepo, "first", "second")
    cd "test-repo" do
      `git branch`.should =~ /\* second/
    end
  end

  it "drops a FIDO file one clone" do
    @fido.clone(TestRepo)
    cd "test-repo" do
      File.exists?(".git/FIDO").should == true
    end
  end

  it "does nothing if .git/FIDO exists" do
    cd TestRepo do
      `git branch some-work`
    end

    @fido.clone(TestRepo)

    cd "test-repo" do
      `git checkout -b stay-here 2>/dev/null`
    end

    @fido.clone(TestRepo, "some-work")

    cd "test-repo" do
      `git branch`.should =~ /\* stay-here/
    end
  end

  it "will mirror upstream if forced" do
    sha = nil

    cd TestRepo do
      echo("foo") >> "FOO"
      `git add FOO`
      `git commit -m 'foo'`
      sha = lastSHA
    end

    @fido.clone(TestRepo)

    cd "test-repo" do
      echo("bar") >> "BAR"
      `git add BAR`
      `git commit -m 'foo'`
    end

    @fido.clone(TestRepo, true)

    cd "test-repo" do
      lastSHA.should == sha
    end
  end
end
