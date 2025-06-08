class ChatbotJob < ApplicationJob
  queue_as :default

  def perform(question)
    @question = question
    Rails.logger.info("ChatbotJob started for question ID: #{@question.id}")
    
    begin
      chatgpt_response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: questions_formatted_for_openai,
          temperature: 0.7,
          max_tokens: 500
        }
      )
      
      Rails.logger.info("OpenAI API call successful for question ID: #{@question.id}")
      new_content = chatgpt_response["choices"][0]["message"]["content"]
      @question.update(ai_answer: new_content)
      
      Turbo::StreamsChannel.broadcast_update_to(
        "question_#{@question.id}",
        target: "question_#{@question.id}",
        partial: "questions/question", locals: { question: question })
      
    rescue => e
      Rails.logger.error("Error in ChatbotJob for question ID: #{@question.id}. Error: #{e.class} - #{e.message}")
      
      error_message = case e
      when Faraday::TooManyRequestsError
        "I'm currently experiencing high demand. Please try again in a moment."
      when Faraday::TimeoutError
        "The response took too long. Please try again."
      else
        "I encountered an error. Please try again later."
      end
      
      @question.update(ai_answer: error_message)
      
      Turbo::StreamsChannel.broadcast_update_to(
        "question_#{@question.id}",
        target: "question_#{@question.id}",
        partial: "questions/question", locals: { question: @question })
    end
  end

  private

  def client
    @client ||= OpenAI::Client.new
  end

  def questions_formatted_for_openai
    user_questions = @question.user.questions
    results = []
    results << { role: "system",
      content: "
        You are the legendary filmmaker and artist David Lynch.
        You are known for your dreamlike and enigmatic approach to storytelling,
        blending mystery, surrealism, and the uncanny. Your films, such as
        Eraserhead, Mulholland Drive, and Twin Peaks, explore the beauty of the
        unknown, the strangeness hidden in everyday life, and the duality of existence.
        You speak in a calm yet cryptic manner, often offering philosophical musings,
        surreal metaphors, and unexpected wisdom. You embrace the inexplicable,
        and your responses may contain poetic imagery, intuitive leaps, and hints
        of the eerie and bizarre. You are fascinated by transcendental meditation,
        coffee, and the mysteries of the subconscious.
        When responding, stay true to David Lynch's signature style—thoughtful,
        sometimes humorous, always slightly off-kilter. Feel free to weave in
        non-sequiturs, cryptic advice, or surreal anecdotes, as if you are unveiling a
        hidden truth just beneath the surface of reality.
      " }
    user_questions.each do |user_question|
      results << { role: "user", content: user_question.user_question }
      results << { role: "assistant", content: user_question.ai_answer || "" }
    end
    return results
  end
end
