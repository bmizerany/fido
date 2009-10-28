require 'fileutils'
require 'recho'

module Fido
  extend FileUtils

  def self.clone(repo, to="master")
    `git clone #{repo}`
    cd File.basename(repo, ".git") do
      `git checkout -b #{to} origin/#{to}`
    end
  end
end
