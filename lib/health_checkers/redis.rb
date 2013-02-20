module HealthCheckers::Redis
  REDIS_PROVIDERS = %w[
    REDISTOGO
  ]

  def check_redis(app)
    REDIS_PROVIDERS.each do |provider|
      uri = api.get_config_vars(app).body["#{provider}_URL"]
      check_redis_server(uri, provider) if uri
    end
  end

  private

  def check_redis_server(uri, provider)
    require 'redis'
    uri_values = URI.parse(uri)
    redis_client = Redis.new(host: uri_values.host, port: uri_values.port, password: uri_values.password)
    begin
      val = redis_client.set "heroku-health-check", "OK"
      redis_client.del "heroku-health-check"
    rescue
      val = "FAIL\n#{$!.message}"
    ensure
      display "#{provider}: #{val} (#{uri_values.host})"
    end
  end
end
