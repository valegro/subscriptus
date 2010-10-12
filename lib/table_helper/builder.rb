class TableHelper::Builder

  module TableHelpers
    def self.titleize(text)
      text.kind_of?(Symbol) ? text.to_s.humanize.titleize : text
    end
  end

  class RowDefiniton

    def initialize(record, idx, &block)
      @definition = {}
      @actions = []
      @class_name = nil
      @record = record
      yield(self, record, idx)
    end

    def column(name, content = "", &block)
      @definition[name.to_sym] = block_given? ? yield(@record) : content
    end

    def action(title, path, options = {})
      @actions << { :title => TableHelpers.titleize(title), :path => path, :options => options.merge({ :class=> TableHelpers.titleize(title).parameterize.downcase }) }
    end

    def _definition
      @definition.merge({ :_actions => @actions, :_class_name => @class_name, :_delegate => @record })
    end
    
    def class_name(name)
      @class_name = name
    end

    def method_missing(method_name, *args, &block)
      column method_name, *args, &block
    end
    
  end

  class SearchBuilder

    def initialize(template, path, object, &block)
      @template = template
      @object = object
      @build = @template.capture do
        @template.form_for(object, :url => path) do |f| 
          @template.concat block.call(f)
        end
      end
    end

    def build
      @build
    end

  end

  class OptionCollector

    attr_accessor :options

    def initialize(options)
      @options = options 
    end

    def method_missing(m, value = nil, &block)
      if m.to_s.match(/=$/)
        @options[m.to_s.gsub(/=$/, '').to_sym] = value
      else
        @options[m.to_sym] = yield 
      end
    end

  end

  def initialize(record_set, template, &block)
    @record_set = record_set
    @template = template
    @table_headers = []
    @table_footers = []
    @tools = []
    @rows = []
    @groups = []
    @options = {}
    @options_collector = OptionCollector.new(@options)
    yield(self)
    @options.merge(@options_collector.options)
  end
  
  def options(opts = {})
    @options.merge(opts)
    @options_collector
  end

  def title(title = nil, &block)
    @options[:title] = block_given? ? yield : title
  end
  
  def record_set
    @record_set
  end
  
  def header(*args, &block)
    options = args.last.kind_of?(Hash) ? args.pop : {}
    [*args].each do |title|
      label_text = if options.has_key?(:label)
        options[:label]
      elsif block_given?
        label_text = block.call
      else
        TableHelpers.titleize(title)
      end
      options.delete(:label) # Just to make sure.
      label_text = '&nbsp;' if label_text.blank?
      @table_headers << { :label => label_text, :sym => title.to_s.downcase.to_sym, :options => options }
    end
  end
  
  def footer(*args)
    options = args.last.kind_of?(Hash) ? args.pop : {}
    [*args].each do |title|
      label_text = options.has_key?(:label) ? options[:label] : TableHelpers.titleize(title)
      options.delete(:label) # Just to make sure.
      label_text = '&nbsp;' if label_text.blank?
      @table_footers << { :label => label_text, :sym => title.to_s.downcase.to_sym, :options => options }
    end
  end

  def grouping(record_set, options = {}, &block)
    @groups << TableHelper::Builder.new(record_set, @template, &block).html_helper.merge(options)
  end
  
  # Added custom title
  def tool(title, path, options = {})
    label_text = options.has_key?(:label) ? options[:label] : TableHelpers.titleize(title)
    @tools <<  { :title => label_text, :path => path, :options => options }
  end

  def search(title, path, object, options = {}, &block)
    @tools << { :title => TableHelpers.titleize(title), :path => path, :options => options, :body => SearchBuilder.new(@template, path, object, &block).build }
  end

  def rows(&block)
    @record_set.each_with_index do |record, idx|
      @rows << RowDefiniton.new(record, idx, &block)._definition
    end
  end

  def html_helper
    { :table_headers => @table_headers, :tools => @tools, :rows => @rows, :groups => @groups, :record_set => @record_set, :options => @options }
  end

end
