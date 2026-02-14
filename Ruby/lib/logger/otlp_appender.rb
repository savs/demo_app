# lib/logger/otlp_appender.rb
# SemanticLogger appender that forwards each log to the OpenTelemetry Logs API,
# which exports to the configured OTLP endpoint (see config/initializers/opentelemetry_logs.rb).
require 'semantic_logger'

module Loggers
  class OtlpAppender < SemanticLogger::Subscriber
    SEVERITY_NUMBER = {
      trace: 1,
      debug: 5,
      info: 9,
      warn: 13,
      error: 17,
      fatal: 21
    }.freeze

    def log(log)
      return false unless should_log?(log)

      otel_logger = OpenTelemetry.logger_provider.logger(name: log.name, version: nil)
      attributes = build_attributes(log)
      trace_id = log.named_tags&.dig(:trace_id)
      span_id = log.named_tags&.dig(:span_id)
      trace_flags = log.named_tags&.dig(:trace_sampled) ? 1 : 0

      # OTel Logs API: on_emit. Timestamps in nanoseconds since epoch.
      ts_nanos = (log.time.to_f * 1e9).to_i
      observed_nanos = (Time.now.to_f * 1e9).to_i

      otel_logger.on_emit(
        timestamp: ts_nanos,
        observed_timestamp: observed_nanos,
        severity_number: SEVERITY_NUMBER[log.level] || 9,
        severity_text: log.level.to_s.upcase,
        body: log.message,
        trace_id: trace_id ? hex_to_trace_id(trace_id) : nil,
        span_id: span_id ? hex_to_span_id(span_id) : nil,
        trace_flags: trace_flags,
        attributes: attributes.empty? ? nil : attributes
      )
      true
    rescue StandardError => e
      # Don't break app logging if OTLP export fails
      OpenTelemetry.handle_error(exception: e, message: 'OtlpAppender: failed to emit log')
      true
    end

    private

    def hex_to_trace_id(hex)
      return nil if hex.nil? || hex.to_s.length != 32
      [hex.to_s].pack('H*')
    end

    def hex_to_span_id(hex)
      return nil if hex.nil? || hex.to_s.length != 16
      [hex.to_s].pack('H*')
    end

    def build_attributes(log)
      attrs = {}
      if log.named_tags.is_a?(Hash)
        log.named_tags.each do |k, v|
          next if %i[trace_id span_id trace_sampled].include?(k)
          attrs[k.to_s] = v
        end
      end
      if log.exception
        attrs['exception.type'] = log.exception.class.name
        attrs['exception.message'] = log.exception.message
        attrs['exception.stacktrace'] = log.exception.backtrace&.join("\n")
      end
      if log.payload.is_a?(Hash)
        log.payload.each do |key, value|
          attrs[payload_key(key)] = value
        end
      end
      attrs
    end

    def payload_key(key)
      case key
      when :method then 'http.request.method'
      when :path then 'url.path'
      when :status then 'http.response.status_code'
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
    end
  end
end
