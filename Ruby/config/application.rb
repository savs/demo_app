require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"  # Requires ActiveRecord
require "action_controller/railtie"
# require "action_mailer/railtie"  # Not needed for simple app
# require "action_mailbox/engine"  # Requires ActiveRecord
# require "action_text/engine"  # Requires ActiveRecord
require "action_view/railtie"
# require "action_cable/engine"  # Not needed for simple app
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RubyApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil
    
    # Inject OpenTelemetry trace context into logs using log_tags
    # This automatically adds trace_id, span_id, and trace_sampled to all log entries
    config.log_tags = {
      trace_id: -> request {
        span = OpenTelemetry::Trace.current_span
        span.context.valid? ? span.context.hex_trace_id : nil
      },
      span_id: -> request {
        span = OpenTelemetry::Trace.current_span
        span.context.valid? ? span.context.hex_span_id : nil
      },
      trace_sampled: -> request {
        span = OpenTelemetry::Trace.current_span
        span.context.valid? ? span.context.trace_flags.sampled? : nil
      }
    }
  end
end
