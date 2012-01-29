require 'node_list_decorator'

class IgnoreSelfReference < NodeListDecorator
  def link(from, to)
    return if from == to
    nodelist.link(from, to)
  end
end
