# refactors...
# 1. incorporate in larger pipeline
  # write a method that takes json objects and adds gender as a property for each one
# 2. make detect_word based on regex
# 3. return gender percentages along with the outcome gender
# 4. find a better gender or additional api?


module GenderDetector

  @male_words = [/actor/, /boy/, /boyfriend/, /boyfriends/, /boys/, /brother/, /brothers/, /chairman/, /dad/, /dads/, /dude/, /father/, /fathers/, /fiance/, /gentleman/, /gentlemen/, /god/, /grandfather/, /grandpa/, /grandson/, /groom/, /guy/, /he/, /he's/, /him/, /himself/, /his/, /husband/, /husbands/, /king/, /male/, /man/, /men/, /men's/, /mr/, /nephew/, /nephews/, /priest/, /prince/, /son/, /sons/, /spokesman/, /uncle/, /uncles/, /waiter/, /widower/, /widowers/]
  @female_words = [/actor/, /actress/, /aunt/, /aunts/, /bride/, /chairwoman/, /daughter/, /daughters/, /female/, /fiancee/, /girl/, /girlfriend/, /girlfriends/, /girls/, /goddess/, /granddaughter/, /grandma/, /grandmother/, /her/, /heroine/, /herself/, /ladies/, /lady/, /lady/, /mom/, /moms/, /mother/, /mothers/, /mrs/, /ms/, /niece/, /nieces/, /priestess/, /princess/, /queens/, /she/, /she's/, /sister/, /sisters/, /spokeswoman/, /waitress/, /widow/, /widows/, /wife/, /wives/, /woman/, /women/, /women's/]


  def self.transform(keywords_hash)
    keywords_hash["gender"] = self.detect(keywords_hash["text"])
    keywords_hash
  end

  def self.transform_all(keywords_hashes)
    keywords_hashes.map {|hash| self.transform(hash)}
  end

  def self.detect(text)
    outcome = self.detect_word(text)
    if outcome == "neutral"
      return self.detect_name(text)
    else
      return outcome
    end
  end

  def self.matches?(regex_list, text)
    regex_list.any? { |regex| regex.match(text) }
  end

  def self.detect_word(text)

    in_male = self.matches?(@male_words, text)
    in_female = self.matches?(@female_words, text)

    if in_female && in_male
      "unisex"
    elsif in_male
      "male"
    elsif in_female
      "female"
    else
      "neutral"
    end

  end

  def self.detect_name(text)

    unisex_threshold = 0.6

    response = Guess.gender(text)

    percentage = response[:confidence]
    gender = response[:gender]

    if gender == "unknown"
      return "neutral"
    elsif percentage < unisex_threshold && percentage > 1 - unisex_threshold
      return "unisex"
    else percentage
      return gender
    end
  end

end
