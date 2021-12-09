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
      next(true) if point.x == x && (point.y - y).abs == 1
      next(true) if point.y == y && (point.x - x).abs == 1

      false
    end
  end

  def find_neighbourhood(points:)
    neighbourhood = [self]

    neighbourhood.each do |neighbour|
      neighbour.find_neighbours(points: points).each do |point|
        neighbourhood << point unless neighbourhood.include?(point)
      end
    end

    neighbourhood
  end

  def to_s
    "x=#{x} y=#{y} z=#{z}"
  end
end

class Basin
  attr_reader :points

  def initialize(points:)
    @points = points
  end

  def size
    points.size
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

  def lowest_basins(n)
    basins.sort_by(&:size).last(n)
  end

  def basins
    points_without_height_of_nine = points.reject { |point| point.z == 9 }

    lowest_points.map do |point|
      Basin.new(points: point.find_neighbourhood(points: points_without_height_of_nine))
    end
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

  def self.multiply_basins_size(basins:)
    basins.map(&:size).inject(:*)
  end
end

describe Calculator do
  include Test::Unit::Assertions

  it 'sums the risks of the lowest points' do
    input = File.read('fixtures/test.txt')
    calc = Calculator.from_raw(input)

    assert_equal 15, Calculator.sum_risks(points: calc.lowest_points)
  end

  it 'finds the biggest basins' do
    input = File.read('fixtures/test.txt')
    calc = Calculator.from_raw(input)

    assert_equal 1134, Calculator.multiply_basins_size(basins: calc.lowest_basins(3))
  end
end
