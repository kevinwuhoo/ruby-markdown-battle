require 'sinatra'
require 'json'
require 'coffee_script'
require 'haml'

set :views, Proc.new { File.join(root) }

get '/' do
  haml :index
end

post '/' do
  content_type :json

  # get the processor and remove from options hash
  params[:options] = Rack::Utils.parse_nested_query(params[:options])
  processor = params[:options]["processor"] 
  params[:options].delete("processor")

  # get only the options selected with the current processor
  options = []
  params[:options].each do |o,trash|
    checked_processor, checked_value = o.split(":")
    options << checked_value.to_sym if checked_processor == processor
  end

  # time each render
  begin_time = nil
  end_time = nil

  # use the selected markdown interpreter with selected options and render html
  if processor == "redcarpet"
    require 'redcarpet'

    # https://github.com/vmg/redcarpet
    redcarpet_options = {}
    options.each do |o|
      redcarpet_options[o] = true
    end
        
    begin_time = Time.now
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, redcarpet_options)
    html = markdown.render(params[:text])
    end_time = Time.now

  elsif processor == "rdiscount"
    require 'rdiscount'

    # http://rdoc.info/github/davidfstr/rdiscount/master/RDiscount
    begin_time = Time.now
    markdown = RDiscount.new(params[:text], *options)
    html = markdown.to_html()
    end_time = Time.now

  elsif processor == "kramdown"
    require 'kramdown'
    
    # options that are default on need to be explictly set false
    # http://kramdown.rubyforge.org/options.html
    # http://kramdown.rubyforge.org/rdoc/Kramdown/Options.html
    kramdown_options = {}
    [:auto_ids, :enable_coderay, :parse_span_html, :remove_block_html_tags, :smart_quotes].each do |o|
      if !options.include? o and o != :smart_quotes
        kramdown_options[o] = false 
      elsif !options.include? o and o == :smart_quotes
        kramdown_options[o] = ["39", "39", "34", "34"] 
      end
    end
    options.each do |o|
      kramdown_options[o] = true if o != :smart_quotes
    end

    begin_time = Time.now
    markdown = Kramdown::Document.new(params[:text], kramdown_options)
    html = markdown.to_html()
    end_time = Time.now

  elsif processor == "maruku"
    require 'maruku'

    # http://maruku.rubyforge.org/math.xhtml
    require 'maruku/ext/math'
    MaRuKu::Globals[:html_math_engine] = 'ritex'
    
    # options that are default on need to be explictly set false
    # https://github.com/bhollis/maruku/blob/master/lib/maruku/defaults.rb
    maruku_options = {}
    maruku_options[:ignore_wikilinks] = false if !options.include? :ignore_wikilinks
    options.each do |o|
      maruku_options[o] = true
    end

    begin_time = Time.now
    markdown = Maruku.new(params[:text], maruku_options)
    html = markdown.to_html()
    end_time = Time.now
  end

  # calculate render time in ms
  render_time = (end_time - begin_time) * 1000

  return {:renderHTML => html, :renderTime => render_time}.to_json

end

get '/script.js' do
  coffee :script
end

