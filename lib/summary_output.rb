class SummaryOutput
  def initialize(dir)
    @dir = dir
    @links = Hash.new
  end

  def add_link(from, to)
    if ! @links.has_key? from
      @links[from] = []
    end
    @links[from] << to
  end

  def output
    path = File.join(@dir, 'summary.txt')

    File.open(path, 'wb') do |f|
      f.puts("-- References:")
      output_references(f)

      count = 10

      f.puts("-- Top #{count} by outgoing references:")
      output_top_outgoing_references(f, count)

      f.puts("-- Top #{count} by incoming references:")
      output_top_incoming_references(f, count)
    end
  end

  def output_references(f)
    @links.keys.sort.each do |source|
      f.puts(source)
      @links[source].sort.each do |dest|
        f.puts("\t#{dest}")
      end
    end
  end

  Sorter = Struct.new(:name, :count)

  def output_top_outgoing_references(f, count)
    referenced = @links.map {|k,v| Sorter.new(k, v.size)}
    output_top_n(f, referenced, count)
  end

  def output_top_incoming_references(f, count)
    all_referenced = @links.values.reduce(&:+)

    counter = Hash.new(0)
    all_referenced.each {|x| counter[x] += 1}

    referenced = counter.to_a.map {|x| Sorter.new(*x)}
    output_top_n(f, referenced, count)
  end

  def output_top_n(f, items, count)
    items.sort_by(&:count).reverse[0..count].each do |item|
      f.puts("\t#{item.name}: #{item.count}")
    end
  end
end
