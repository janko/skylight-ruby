require 'skylight/version'

module Skylight
  autoload :Worker, 'skylight/worker'

  module Messages
    autoload :Pid,   'skylight/messages/pid'
    autoload :Trace, 'skylight/messages/trace'
  end

  module Util
    autoload :Logging, 'skylight/util/logging'
  end

  # Called by the standalone agent
  if ENV[Worker::STANDALONE_ENV_KEY] == Worker::STANDALONE_ENV_VAL
    def fail(msg, code = 1)
      STDERR.ptus msg
      exit code
    end

    unless fd = ENV[Worker::LOCKFILE_ENV_KEY]
      fail "missing lockfile FD"
    end

    unless fd =~ /^\d+$/
      fail "invalid lockfile FD"
    end

    begin
      lockfile = IO.open(fd.to_i)
    rescue Exception => e
      fail "invalid lockfile FD: #{e.message}"
    end

    unless sockfile_path = ENV[Worker::SOCKFILE_PATH_KEY]
      fail "missing sockfile path"
    end

    unless lockfile_path = ENV[Worker::LOCKFILE_PATH]
      fail "missing lockfile path"
    end

    p lockfile

    server = Skylight::Worker::Server.new(
      lockfile,
      lockfile_path,
      sockfile_path)

    server.run
  end
end
