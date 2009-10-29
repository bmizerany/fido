require 'fileutils'
require 'recho'
require 'logger'
require 'open3'

class Fido
  include FileUtils

  attr_accessor :logger

  def initialize(logger = Logger.new(open('/dev/null', 'w')))
    @logger = logger
  end

  def clone(repo, *to)
    to << "master"

    dir = File.basename(repo, ".git")
    mkdir_p dir

    cd dir do
      if !File.exists?(".git")
        cmd "git init"
        cmd "git remote add origin #{repo}"
        cmd "git fetch origin"
      end

      branches = cmd("git branch -a")

      to.each do |branch|
        if branches =~ /[\* ] #{branch}\n/
          break if cmd("git branch") =~ /\* #{branch}/
          cmd "git checkout #{branch}"
          break
        elsif branches =~ /  remotes\/origin\/#{branch}\n/
          cmd "git checkout -b #{branch} origin/#{branch}"
          break
        end
      end
    end
  end

  def cmd(c)
    out, err = nil
    @logger.debug "---> Executing: #{c}"
    Open3.popen3(c) do |_i, o, e|
      out = o.read
      err = e.read
    end
    @logger.debug "---> Output\n#{out}" if out !~ /^\s*$/
    @logger.debug "---> Error\n#{err}"  if err !~ /^\s*$/
    out
  end
end
