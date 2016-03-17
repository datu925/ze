require 'twitter'

class TwitterScraper

  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_TOKEN_SECRET']
    end
  end

  def user_timeline_20_recent(handle)
    twitter_output = @client.user_timeline(handle)
  end

  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end  

  def user_whole_timeline(handle)
    collect_with_max_id do |max_id|
      options = {count: 35, include_rts: true}
      options[:max_id] = max_id unless max_id.nil?
      @client.user_timeline(handle, options)
    end
  end

  def concatenate_tweets(tweet_objects)
    concatenated_tweets = ""
    tweet_objects.each_with_index do |tweet, index|
      concatenated_tweets += "#{index + 1}. " + tweet.text + "\n"
    end
    return concatenated_tweets
  end

  def self.search
    client.search("to:justinbieber marry me", result_type: "recent").take(3).each do |tweet|
      puts tweet.text
    end
  end


end


