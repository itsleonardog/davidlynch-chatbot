# OpenAI API configuration
OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
  
  # Configure request timeouts
  config.request_timeout = 120 # seconds
end
