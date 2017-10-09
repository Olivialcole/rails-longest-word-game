class PagesController < ApplicationController
  def game
    @generate = generate_grid
    @start_time = Time.now
  end

  def score
    attempt = params[:query]
    grid = params[:grid].split('')
    start_time = Time.parse(params[:start_time])
    end_time = Time.now
    @result = run_game(attempt, grid, start_time, end_time)
  end


  def generate_grid
    Array.new(9) { ('A'..'Z').to_a.sample }
  end


  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last
    result[:attempt] = attempt.capitalize

    result
  end

  require 'open-uri'
  require 'json'


  def compute_score(attempt, time_taken)
  time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "Well Done!"]
      else
        [0, "Sorry, that's not an english word."]
      end
    else
      [0, "That's not in the grid."]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end
end
