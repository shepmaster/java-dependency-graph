require 'forwardable'

class NodeListDecorator
  extend Forwardable

  attr_reader :nodelist
  def_delegators :@nodelist, :link, :output, :add_output

  def initialize(nodelist)
    @nodelist = nodelist
  end
end
