class HomeController < ApplicationController
  def index
    output = []
    output << "Hello World from Ruby on Rails!"
    output << "Server Time: #{Time.now}"
    output << "Ruby Version: #{RUBY_VERSION}"
    output << "Rails Version: #{Rails.version}"
    output << ""
    output << "OpenTelemetry Environment Variables:"
    output << "=" * 50
    
    # Collect all OTEL_ environment variables
    otel_vars = ENV.select { |key, _| key.start_with?('OTEL_') }
    
    if otel_vars.empty?
      output << "No OTEL_ environment variables found."
    else
      otel_vars.sort.each do |key, value|
        output << "#{key}=#{value}"
      end
    end
    
    render plain: output.join("\n")
  end
end
