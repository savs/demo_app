# Load and register the RequestLogger middleware
require Rails.root.join('app/middleware/request_logger')

# Register the middleware in the stack
# This runs during Rails initialization, before the app starts handling requests
Rails.application.config.middleware.insert_before 0, RequestLogger

# Log that middleware is registered
Rails.logger.info "[RequestLogger] Middleware registered and ready to log requests"
