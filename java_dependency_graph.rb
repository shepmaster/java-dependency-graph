require "rubygems"
require "bundler/setup"

require 'optparse'
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

options = {}
opts = OptionParser.new do |opts|
  opts.banner = "Usage: java_dependency_graph.rb [options] input_file"

  opts.on('-o', '--output-directory DIRECTORY',
          'Directory to write output to') do |dir|
    options[:output_directory] = dir
  end

  opts.on('--interface-file FILE',
          'File with a newline-separated list of interfaces') do |file|
    options[:interface_filename] = file
  end

  opts.on('--interesting-items REGEX',
          'Only output links that match REGEX on either node') do |regex|
    options[:interesting_items] = regex
  end

  opts.on('--[no-]strip-classes',
          'When enabled, the last component of the node will be removed') do |strip|
    options[:strip_classes] = strip
  end

  opts.on('--[no-]output-summary',
          'Outputs a textfile with summary information') do |summary|
    options[:output_summary] = summary
  end

  opts.on('--[no-]output-graphviz',
          'Outputs PDF graphs of dependency information') do |graphviz|
    options[:output_graphviz] = graphviz
  end
end
options[:input_filenames] = opts.parse!

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

node_list = NodeList.new
node_list = IgnoreSelfReference.new(node_list)
node_list = PackageRemover.new(node_list, *ignored_packages)
if options[:interesting_items]
  regex = Regexp.new(options[:interesting_items])
  node_list = OnlyTrackInteresting.new(node_list, regex)
end
if (options.fetch(:strip_classes) {true})
  node_list = ClassStripper.new(node_list)
end

filename = options[:input_filenames].first

if filename.nil? || filename.empty?
  raise "Input filename is required"
end

graph = Nokogiri::XML(open(filename))
graph.xpath("//package").each do |package|
  package.xpath("class").each do |start_class|
    name = start_class.xpath('name').first.text
    next if name.empty?

    start_class.xpath(".//outbound[@type = 'class']").each do |out|
      out_name = out.text
      next if out_name.empty?

      node_list.link(name, out_name)
    end
  end
end

output_dir = options[:output_directory]

if (options.fetch(:output_summary) {true})
  node_list.add_output(NotifierOutput.new(SummaryOutput.new(output_dir)))
end

if (options.fetch(:output_graphviz) {true})
  gv = GraphvizOutput.new(output_dir)
  interface_file = options[:interface_filename]
  if interface_file
    File.open(interface_file) do |f|
      f.each do |line|
        gv.add_interface(line.strip)
      end
    end
  end

  node_list.add_output(NotifierOutput.new(gv))
end

node_list.output

# generate interface file
# git grep interface src/main/java/ | grep -v '\*.*interface' | grep -v '.entity.store.interfaces' | cut -d: -f1 | sort | uniq | sed -e 's@/@.@g' -e 's@.java@@g'
