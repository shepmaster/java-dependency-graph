require 'node_list_decorator'

class ClassStripper < NodeListDecorator
  def link(from, to)
    nodelist.link(extract_package(from), extract_package(to))
  end

private

  def extract_package(str)
    return str unless str.include? '.'
    str.split('.')[0..-2].join('.')
  end
end
