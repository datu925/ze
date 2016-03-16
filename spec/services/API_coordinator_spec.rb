require 'rails_helper'

describe APICoordinator do

  #not testing the API call so we don't waste any credits
  let(:response) { {'text' => "Susan likes bikes"} }
  let(:caller) { APICoordinator.new({:sample => { :content => "Susan likes cars."}}) }

  describe "#create_sample" do

    it "adds nothing when given empty response array" do
      caller.response = response
      sample = caller.create_sample
      caller.create_keywords
      expect(sample.keywords.empty?).to be(true)
    end

    it "adds keyword objects to sample when response given" do
      caller.response = response
      sample = caller.create_sample
      caller.response = {"keywords" => [{'text' => "Susan", 'gender' => "female", 'sentiment' => { 'score' => 0.5, 'type' => "positive" } }] }
      caller.create_keywords

      expect(sample.keywords.first).to have_attributes(text: "Susan", gender: "female", sentiment_type: "positive", sentiment_score: 0.5)
    end

  end


end
