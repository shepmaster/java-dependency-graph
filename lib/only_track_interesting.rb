require 'node_list_decorator'

class OnlyTrackInteresting < NodeListDecorator
  def initialize(nodelist, package)
    super(nodelist)
    @package = package
  end

  def link(from, to)
    return unless @package.match(from) || @package.match(to)
    nodelist.link(from, to)
  end
end
