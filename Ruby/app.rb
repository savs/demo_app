require_relative 'config/initializers/opentelemetry'
require 'webrick'

tracer = OpenTelemetry.tracer_provider.tracer('ruby-web')

server = WEBrick::HTTPServer.new(Port: 4567, BindAddress: '0.0.0.0')

server.mount_proc '/' do |req, res|
  tracer.in_span('handle_request', attributes: { 'http.method' => req.request_method, 'http.path' => req.path }) do |span|
    res.content_type = 'text/plain'
    res.body = "Hello World from Ruby!\nServer Time: #{Time.now}\nRuby Version: #{RUBY_VERSION}\n"
    span.set_attribute('http.status_code', 200)
  end
end

trap('INT') { server.shutdown }
trap('TERM') { server.shutdown }

puts "Starting Ruby app with OpenTelemetry enabled..."
server.start
