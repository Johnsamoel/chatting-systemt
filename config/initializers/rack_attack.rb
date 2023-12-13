# config/initializers/scheduler.rb

class Rack::Attack
  throttle('req/ip', limit: 200, period: 15.minute) do |req|
    req.ip
  end


  self.throttled_responder = lambda do |env|

    [
      429,                          # status code
      {'Content-Type' => 'application/json'},
      [{ error: 'Rate limit exceeded. Please try again later.' }.to_json]
    ]
  end
end