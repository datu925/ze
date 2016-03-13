class AlchemyCaller
  attr_accessor :response
  def initialize(sample)
    @sample = sample
    @response = nil
  end

  def call_API
    response = HTTParty.post("http://access.alchemyapi.com/calls/text/TextGetRankedKeywords",
    :query => { :apikey => ENV["SECRET_ALCHEMY"],
               :text => @sample.content,
               :outputMode => 'json',
               :sentiment => 1
             },
    :headers => { 'Content-Type' => 'application/x-www-form-urlencoded' } )
    @response = JSON.parse(response.body)
  end

  def convert_to_keyword_objects
    if @response && @response['keywords']
      keywords = @response['keywords']
      keywords.each do |keyword|
        @sample.keywords << Keyword.new({
                                          text: keyword["text"],
                                          sentiment_type: keyword["sentiment"]["type"],
                                          sentiment_score: keyword["sentiment"]["score"],
                                          gender: GenderDetector.detect(keyword["text"]),
                                        })
      end
    end
  end
end