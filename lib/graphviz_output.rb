require 'graphviz'
require 'set'

class GraphvizOutput
  def initialize(dir)
    @dir = dir
    @graph = GraphViz.new(:G, :type => :digraph)
    @nodes = {}
    @interfaces = Set.new
  end

  def add_link(from, to)
    start_node = get_node(from)
    end_node = get_node(to)
    @graph.add_edges(start_node, end_node)
  end

  def output
    @nodes.each do |name, node|
      if @interfaces.include? name
        node['style'] = 'dashed'
      end
    end

    @graph.output(:pdf => File.join(@dir, 'graph-dot.pdf'))
    @graph.output(:pdf => File.join(@dir, 'graph-circo.pdf'), :use => 'circo')
  end

  def add_interface(interface)
    @interfaces << interface
  end

  private
  
  def get_node(name)
    node = @nodes[name]
    if node.nil?
      node = @graph.add_nodes(name)
      @nodes[name] = node
    end
    node
  end
end
