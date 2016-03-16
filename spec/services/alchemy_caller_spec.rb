# require 'rails_helper'

# describe AlchemyCaller do

#   #not testing the API call so we don't waste any credits
#   let(:sample) { Sample.new(content: "Susan likes bikes", name: "my sample")}
#   let(:caller) { AlchemyCaller.new(sample)}

#   describe "#convert_to_keyword_objects" do

#     it "adds nothing when given empty response array" do
#       caller.convert_to_keyword_objects
#       expect(sample.keywords.empty?).to be(true)
#     end

#     it "adds keyword objects to sample when response given" do
#       caller.response = {"keywords" => [{'text' => "Susan", 'gender' => "female", 'sentiment' => { 'score' => 0.5, 'type' => "positive" } }] }
#       caller.convert_to_keyword_objects

#       expect(sample.keywords.first).to have_attributes(text: "Susan", gender: "female", sentiment_type: "positive", sentiment_score: 0.5)
#     end

#   end


# end
