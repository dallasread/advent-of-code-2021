# frozen_string_literal: true

# Digit.new(value: 1, pattern: %w[x x          ])
# Digit.new(value: 7, pattern: %w[x x   x      ])
# Digit.new(value: 4, pattern: %w[x x     x x  ])
# Digit.new(value: 8, pattern: %w[x x x x x x x])

# Digit.new(value: 2, pattern: %w[x   x x   x x])
# Digit.new(value: 3, pattern: %w[x x x x   x  ]) # 7 with 2 added
# Digit.new(value: 5, pattern: %w[  x x x x x  ])

# Digit.new(value: 0, pattern: %w[x x x x x   x])
# Digit.new(value: 6, pattern: %w[  x x x x x x]) # missing segments from 7
# Digit.new(value: 9, pattern: %w[x x x x x x  ])

# possibilities = %w[
#   TOP
#   TOP_RIGHT
#   BOTTOM_RIGHT
#   BOTTOM
#   BOTTOM_LEFT
#   TOP_LEFT
#   MIDDLE
# ]
# digits_with_unique_segment_size = [
#   Digit.new(value: 1, pattern: %w[TOP_RIGHT BOTTOM_RIGHT]),
#   Digit.new(value: 7, pattern: %w[TOP_RIGHT BOTTOM_RIGHT TOP]),
#   Digit.new(value: 4, pattern: %w[TOP_LEFT TOP_RIGHT BOTTOM_RIGHT MIDDLE]),
#   Digit.new(value: 8, pattern: %w[TOP TOP_RIGHT BOTTOM_RIGHT BOTTOM BOTTOM_LEFT TOP_LEFT MIDDLE])
# ]
# words = (inputs + outputs).flatten.map { |w| w.split('').sort.join }.uniq
# bits = Hash[words.join.split('').uniq.map { |bit| [bit, []] }]

# digits_with_unique_segment_size.each do |digit|
#   words.each do |word|
#     next unless digit.matches_pattern_by_content_size?(word)

#     word.split('').each do |word_bit|
#       bits[word_bit] = digit.pattern & bits[word_bit]

#       next unless bits[word_bit].count == 1

#       bits.each do |bit|
#         bits[bit] -= bits[word_bit] unless bit == word_bit
#       end
#     end
#   end
# end

# puts bits

# def solve
#   digits_with_unique_segment_size = [
#     Digit.new(value: 1, pattern: %w[a b]),
#     Digit.new(value: 7, pattern: %w[d a b]),
#     Digit.new(value: 4, pattern: %w[e a f b]),
#     Digit.new(value: 8, pattern: %w[a c e d g f b])
#   ]

#   digits_with_five_segments = [
#     # Digit.new(value: 2, pattern: %w[g c d f a]),
#     # Digit.new(value: 3, pattern: %w[f b c a d]),
#     # Digit.new(value: 5, pattern: %w[c d f b e])
#     Digit.new(value: 2, pattern: %w[g a]), # 2 uniques in 5-segmenters
#     Digit.new(value: 3, pattern: %w[b a]), # same as a 2 with one difference
#     Digit.new(value: 5, pattern: %w[b e]) # same as a 2 with two differences
#   ]

#   # Digit.new(value: 0, pattern: %w[c a g e d b]), 8 with one gone
#   # Digit.new(value: 6, pattern: %w[c d f g e b]),
#   # Digit.new(value: 9, pattern: %w[c e f a b d])

#   words = rows.map { |row| row.inputs + row.outputs }.flatten.map { |w| w.split('').sort.join }.uniq

#   digits = []

#   digits_with_unique_segment_size.each do |digit|
#     words.each do |word|
#       if digit.matches_pattern_by_content_size?(word)
#         digits << Digit.new(value: digit.value, segments: word.split(''))
#         break
#       end
#     end
#   end

#   # find a two
#   # rows.each do |row|
#   #   segments = row.select_segments_with_size(digit.pattern.size)
#   #   rows.each do |row|

#   #     if segments.any?
#   #       digits << Digit.new(value: digit.value, segments: segments)
#   #       break
#   #     end
#   #   end
#   # end

#   digits_with_five_segments.each do |digit|
#     samples = []

#     words.each do |word|
#       break if samples.size == digits_with_five_segments.size
#       next if samples.include?(word)

#       samples.push(word.sort) if digit.matches_pattern_by_content_size?(word)
#     end

#     # if 2 uniques, its a 2
#   end

#   puts digits.map(&:inspect)

#   digits
# end

require 'test/unit/assertions'
include Test::Unit::Assertions

class Digit
  attr_reader :value, :pattern
  attr_accessor :segments

  def initialize(value:, segments: [], pattern: [])
    @value = value
    @segments = segments
    @pattern = pattern
  end

  def matches_pattern_by_content_size?(content)
    pattern.size == content.size
  end

  def matches_by_size?(content)
    segments.size == content.size
  end

  def matches_by_content?(content)
    return false unless matches_by_size?(content)

    content.split('').sort.join == segments.join
  end
end

