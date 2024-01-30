# => Config hash (no initializer required)
Rails.application.config.exception_handler = {
  dev:        nil, # allows you to turn ExceptionHandler "on" in development (set to true)
  db:         nil, # allocates a "table name" into which exceptions are saved (defaults to nil)
  email:      ENV.fetch('EXCEPTIONS_NOTIFICATIONS_EMAIL', ''), # sends exception emails to a listed email

  # Custom Exceptions
  custom_exceptions: {
    #'ActionController::RoutingError' => :not_found # => example
  },

  # On default 5xx error page, social media links included
  social: {
    facebook: nil, # Facebook page name
    twitter:  nil, # Twitter handle
    youtube:  nil, # Youtube channel name / ID
    linkedin: nil, # LinkedIn name
    fusion:   nil  # FL Fusion handle
  },

  # This is an entirely NEW structure for the "layouts" area
  # You're able to define layouts, notifications etc ↴

  # All keys interpolated as strings, so you can use symbols, strings or integers where necessary
  exceptions: {
    all: {
      layout: "exceptions", # define layout
      notification: ENV['EXCEPTIONS_NOTIFICATIONS_EMAIL']
    }
  }
}