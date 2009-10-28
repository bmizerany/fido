require 'fileutils'
require 'recho'

module Fido
  extend FileUtils

  def self.clone(repo, *to)
    cmd "git clone #{repo}"
    cd File.basename(repo, ".git") do
      cmd "git fetch origin"
      branches = cmd("git branch -r")
      to.each do |branch|
        next if branches !~ /  origin\/#{branch}/
        cmd "git checkout -b #{branch} origin/#{branch}"
      end
    end
  end

  def self.cmd(c)
    out = `#{c}`
    fail(out) if $? != 0
    out
  end
end
