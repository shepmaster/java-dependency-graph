require 'node_list_decorator'

class PackageRemover < NodeListDecorator
  def initialize(nodelist, *packages)
    super(nodelist)
    @packages = packages
  end

  def link(from, to)
    @packages.each do |package|
      return if (from.start_with? package)
      return if (to.start_with? package)
    end
    nodelist.link(from, to)
  end
end
