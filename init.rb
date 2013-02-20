$:.unshift File.expand_path("../lib", __FILE__)
require 'uri'
require 'net/http'
require 'health_checkers'

class Heroku::Command::HealthCheck < Heroku::Command::Base
  include HealthCheckers::DnsChecker
  include HealthCheckers::Processes
  include HealthCheckers::Releases
  include HealthCheckers::LogStats
  include HealthCheckers::Redis
  include HealthCheckers::Memcache

  # healthcheck
  #
  # displays a variety of information about your application that may indicate any problems
  #
  def index
    validate_arguments!

    Heroku::Command::Status.new.index
    display("")

    styled_header("Checking processes")
    get_processes(app)

    check_domains(app)
    display("")

    styled_header("Recent Releases")
    get_releases(app)
    display("")

    styled_header("Analyzing recent log entries")
    get_log_stats(app)
    display("")

    styled_header("Checking memcache providers")
    check_memcache(app)
    display("")

    styled_header("Checking redis providers")
    check_redis(app)
    display("")

  end

end
