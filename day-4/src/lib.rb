# frozen_string_literal: true

require 'minitest/autorun'

class Decision
  attr_reader :card, :last_number

  def initialize(card:, last_number:)
    @card = card
    @last_number = last_number
  end

  def result
    unapplied_card_numbers = card.numbers.reject { |number| card.applied?(number) }

    unapplied_card_numbers.sum * last_number
  end
end

class Win < Decision
end

class Loser < Decision
end

class Card
  attr_accessor :numbers, :applied

  def initialize(numbers: [])
    @numbers = numbers
    @applied = []
  end

  def apply_number(number)
    applied.push(number)
  end

  def applied?(number)
    applied.include?(number)
  end

  def won?
    [0, 5, 10, 15, 20].each do |index|
      row = numbers[index..(index + 4)]
      applied_in_row = row.select { |number| applied?(number) }

      return true if applied_in_row.count == 5
    end

    (0..4).each do |index|
      column = numbers.select.with_index { |_number, i| (i % 5) == index }
      applied_in_column = column.select { |number| applied?(number) }

      return true if applied_in_column.count == 5
    end

    false
  end
end

class Calculator
  attr_reader :numbers, :cards

  def self.from_input(input = '')
    lines = input.split("\n")
    numbers = lines.shift.split(',').map(&:to_i)
    cards = []
    card_numbers = []

    lines.each do |line|
      if line.empty?
        card_numbers = []
        cards.push(card_numbers)
        next
      end

      line.split(/\s+/).reject(&:empty?).each do |line_number|
        card_numbers.push(line_number.to_i)
      end
    end

    Calculator.new(
      numbers: numbers,
      cards: cards.map { |card| Card.new(numbers: card) }
    )
  end

  def initialize(numbers:, cards:)
    @numbers = numbers
    @cards = cards
  end

  def winner
    numbers.each do |n|
      cards.each do |card|
        card.apply_number(n)
        return Win.new(card: card, last_number: n) if card.won?
      end
    end

    raise 'No winner found'
  end

  def loser
    all_cards = cards.dup

    numbers.each do |n|
      cards.each do |card|
        card.apply_number(n)
        all_cards.delete(card) if card.won?

        return Loser.new(card: card, last_number: n) if all_cards.empty?
      end
    end

    raise 'No loser found'
  end
end

describe Calculator do
  it 'calculates winner' do
    input = File.read('fixtures/test.txt')

    calc = Calculator.from_input(input)

    assert_equal 4512, calc.winner.result
  end

  it 'calculates loser' do
    input = File.read('fixtures/test.txt')

    calc = Calculator.from_input(input)

    assert_equal 1924, calc.loser.result
  end

  it 'calculates if a card has won with horizontal numbers' do
    card = Card.new(numbers: [0, 1, 2, 3, 4])

    card.apply_number(0)
    card.apply_number(1)
    card.apply_number(2)
    card.apply_number(3)
    card.apply_number(4)

    assert_equal true, card.won?
  end

  it 'calculates if a card has won with vertical numbers' do
    card = Card.new(numbers: [0, 10, 11, 12, 13, 1, 20, 21, 22, 23, 2, 30, 31, 32, 33, 3, 40, 41, 42, 43, 4, 50, 51,
                              52, 53])

    card.apply_number(0)
    card.apply_number(1)
    card.apply_number(2)
    card.apply_number(3)
    card.apply_number(4)

    assert_equal true, card.won?
  end
end
