require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  def score
    user_word = params[:word]
    grid = params[:grid]

    # Now you can use `user_word` and `grid` with your private methods
    start_time = Time.now # You'd want to receive or calculate this somehow
    end_time = Time.now # Ditto for end_time

    @result = run_game(user_word, grid, start_time, end_time)
  end

  private
def included?(guess, grid)
      guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
    end

    def compute_score(attempt, time_taken)
      time_taken > 60.0 ? 0 : (attempt.size * (1.0 - (time_taken / 60.0)))
    end

    def run_game(attempt, grid, start_time, end_time)
      # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
      result = { time: end_time - start_time }

      score_and_message = score_and_message(attempt, grid, result[:time])
      result[:score] = score_and_message.first
      result[:message] = score_and_message.last

      result
    end

    def score_and_message(attempt, grid, time)
      if included?(attempt.upcase, grid)
        if english_word?(attempt)
          score = compute_score(attempt, time)
          [score, "well done"]
        else
          [0, "not an english word"]
        end
      else
        [0, ""]
      end
    end

    def english_word?(word)
      begin
        response = URI.open("https://dictionary.lewagon.com/#{word}")
        json = JSON.parse(response.read)
        return json['found']
      rescue OpenURI::HTTPError => e
        Rails.logger.error "Dictionary API call failed: #{e.message}"
        return false
      end
end
end
