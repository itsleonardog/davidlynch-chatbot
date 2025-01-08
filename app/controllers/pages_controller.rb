class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    client = OpenAI::Client.new
    chatgpt_response = client.chat(parameters: {
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: "Who is David Lynch, and how is he related to Twin Peaks?" }]
    })
    @content = chatgpt_response["choices"][0]["message"]["content"]
  end
end
