class APICoordinator

  attr_accessor :response

  # get params and set instance variable to type and value after relevant preprocessing - note twitter scraping, tesseract, etc.
  def initialize(params)
    if params[:url]
      @input = {type: :url, value: params[:url][:url]}
      @sample_name = params[:url][:name]
    elsif params[:image]
      @input = {type: :text, value: process_image(params[:image])}
      @sample_name = params[:sample][:name]
    elsif params[:tweet]
      @input = {type: :text, value: fetch_tweets(params[:tweet][:content])}
      @sample_name = params[:tweet][:name]
    elsif params[:file]
      parsed_file = Yomu.new params[:file].tempfile
      @input = {type: :text, value: parsed_file.text}
      @sample_name = params[:file].original_filename
    else
      @input = {type: :text, value: params[:sample][:content]}
      @sample_name = params[:sample][:name]
    end
  end

  # tesseract image processing
  def process_image(image)
    engine = Tesseract::Engine.new do |config|
      config.language  = :eng
      config.blacklist = '|'
    end

    def clean(text)
      text.split(/\n/).compact.select { |v| v.size > 0 }
    end

    new_image =  image.tempfile.path
    clean(engine.text_for(new_image)).join(" ");
  end

  # tweet fetching
  def fetch_tweets(handle)
    handle = handle[1..-1] if handle[0] == "@"
    tweeter = TwitterScraper.new
    tweet_objects = tweeter.user_whole_timeline(handle)
    tweeter.concatenate_tweets(tweet_objects)
  end

  # determine API call to use; set input to just content
  def call_API
    case @input[:type]
    when :text
      @input = @input[:value]
      call_text_API
    when :url
      @input = @input[:value]
      call_URL_API
    else
      "Invalid input"
    end
  end

  def call_text_API
    max_length = 4000
    # if @sample.content is small enough
    if @input.length > max_length
      content = @input[0...max_length]
    else
      content = @input
    end

    response = HTTParty.post("http://access.alchemyapi.com/calls/text/TextGetRankedKeywords",
      :query => { :apikey => ENV["SECRET_ALCHEMY"],
               :text => content,
               :showSourceText => 1,
               :outputMode => 'json',
               :sentiment => 1
             },
      :headers => { 'Content-Type' => 'application/x-www-form-urlencoded' } )

    @response = JSON.parse(response.body)
  end

  def call_URL_API
    response = HTTParty.post("http://gateway-a.watsonplatform.net/calls/url/URLGetRankedKeywords",
      :query => { :apikey => ENV["URL_SECRET_ALCHEMY"],
                 :url => @input,
                 :sourceText => "cleaned",
                 :showSourceText => 1,
                 :outputMode => 'json',
                 :sentiment => 1
               },
      :headers => { 'Content-Type' => 'application/x-www-form-urlencoded' } )
    @response = JSON.parse(response.body)
  end

  def create_sample
    if @response['text']
      @sample = Sample.new(content: @response['text'], name: @sample_name)
    end
  end

  def create_keywords
    keywords = @response['keywords'] || []
    keywords.each do |keyword|
        @sample.keywords << Keyword.new({
          text: keyword["text"],
          sentiment_type: keyword["sentiment"]["type"],
          sentiment_score: keyword["sentiment"]["score"],
          gender: GenderDetector.detect(keyword["text"]),
        })
    end
    @sample.keywords
  end

end
