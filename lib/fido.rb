require 'fileutils'
require 'open3'
require 'logger'
require 'hutils/logable'

class Fido
  include FileUtils
  include Logable

  def clone(repo, *to)
    to << "master"

    dir = File.basename(repo, ".git")
    mkdir_p dir

    cd dir do
      return if File.exists?(".git/FIDO")

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

      touch ".git/FIDO"
    end
  end

  def cmd(c)
    out, err = nil
    @logger.debug c
    Open3.popen3(c) do |_i, o, e|
      out = o.read
      err = e.read
    end
    @logger.debug out if out !~ /^\s*$/
    @logger.error err if err !~ /^\s*$/
    out
  end
end
