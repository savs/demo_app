class RequestLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    start_time = Time.now
    
    # Call the next middleware/application
    status, headers, response = @app.call(env)
    
    duration = ((Time.now - start_time) * 1000).round(2) # duration in milliseconds
    
    # Get trace context if available
    span = OpenTelemetry::Trace.current_span
    trace_id = span&.context&.trace_id&.unpack1('H*') if span&.context
    span_id = span&.context&.span_id&.unpack1('H*') if span&.context
    
    # Log request - OpenTelemetry logger will automatically attach trace context
    log_message = "[RequestLogger] HTTP Request: #{request.method} #{request.path} - Status: #{status} - Duration: #{duration}ms"
    if trace_id
      log_message += " - TraceID: #{trace_id}"
    end
    if span_id
      log_message += " - SpanID: #{span_id}"
    end
    
    Rails.logger.info(log_message)
    
    # Ensure we return the response
    
    [status, headers, response]
  end
end
