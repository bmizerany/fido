$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require 'fido'
require 'recho'
require 'logger'

GitDir = File.expand_path(File.dirname(__FILE__) + "/git")
TestRepo = GitDir + "/test-repo.git"

include FileUtils
include Guns

describe "Fido" do

  def lastSHA(branch="")
    `git log --format=%h #{branch} | head -n1`.chomp
  end

  before do

    rm_rf GitDir

    @pwd = pwd

    mkdir_p TestRepo

    logger = Logger.new(STDOUT)
    logger.level = $DEBUG ? Logger::UNKNOWN : Logger::FATAL
    @fido = Fido.new(TestRepo, :workdir => GitDir, :logger => logger)

    cd TestRepo do
      sh! "git init"
      echo("foo!") > "FOO"
      sh! "git add FOO"
      sh! "git commit -m 'foo'"
    end

    cd GitDir
  end

  after { cd @pwd }

  it "fails if no branches given" do
    lambda { @fido.clone }.should.raise RuntimeError
  end

  it "does a checkout of the first branch if available" do
    cd TestRepo do
      `git branch first`
    end
    @fido.clone("first")
    cd "test-repo" do
      `git branch`.should =~ /\* first/
    end
  end

  it "does a checkout of the second branch if first is not available" do
    cd TestRepo do
      `git branch second`
    end
    @fido.clone("first", "second")
    cd "test-repo" do
      `git branch`.should =~ /\* second/
    end
  end

  it "returns true if there is a matching remote branches" do
    @fido.clone("master").should == true
  end

  it "returns false if there are no matching remote branches" do
    @fido.clone("not-a-branch").should == false
  end

  it "goes nothing if .git dir exists" do
    @fido.clone("master")
    sha = nil
    cd "test-repo" do
      echo("foo") > "FOO"
      sh! "git add FOO"
      sh! "git commit -m 'foo'"
      sha = lastSHA
    end
    @fido.clone("master")
    cd "test-repo" do
      sha.should == lastSHA
    end
  end

  it "clone! forces mirror of origin/branch" do
    @fido.clone("master")

    sha = nil
    cd "test-repo" do
      sha = lastSHA
      echo("foo") > "FOO"
      `git add FOO`
      `git commit -m 'foo'`
    end

    @fido.clone!("master")

    cd "test-repo" do
      sha.should == lastSHA
    end
  end

end
