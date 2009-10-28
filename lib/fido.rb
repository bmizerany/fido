require 'fileutils'
require 'recho'

module Fido
  extend FileUtils

  class << self ; attr_accessor :verbose ; end

  def self.clone(repo, *to)
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

  def self.cmd(c)
    puts(c) if verbose
    out = `#{c}`
    print(out) if verbose
    fail(out) if $? != 0
    out
  end
end
