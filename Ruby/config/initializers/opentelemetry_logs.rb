# config/initializers/opentelemetry_logs.rb
# Ship logs to an OpenTelemetry endpoint via OTLP.
# Requires opentelemetry_logs to load after opentelemetry.rb (traces).
# Set OTEL_EXPORTER_OTLP_ENDPOINT (e.g. http://alloy:4318) and optionally
# OTEL_LOGS_EXPORTER=otlp (or leave unset to use OTLP). Set OTEL_LOGS_EXPORTER=none
# to disable log export.

unless ENV['OTEL_LOGS_EXPORTER'] == 'none'
  require 'opentelemetry/sdk'
  require 'opentelemetry/sdk/logs'
  require 'opentelemetry-exporter-otlp-logs'

  # Use same base endpoint as traces. LogsExporter appends /v1/logs only when
  # endpoint equals ENV['OTEL_EXPORTER_OTLP_ENDPOINT']; otherwise pass full URL.
  otlp_headers = {}
  if ENV['OTEL_EXPORTER_OTLP_HEADERS']
    ENV['OTEL_EXPORTER_OTLP_HEADERS'].split(',').each do |header|
      key, value = header.split('=', 2)
      otlp_headers[key.strip] = value.strip if key && value
    end
  end

  base = ENV['OTEL_EXPORTER_OTLP_LOGS_ENDPOINT'] || ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] || 'http://alloy:4318'
  logs_endpoint = base.include?('/v1/') ? base : base.chomp('/') + '/v1/logs'

  service_name = ENV['OTEL_SERVICE_NAME'] || 'ruby-app'
  service_namespace = ENV['OTEL_SERVICE_NAMESPACE'] || 'demo'
  resource = OpenTelemetry::SDK::Resources::Resource.create(
    OpenTelemetry::SemanticConventions::Resource::SERVICE_NAME => service_name,
    'service.namespace' => service_namespace
  )

  logs_exporter = OpenTelemetry::Exporter::OTLP::Logs::LogsExporter.new(
    endpoint: logs_endpoint,
    headers: otlp_headers
  )

  log_record_processor = OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(logs_exporter)
  logger_provider = OpenTelemetry::SDK::Logs::LoggerProvider.new(resource: resource)
  logger_provider.add_log_record_processor(log_record_processor)

  # Register as the global LoggerProvider so log bridges (e.g. OtlpAppender) use it
  if OpenTelemetry.respond_to?(:logger_provider=)
    OpenTelemetry.logger_provider = logger_provider
  else
    OpenTelemetry.logger_provider.send(:delegate=, logger_provider)
  end
end
