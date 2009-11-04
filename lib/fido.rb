require 'fileutils'
require 'open3'

class Fido
  include FileUtils

  BACKUP_BRANCH = "fido-backup"

  attr_accessor :logger

  def initialize(logger=Logger.new("/dev/null"))
    @logger = logger
  end

  def clone(repo, *to)
    force = to.last == true && to.pop
    to << "master"

    dir = File.basename(repo, ".git")
    mkdir_p dir

    cd dir do
      return if !force && File.exists?(".git/FIDO")

      if !File.exists?(".git")
        cmd "git init"
        cmd "git remote add origin #{repo}"
      end

      cmd "git fetch origin"

      cmd "git branch -D #{BACKUP_BRANCH}"
      cmd "git checkout -b #{BACKUP_BRANCH}"
      cmd "git add ."
      cmd "git commit -m 'fido backup'"

      branches = cmd("git branch -a")

      to.each do |branch|
        if branches =~ /\* #{branch}\n/
          cmd "git reset --hard origin/#{branch}"
          break
        elsif branches =~ /  remotes\/origin\/#{branch}\n/
          cmd "git branch -D #{branch}" if branches =~ /  #{branch}\n/
          cmd "git checkout -b #{branch} origin/#{branch}"
          break
        end
      end

      touch ".git/FIDO"
    end
  end

  def sh(cmd, *args)
    env = args.pop if args.last.kind_of?(Hash)

    rout, wout = IO.pipe
    rerr, werr = IO.pipe

    # Disable GC before forking in an attempt to get some advantage
    # out of COW.

    GC.disable

    if fork
      # Parent
      wout.close
      werr.close

      Process.wait

      exitstatus = $?.exitstatus
      out = rout.read
      err = rerr.read

      [out, err, exitstatus]
    else
      # Child

      if env
        env.each {|k,v| ENV[k] = v}
      end

      STDOUT.reopen(wout)
      STDERR.reopen(werr)

      system(cmd, *args)

      exit! $?.exitstatus
    end

  ensure
    GC.enable
  end

  def cmd(c)
    @logger.debug c
    out, err, code = sh(c)
    @logger.debug out if out !~ /^\s*$/
    @logger.error err if err !~ /^\s*$/
    out
  end

end
