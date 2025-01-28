class ChatbotJob < ApplicationJob
  queue_as :default

  def perform(question)
    # Do something later
  end
end
