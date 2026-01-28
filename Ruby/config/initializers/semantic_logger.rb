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

# Configure Rails Semantic Logger to use the same formatter
Rails.application.config.rails_semantic_logger.format = Loggers::OtelFormatter.new

# Test log message
logger = SemanticLogger['ruby-web']
logger.info('Semantic Logger configured successfully with OpenTelemetry formatter')
