require "rubygems"
require "bundler/setup"

require 'nokogiri'

# Add our lib directory to the load path
libdir = File.dirname(__FILE__) + '/lib'
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'node_list'
require 'ignore_self_reference'
require 'class_stripper'
require 'package_remover'
require 'only_track_interesting'
require 'summary_output'
require 'graphviz_output'
require 'notifier_output'

ignored_packages = ['com.google.common',
                    'com.google.commons',
                    'edu.umd.cs.findbugs.annotations',
                    'java.io',
                    'java.lang',
                    'java.text',
                    'java.util',
                    'org.apache.commons.lang',
                    'org.apache.log4j',
                    'org.slf4j']

core_list = NodeList.new
no_self = IgnoreSelfReference.new(core_list)
no_common = PackageRemover.new(no_self, *ignored_packages)
interesting = OnlyTrackInteresting.new(no_common, /persistence/)
#only_packages = ClassStripper.new(no_common)
nodes = interesting #only_packages

filename = '/tmp/palmer-graph.xml'
#filename = '/tmp/master-graph.xml'

graph = Nokogiri::XML(open(filename))
graph.xpath("//package").each do |package|
  package.xpath("class").each do |start_class|
    name = start_class.xpath('name').first.text
    next if name.empty?

    start_class.xpath(".//outbound[@type = 'class']").each do |out|
      out_name = out.text
      next if out_name.empty?

      nodes.link(name, out_name)
    end
  end
end

output_dir = '/tmp/play'

interfaces = File.open('/tmp/master-interfaces2') do |f|
  f.map {|x| x.strip}
end

gv = GraphvizOutput.new(output_dir, interfaces)

#nodes.add_output(NotifierOutput.new(SummaryOutput.new(output_dir)))
nodes.add_output(NotifierOutput.new(gv))

nodes.output

# generate interface file
# git grep interface src/main/java/ | grep -v '\*.*interface' | grep -v '.entity.store.interfaces' | cut -d: -f1 | sort | uniq | sed -e 's@/@.@g' -e 's@.java@@g'
