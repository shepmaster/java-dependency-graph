require 'forwardable'

class NotifierOutput
  extend Forwardable

  def_delegators :@output, :add_link

  def initialize(output)
    @output = output
  end

  def output
    @output.output
    puts "Output #{@output} done"
  end
end
