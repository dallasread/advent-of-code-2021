# frozen_string_literal: true

require 'test/unit/assertions'

class Node
  attr_reader :id, :nodes

  SMALL = :small
  BIG = :big

  def initialize(id:)
    @id = id
    @nodes = []
  end

  def add_connection(node)
    nodes << node
  end

  def big?
    id.upcase == id
  end

  def small?
    !big?
  end
end

class NodeMap
  attr_reader :nodes

  def initialize
    @nodes = []
  end

  def find(id:)
    nodes.find { |n| n.id == id }
  end

  def build_or_find(id:)
    node = find(id: id)

    unless node
      node = Node.new(id: id)
      nodes.push(node)
    end

    node
  end

  def find_paths(start:, finish:, includes: [])
    paths = []
    pending_nodes = start.nodes

    node = pending_nodes.shift while pending_nodes.any?

    paths
    # start.path
    # start.nodes.map do |node|
    #   [start] + find_paths(start: node, finish: finish, includes: includes)
    # end

    # .each do |node|
    #   paths if node.big?
    # end

    # if node.small? && !smalls.include?(node)
    #   smalls << node
    #   paths.each { |path| path.push(node) }
    # elsif node.big?
    #   paths.each { |path| path.push(node) }
    #   node.nodes.each do |n|
    #     paths.each do |path|
    #       path.push(n)
    #     end
    #   end
    # end

    # node
    # paths << node.nodes.map { |n| paths + [node, n] }
  end

  def select_paths(start:, finish:, includes:)
    # paths = find_paths(start: start, finish: finish, includes: includes)
    puts start.path
    start.path
  end

  def small_caves
    nodes.select(&:small?)
  end
end

class Calculator
  attr_reader :node_map

  def initialize(node_map:)
    @node_map = node_map
  end

  def self.from_raw(input)
    lines = input.split("\n")
    node_map = NodeMap.new

    lines.each do |line|
      splat = line.split('-')

      a = node_map.build_or_find(id: splat.first)
      b = node_map.build_or_find(id: splat.last)

      a.add_connection(b)
      # b.add_connection(a)
    end

    Calculator.new(node_map: node_map)
  end
end

describe Calculator do
  include Test::Unit::Assertions

  it 'counts the paths that visit small caves' do
    input = File.read('fixtures/test.txt')
    node_map = Calculator.from_raw(input).node_map
    start = node_map.find(id: 'start')
    finish = node_map.find(id: 'end')
    assert_equal 10, node_map.select_paths(start: start, finish: finish, includes: node_map.small_caves).count

    # input = File.read('fixtures/test-2.txt')
    # node_map = Calculator.from_raw(input).node_map
    # start = node_map.find(id: 'start')
    # finish = node_map.find(id: 'end')
    # assert_equal 19, node_map.select_paths(start: start, finish: finish, include: node_map.small_caves).count

    # input = File.read('fixtures/test-3.txt')
    # node_map = Calculator.from_raw(input).node_map
    # start = node_map.find(id: 'start')
    # finish = node_map.find(id: 'end')
    # assert_equal 226, node_map.select_paths(start: start, finish: finish, include: node_map.small_caves).count
  end
end
