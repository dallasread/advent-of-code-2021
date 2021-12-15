# frozen_string_literal: true

require 'test/unit/assertions'
require 'benchmark'

class InsertionRule
  attr_reader :matcher, :insertion

  def initialize(matcher:, insertion:)
    @matcher = matcher
    @insertion = insertion
  end

  def apply(polymer)
    polymer.gsub
  end
end

class Calculator
  attr_reader :initial_polymer, :insertion_rules

  def initialize(initial_polymer:, insertion_rules:)
    @initial_polymer = initial_polymer
    @insertion_rules = insertion_rules
  end

  def occurences(polymer:)
    counts = {}

    polymer.size.times do |n|
      char = polymer[n]
      counts[char] ||= 0
      counts[char] += 1
    end

    counts
  end

  def most_common_character_occurrences(polymer:)
    occurences(polymer: polymer).values.max
  end

  def least_common_character_occurrences(polymer:)
    occurences(polymer: polymer).values.min
  end

  def most_common_subtract_least_common_occurrences(polymer:)
    most_common_character_occurrences(polymer: polymer) - least_common_character_occurrences(polymer: polymer)
  end

  def find_polymer_repeatedly(template:, limit: 1)
    polymer = template

    limit.times do |n|
      time = Benchmark.measure do
        polymer = find_polymer(template: polymer)
      end

      puts "Step ##{n}: #{time.real}"
    end

    polymer
  end

  def find_polymer(template:)
    result = ''

    template.size.times do |n|
      break if template[n + 1].nil?

      result = result[0...-1]
      result += insertion_rules["#{template[n]}#{template[n + 1]}"]
    end

    result
  end

  def self.from_raw(input)
    lines = input.split("\n")
    initial_polymer = lines.shift
    replacements = lines.reject(&:empty?).map do |line|
      splat = line.split(' -> ')
      [splat.first, "#{splat.first[0]}#{splat.last}#{splat.first[1]}"]
    end

    Calculator.new(initial_polymer: initial_polymer, insertion_rules: Hash[replacements])
  end
end

describe Calculator do
  include Test::Unit::Assertions

  it 'calculates the polymer' do
    input = File.read('fixtures/test.txt')
    calc = Calculator.from_raw(input)

    assert_equal 'NCNBCHB', calc.find_polymer(template: calc.initial_polymer)
    assert_equal 'NBCCNBBBCBHCB', calc.find_polymer_repeatedly(template: calc.initial_polymer, limit: 2)
    assert_equal 'NBBBCNCCNBBNBNBBCHBHHBCHB', calc.find_polymer_repeatedly(template: calc.initial_polymer, limit: 3)
    assert_equal 'NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB',
                 calc.find_polymer_repeatedly(template: calc.initial_polymer, limit: 4)
  end

  it 'finds the magic number at 10 steps' do
    input = File.read('fixtures/test.txt')
    calc = Calculator.from_raw(input)
    polymer = calc.find_polymer_repeatedly(template: calc.initial_polymer, limit: 10)

    assert_equal 1588, calc.most_common_subtract_least_common_occurrences(polymer: polymer)
  end

  it 'finds the magic number at 40 steps' do
    input = File.read('fixtures/test.txt')
    calc = Calculator.from_raw(input)
    polymer = calc.find_polymer_repeatedly(template: calc.initial_polymer, limit: 40)

    assert_equal 2_188_189_693_529, calc.most_common_subtract_least_common_occurrences(polymer: polymer)
  end
end
