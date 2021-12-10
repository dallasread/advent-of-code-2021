# frozen_string_literal: true

require 'test/unit/assertions'

class InvalidChunkError < StandardError
  attr_reader :expected, :invalid

  POINTS = {
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25_137
  }.freeze

  def initialize(expected:, invalid:)
    super('Invalid chunk')
    @expected = expected
    @invalid = invalid
  end

  def points
    POINTS[invalid]
  end
end

class Score
  attr_reader :chars

  POINTS = {
    ')' => 1,
    ']' => 2,
    '}' => 3,
    '>' => 4
  }.freeze

  def initialize(chars:)
    @chars = chars.split('')
  end

  def points
    points = 0

    chars.each do |char|
      points *= 5
      points += POINTS[char]
    end

    points
  end
end

class Line
  attr_reader :chars

  OPENERS = ['(', '[', '{', '<'].freeze
  CLOSERS = [')', ']', '}', '>'].freeze

  def initialize(chars:)
    @chars = chars.split('')
  end

  def parse
    buffer = []

    chars.each do |char|
      if OPENERS.include?(char)
        buffer << char
      elsif CLOSERS.include?(char)
        opener = buffer.pop
        opener_index = OPENERS.find_index(opener)
        expected = CLOSERS[opener_index]

        next if char == expected

        raise InvalidChunkError.new(invalid: char, expected: expected)
      end
    end
  end

  def finish_score
    Score.new(chars: finish_chars)
  rescue InvalidChunkError
    Score.new(chars: '')
  end

  def finish_chars
    buffer = []

    chars.each do |char|
      if OPENERS.include?(char)
        buffer << char
      elsif CLOSERS.include?(char)
        opener = buffer.pop
        opener_index = OPENERS.find_index(opener)
        expected = CLOSERS[opener_index]

        next if char == expected

        raise InvalidChunkError.new(invalid: char, expected: expected)
      end
    end

    buffer.map do |char|
      opener_index = OPENERS.find_index(char)
      CLOSERS[opener_index]
    end.join.reverse
  end
end

class Calculator
  attr_reader :lines

  def initialize(lines:)
    @lines = lines
  end

  def collect_invalid_chunks
    invalid_chunks = []

    lines.each do |line|
      line.parse
    rescue InvalidChunkError => e
      invalid_chunks.push(e)
    end

    invalid_chunks
  end

  def self.sum_points(chunks:)
    chunks.map(&:points).sum
  end

  def self.from_raw(input)
    lines = input.split("\n").map { |line| Line.new(chars: line) }

    Calculator.new(lines: lines)
  end

  def self.find_middle_score(scores:)
    points = scores.map(&:points).reject(&:zero?).sort
    index = (points.size / 2).floor
    points[index]
  end
end

describe Calculator do
  include Test::Unit::Assertions

  it 'sums the points of the lines with invalid syntax' do
    input = File.read('fixtures/test.txt')
    calc = Calculator.from_raw(input)

    assert_equal 26_397, Calculator.sum_points(chunks: calc.collect_invalid_chunks)
  end

  it 'calculates the score' do
    assert_equal 288_957, Score.new(chars: '}}]])})]').points
    assert_equal 5566, Score.new(chars: ')}>]})').points
    assert_equal 1_480_781, Score.new(chars: '}}>}>))))').points
    assert_equal 995_444, Score.new(chars: ']]}}]}]}>').points
    assert_equal 294, Score.new(chars: '])}>').points
  end

  it 'finishes a line' do
    assert_equal '}}]])})]', Line.new(chars: '[({(<(())[]>[[{[]{<()<>>').finish_chars
    assert_equal ')}>]})', Line.new(chars: '[(()[<>])]({[<{<<[]>>(').finish_chars
    assert_equal '}}>}>))))', Line.new(chars: '(((({<>}<{<{<>}{[]{[]{}').finish_chars
    assert_equal ']]}}]}]}>', Line.new(chars: '{<[[]]>}<{[{[{[]{()[[[]').finish_chars
    assert_equal '])}>', Line.new(chars: '<{([{{}}[<[[[<>{}]]]>[]]').finish_chars
  end

  it 'finds the middle score' do
    input = File.read('fixtures/input.txt')
    calc = Calculator.from_raw(input)

    assert_equal 288_957, Calculator.find_middle_score(scores: calc.lines.map(&:finish_score))
  end
end
