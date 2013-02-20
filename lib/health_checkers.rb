module HealthCheckers
end

Dir[File.expand_path("../health_checkers/*.rb", __FILE__)].each do |file|
  require file
end
