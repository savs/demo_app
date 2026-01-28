# lib/logger/otel_formatter.rb
require 'semantic_logger'

module Loggers
  class OtelFormatter < SemanticLogger::Formatters::Json
    def call(log, logger)
      # https://opentelemetry.io/docs/specs/otel/logs/data-model/#log-and-event-record-definition
      output = {
        timestamp:      log.time.utc.iso8601(9),
        severity_text:  log.level.upcase,
        severity_number: map_severity_to_number(log.level),
        body:           log.message,
        attributes:     {}
      }

      # https://opentelemetry.io/docs/specs/otel/logs/data-model/#trace-context-fields
      if log.named_tags
        output[:trace_id]    = log.named_tags[:trace_id]
        output[:span_id]     = log.named_tags[:span_id]
        output[:trace_flags] = log.named_tags[:trace_sampled] ? "01" : "00"
        
        # Create a copy of named_tags to avoid mutating the original
        remaining_tags = log.named_tags.dup
        remaining_tags.delete(:trace_id)
        remaining_tags.delete(:span_id)
        remaining_tags.delete(:trace_sampled)
        
        output[:attributes].merge!(remaining_tags) if remaining_tags.any?
      end

      # https://opentelemetry.io/docs/specs/semconv/registry/attributes/exception/
      if log.exception
        output[:attributes]['exception.type']       = log.exception.class.name
        output[:attributes]['exception.message']    = log.exception.message
        output[:attributes]['exception.stacktrace'] = log.exception.backtrace&.join("\n")
      end

      if log.payload.is_a?(Hash)
        map_payload_to_semantic_conventions(log.payload, output[:attributes])
      end

      output.to_json
    end

    private

    # https://opentelemetry.io/docs/specs/otel/logs/data-model/#field-severitynumber
    def map_severity_to_number(level)
      case level
      when :trace then 1
      when :debug then 5
      when :info  then 9
      when :warn  then 13
      when :error then 17
      when :fatal then 21
      else 9
      end
    end

    # Rename Rails keys to OTel Semantic Conventions
    def map_payload_to_semantic_conventions(payload, attributes)
      payload.each do |key, value|
        new_key = case key
        when :method   then 'http.request.method'
        when :path     then 'url.path'
        when :status   then 'http.response.status_code'
        when :duration then 'rails.duration'
        when :db_runtime then 'rails.db_runtime'
        when :view_runtime then 'rails.view_runtime'
        when :allocations then 'rails.allocations'
        when :queries_count then 'rails.queries_count'
        when :cached_queries_count then 'rails.cached_queries_count'
        when :status_message then 'rails.status_message'
        when :controller then 'rails.controller'
        when :action then 'rails.action'
        when :format then 'rails.format'
        else key.to_s
        end
        attributes[new_key] = value
      end
    end
  end
end
