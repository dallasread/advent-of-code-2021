# frozen_string_literal: true

require 'test/unit/assertions'

class Line
  attr_reader :chars

  OPENERS = ['(', '[', '{', '<'].freeze
  CLOSERS = [')', ']', '}', '>'].freeze

  def initialize(value:)
    @chars = value.split('')
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
end

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
    lines = input.split("\n").map { |line| Line.new(value: line) }

    Calculator.new(lines: lines)
  end
end

describe Calculator do
  include Test::Unit::Assertions

  it 'sums the points of the lines with invalid syntax' do
    input = File.read('fixtures/test.txt')
    calc = Calculator.from_raw(input)

    assert_equal 26_397, Calculator.sum_points(chunks: calc.collect_invalid_chunks)
  end
end
