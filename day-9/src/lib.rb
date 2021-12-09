# frozen_string_literal: true

require 'test/unit/assertions'

class Point
  attr_reader :z, :x, :y

  def initialize(x:, y:, z:)
    @x = x
    @y = y
    @z = z
  end

  def risk
    z + 1
  end

  def lower_than_all_neighbours?(points:)
    find_neighbours(points: points).select do |neighbour|
      z >= neighbour.z
    end.empty?
  end

  def find_neighbours(points:)
    points.select do |point|
      next(false) if point == self
      next(false) if (point.x - x).abs > 1
      next(false) if (point.y - y).abs > 1

      true
    end
  end

  def to_s
    "x=#{x} y=#{y} z=#{z}"
  end
end

class Calculator
  attr_reader :points

  def initialize(points:)
    @points = points
  end

  def lowest_points
    points.select { |point| point.lower_than_all_neighbours?(points: points) }
  end

  def self.sum_risks(points:)
    points.map(&:risk).sum
  end

  def self.from_raw(raw)
    rows = raw.split("\n")
    points = []

    rows.each_with_index do |row, y|
      columns = row.split('')

      columns.each_with_index do |z, x|
        points << Point.new(z: z.to_i, x: x, y: y)
      end
    end

    Calculator.new(points: points)
  end
end

describe Calculator do
  include Test::Unit::Assertions

  it 'sums the risks of the lowest points' do
    input = File.read('fixtures/test.txt')
    calc = Calculator.from_raw(input)

    assert_equal 15, Calculator.sum_risks(points: calc.lowest_points)
  end
end
