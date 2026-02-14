# Semantic Logger configuration
# rails_semantic_logger automatically replaces Rails.logger with SemanticLogger
# Configure it to output JSON to STDOUT following OpenTelemetry data model conventions

require_relative '../../lib/logger/otel_formatter'

# Configure SemanticLogger to output JSON to STDOUT
SemanticLogger.default_level = :info

# Add appender that writes to STDOUT with OpenTelemetry-compliant JSON formatting
SemanticLogger.add_appender(
  io: STDOUT,
  formatter: Loggers::OtelFormatter.new
)

# Ship logs to OpenTelemetry endpoint via OTLP (when opentelemetry_logs is configured)
if defined?(OpenTelemetry) && OpenTelemetry.respond_to?(:logger_provider) && ENV['OTEL_LOGS_EXPORTER'] != 'none'
  require_relative '../../lib/logger/otlp_appender'
  SemanticLogger.add_appender(appender: Loggers::OtlpAppender.new)
end

# Configure Rails Semantic Logger to use the same formatter
Rails.application.config.rails_semantic_logger.format = Loggers::OtelFormatter.new

# Test log message
logger = SemanticLogger['ruby-app']
logger.info('Semantic Logger configured successfully with OpenTelemetry formatter')
