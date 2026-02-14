# config/initializers/opentelemetry.rb
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/all'

# Parse OTLP headers if provided
otlp_headers = {}
if ENV['OTEL_EXPORTER_OTLP_HEADERS']
  ENV['OTEL_EXPORTER_OTLP_HEADERS'].split(',').each do |header|
    key, value = header.split('=', 2)
    otlp_headers[key.strip] = value.strip if key && value
  end
end

OpenTelemetry::SDK.configure do |c|
  c.service_name = ENV['OTEL_SERVICE_NAME'] || 'ruby-app'
  
  # Add console exporter if OTEL_TRACES_EXPORTER includes 'console'
  if ENV['OTEL_TRACES_EXPORTER']&.include?('console')
    # Create a simple console exporter that prints to STDOUT
    console_exporter = Class.new(OpenTelemetry::SDK::Trace::Export::SpanExporter) do
      def export(spans, timeout: nil)
        spans.each do |span|
          puts "\n=== OpenTelemetry Trace ==="
          puts "Span: #{span.name}"
          puts "Trace ID: #{span.trace_id.unpack1('H*')}"
          puts "Span ID: #{span.span_id.unpack1('H*')}"
          puts "Attributes: #{span.attributes.inspect}" if span.attributes.any?
          puts "==========================\n"
        end
        OpenTelemetry::SDK::Trace::Export::SUCCESS
      end
      
      def shutdown(timeout: nil)
        OpenTelemetry::SDK::Trace::Export::SUCCESS
      end
    end.new
    
    c.add_span_processor(
      OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(console_exporter)
    )
  end
  
  # Configure OTLP exporter with proper endpoint if OTEL_TRACES_EXPORTER includes 'otlp'
  if ENV['OTEL_TRACES_EXPORTER']&.include?('otlp') || ENV['OTEL_TRACES_EXPORTER'].nil?
    otlp_endpoint = ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] || 'http://alloy:4318'
    protocol = ENV['OTEL_EXPORTER_OTLP_PROTOCOL'] || 'http/protobuf'
    
    # Add /v1/traces path if using HTTP and not present
    if protocol == 'http/protobuf' && !otlp_endpoint.include?('/v1/traces')
      otlp_endpoint = otlp_endpoint.chomp('/') + '/v1/traces'
    end
    
    c.add_span_processor(
      OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
        OpenTelemetry::Exporter::OTLP::Exporter.new(
          endpoint: otlp_endpoint,
          headers: otlp_headers
        )
      )
    )
  end
  
  # Enable all instrumentation
  c.use_all()
end
