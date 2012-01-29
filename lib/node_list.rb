require 'set'

class NodeList
  def initialize
    @links = Set.new
    @outputs = Array.new
  end

  def link(from, to)
    @links.add([from, to])
  end

  def add_output(output)
    @outputs << output
  end

  def output
    @outputs.each do |out|
      @links.each do |link|
        from, to = *link
        out.add_link(from, to)
      end
      out.output
    end
  end
end