class Row
  attr_reader :inputs, :outputs

  def initialize(inputs: [], outputs: [])
    @inputs = inputs
    @outputs = outputs
  end

  def count_of_outputs_for_digits(digits: [])
    digits.map do |digit|
      outputs.select { |output| digit.matches_by_size?(output) }.size
    end.sum
  end

  def output
    known_digits = {}
    words = (inputs + outputs).flatten.map { |w| w.split('').sort.join }.uniq
    digits_with_unique_segment_size = [
      Digit.new(value: 1, pattern: %w[a b]),
      Digit.new(value: 7, pattern: %w[a b d]),
      Digit.new(value: 4, pattern: %w[a b e f]),
      Digit.new(value: 8, pattern: %w[a b c d e f g])
    ]

    # Digit.new(value: 1, pattern: %w[a b          ])
    # Digit.new(value: 7, pattern: %w[a b   d      ])
    # Digit.new(value: 4, pattern: %w[a b     e f  ])
    # Digit.new(value: 8, pattern: %w[a b c d e f g])

    # Digit.new(value: 2, pattern: %w[a   c d   f g])
    # Digit.new(value: 3, pattern: %w[a b c d   f  ]) # 7 with 2 added
    # Digit.new(value: 5, pattern: %w[  b c d e f  ])

    # Digit.new(value: 0, pattern: %w[a b c d e   g])
    # Digit.new(value: 6, pattern: %w[  b c d e f g]) # missing segments from 7
    # Digit.new(value: 9, pattern: %w[a b c d e f  ]) # 4 with 1 added segment

    digits_with_unique_segment_size.each do |digit|
      words.each do |word|
        if digit.matches_pattern_by_content_size?(word)
          known_digits[digit.value] = Digit.new(value: digit.value, segments: word.split(''))
          break
        end
      end
    end

    words.each do |word|
      next if known_digits.values.find { |digit| digit.matches_by_content?(word) }

      segments = word.split('')

      case segments.size
      when 5
        if (segments - known_digits[7].segments).size == 2 # APPROVED
          known_digits[3] = Digit.new(value: 3, segments: segments)
        elsif (segments - known_digits[4].segments).size == 2 # APPROVED
          known_digits[5] = Digit.new(value: 5, segments: segments)
        else
          known_digits[2] = Digit.new(value: 2, segments: segments) # APPROVED
        end
        next
      when 6
        if (segments - known_digits[4].segments).size == 2 # APPROVED
          known_digits[9] = Digit.new(value: 9, segments: segments)
        elsif (segments - known_digits[1].segments).size == 5 # APPROVED
          known_digits[6] = Digit.new(value: 6, segments: segments)
        else
          known_digits[0] = Digit.new(value: 0, segments: segments) # APPROVED
        end
        next
      end
    end

    # puts known_digits.values.map(&:inspect)
    # puts known_digits.keys.join(' ')

    result = outputs.map do |output|
      output = output.split('').sort.join

      known_digits.values.find { |digit| digit.segments.join == output }&.value
    end

    result.join.to_i
  end

  def find_segments_with_size(size)
    select_segments_with_size(size)
  end

  def select_segments_with_size(size)
    (inputs + outputs).find { |item| item.size == size }.map { |item| item.split('') }
  end

  def self.from_raw(raw)
    splat = raw.split(' | ')
    inputs = splat.first.split(' ')
    outputs = splat.last.split(' ')

    Row.new(inputs: inputs, outputs: outputs)
  end
end

class Calculator
  attr_reader :rows

  def initialize(rows:)
    @rows = rows
  end

  def count_of_outputs_for_digits(digits: [])
    rows.map { |row| row.count_of_outputs_for_digits(digits: digits) }.sum
  end

  def sum_row_outputs
    rows.map(&:output).sum
  end

  def self.from_raw(raw)
    lines = raw.split("\n").map(&:strip).reject(&:empty?)
    rows = lines.map { |line| Row.from_raw(line) }

    Calculator.new(rows: rows)
  end
end

describe Calculator do
  it 'calculates count of outputs for given digits' do
    input = File.read('fixtures/test.txt')
    digits = [
      Digit.new(value: 1, segments: %w[c f]),
      Digit.new(value: 4, segments: %w[b c d f]),
      Digit.new(value: 7, segments: %w[a c f]),
      Digit.new(value: 8, segments: %w[a b c d e f g])
    ]

    assert_equal 26, Calculator.from_raw(input).count_of_outputs_for_digits(digits: digits)
  end

  it 'calculates the sum of outputs' do
    input = File.read('fixtures/input.txt')
    calc = Calculator.from_raw(input)

    assert_equal 61_229, calc.sum_row_outputs
  end

  it 'detects digits' do
    input = File.read('fixtures/test.txt')
    calc = Calculator.from_raw(input)

    assert_equal 8394, calc.rows[0].output
    assert_equal 9781, calc.rows[1].output
    assert_equal 1197, calc.rows[2].output
    assert_equal 9361, calc.rows[3].output
    assert_equal 4873, calc.rows[4].output
    assert_equal 8418, calc.rows[5].output
    assert_equal 4548, calc.rows[6].output
    assert_equal 1625, calc.rows[7].output
    assert_equal 8717, calc.rows[8].output
    assert_equal 4315, calc.rows[9].output
  end
end
