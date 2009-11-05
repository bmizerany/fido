require 'fileutils'
require 'open3'
require 'guns'

class Fido
  include FileUtils
  include Guns

  FATAL = 4

  attr_accessor :logger

  def initialize(url, options={})
    @logger = options[:logger] || (l = Logger.new(STDOUT) ; l.level = FATAL ; l)
    @url    = url
    @workdir = File.expand_path(
      File.join(
        options[:workdir] || pwd,
        File.basename(url, ".git")
      )
    )
    @gitdir = File.join(@workdir, ".git")
    @logger = logger
  end

  def clone!(*branches)
    fail "No branches specified." if branches.empty?

    mkdir_p @gitdir

    found = false

    cd @gitdir do
      git "init"
      if git("remote").grep(/origin/).empty?
        git "remote add origin", @url
      end
      git "fetch origin"

      @branches = git("branch -a")

      branches.each do |branch|
        if found = branch?("remotes/origin/#{branch}")
          if branch?(branch)
            git "checkout", branch
            git "reset --hard origin/#{branch}"
          else
            git "checkout -b", branch, "origin/#{branch}"
          end
        end
      end
    end

    found
  end

  def clone(*branches)
    return false if File.directory?(@gitdir) 
    clone!(*branches)
  end

  def git(cmd, *args)
    command = [
      "git",
      "--git-dir=#{@gitdir}",
      "--work-tree=#{@workdir}",
      cmd,
      *args
    ].join(" ")
    logger.debug(command)
    out, err, code = Guns.sh! command
    logger.debug(out)
    logger.debug(err)
    out
  end

  def branch?(branch, current=nil)
    prefix = case current
    when nil
      /[\* ]/
    when :current
      /\* /
    when :not_current
      / /
    else
      fail "unknow state #{current.inspect}"
    end

    @branches =~ /#{current} #{branch}\n/ ? true : false
  end

end
