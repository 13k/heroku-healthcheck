module HealthCheckers::Memcache
  MEMCACHE_PROVIDERS = %w[
    MEMCACHE
    MEMCACHIER
  ]

  def check_memcache(app)
    MEMCACHE_PROVIDERS.each do |provider|
      server = api.get_config_vars(app).body["#{provider}_SERVERS"]
      check_memcache_server(server, provider) if server
    end
  end

  private

  def check_memcache_server(server, provider)
    require 'dalli'
    username = api.get_config_vars(app).body["#{provider}_USERNAME"]
    password = api.get_config_vars(app).body["#{provider}_PASSWORD"]
    memcache_client = Dalli::Client.new server, username: username, password: password, failover: false
    begin
      memcache_client.set 'heroku-health-check', 'OK'
      val = memcache_client.get 'heroku-health-check'
      memcache_client.delete 'heroku-heroku-check'
    rescue
      val = "FAIL\n#{$!.message}"
    ensure
      display "#{provider}: #{val} (#{server})"
    end
  end
end
