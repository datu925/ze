function SampleView(sample) {
  this.sample = sample;
};

SampleView.prototype.render = function() {
  // call methods to generate text
  return JST["templates/sample"]({view: this});
}

SampleView.prototype.displayHighlightedContent = function() {
  this.displayHighlightCaption();
  this.displayHighlightedSample();
};

SampleView.prototype.displayHighlightedSample = function() {
  $("#highlighted-text").append(this.wrapSampleContent());
};

SampleView.prototype.displayHighlightCaption = function() {
  $("#highlighted-text").html("<h4>Highlighted Text</h4><p>See below for a deeper analysis of your text: <span class='negative'>Red</span> means negative. <span class='positive'>Green</span> means positive. <span class='female'>Pink</span> means it's a feminine-coded word. <span class='male'>Blue</span> means it's a masculine-coded word.</p>")
}

SampleView.prototype.wrapSampleContent = function() {

  var keywords = this.sample.keywords;
  var contentHtml = $("<div>" + this.sample.content + "</div>");

  keywords.forEach(function(keyword) {
    contentHtml.highlight(keyword.text, { wordsOnly: true, element: 'span', className: keyword.gender + " keyword " + keyword.sentiment_type, data: { sentiment_score: keyword.sentiment_score } })
  })
  return contentHtml;
};

SampleView.prototype.showStatistics = function() {
  $("#averages").prepend("<h3>" + this.sample.name + "</h3>");
  $("#averages").html(

    "<h4>Average sentiment by gender</h4><p>Using sentiment analysis, these averages reflect, on a scale from -1 to 1, how negatively or positively the passage feels about men and women.</p>"

    );
  $("#averages").append(this.generateAverageView(this.sample.calculateAverages()));
}

SampleView.prototype.generateAverageView = function(averages) {
  var ul = $("<ul>");
  var setOrder = ["male", "female", "neutral"]
  for(var index in setOrder) {
    var gender = setOrder[index]
    if (averages[gender]) {
      ul.append($("<li>").text(gender + ": " + averages[gender].toFixed(2)))
    }
  }
  return ul;
}

SampleView.prototype.createNumberLine = function(sample) {

  $("#number-line").html(


  "<h3>Keywords</h3><p>These are the gender-coded keywords in your passage and how our algorithm rated their sentiment. Hover over a circle to see what keyword it represents.</p>"


  )

  var svgContainer = d3.select("#number-line")
                       .append("svg")
                       .attr("width", 500)
                       .attr("height", 200);

  var linearScale = d3.scale.linear()
                      .domain([-1,1])
                      .range([50,450]);

  var xAxis = d3.svg.axis()
                    .scale(linearScale);

  var genderedKeywords = this.sample.keywords.filter(function(keyword) {
    return keyword.gender !== "neutral";
  })

  var circles = svgContainer.selectAll("circle")
    .data(genderedKeywords)
    .enter()
    .append("circle")
    .attr("cx", function(d) { return linearScale(d.sentiment_score) })
    .attr("cy", 70)
    .attr("r", 15)
    .style("fill", function(d) { return colorFromGender(d.gender) })

    .on("mouseover", function() {return tooltip.style("visibility", "visible");})
    .on("mousemove", function() {return tooltip.style("top", (d3.event.pageY-35)+"px").style("left", (d3.event.pageX+10)+"px").text(d3.event.currentTarget.__data__.text);})
    .on("mouseout", function(){return tooltip.style("visibility", "hidden");});

  var tooltip = d3.select("body")
                  .append("div")
                  .style("position", "absolute")
                  .style("z-index", "10")
                  .style("visibility", "hidden")


  var xAxisGroup = svgContainer.append("g")
                               .attr("transform", "translate(0, 100)")
                               .call(xAxis);

  svgContainer.append("text")
              .attr("x", 75 )
              .attr("y", 165 )
              .style("text-anchor", "middle")
              .text("negative sentiment");

  svgContainer.append("text")
              .attr("x", 425 )
              .attr("y", 165 )
              .style("text-anchor", "middle")
              .text("positive sentiment");
}

function colorFromGender(gender) {
  if (gender == "male") {
    return '#52CFF8'
  } else if (gender == "female") {
    return 'pink'
  } else if (gender == "neutral") {
    return 'transparent'
  }
}

SampleView.prototype.bindPopups = function() {
  var that = this;
  $("#highlighted-text").on("click",".keyword",function() {
    var popup = $(JST["templates/keywordPopup"]());
    var keyword_text = $(this).text();
    var x = $(this).offset().left;
    var y = $(this).offset().top - 50;
    $("body").append(popup);
    popup.css({
                "position":"absolute",
                "top": y, "left": x,
                "background-color": "white",
                "border": "1px solid black",
                "padding": "10px"
                })

      $("body").on("click", ".keyword-popup input", function() {
        var gender = $(this).val();
        var keyword = that.sample.keywords.find(function(keyword) {
          return keyword.text === keyword_text
        });
        keyword.gender = gender;
        that.displayHighlightedContent();
        that.showStatistics();
        that.createNumberLine();
        $(this).closest(".keyword-popup").remove();
        $("body").off("click", ".keyword-popup input")
      });
  });
}


SampleView.prototype.createNumberLine2 = function() {

  var div = $("<div>");


  var svgContainer = d3.select(div[0])
                       .append("svg")
                       .attr("width", 500)
                       .attr("height", 200);

  var linearScale = d3.scale.linear()
                      .domain([-1,1])
                      .range([50,450]);

  var xAxis = d3.svg.axis()
                    .scale(linearScale);

  var circles = svgContainer.selectAll("circle")
    .data(this.sample.genderedKeywords())
    .enter()
    .append("circle")
    .attr("cx", function(d) { return linearScale(d.sentiment_score) })
    .attr("cy", 70)
    .attr("r", 15)
    .style("fill", function(d) { return colorFromGender(d.gender) })
    .on("mouseover", function() {return tooltip.style("visibility", "visible");})
    .on("mousemove", function() { return tooltip.style("top", (d3.event.pageY-35)+"px").style("left", (d3.event.pageX+10)+"px").text(d3.event.currentTarget.__data__.text);})
    .on("mouseout", function(){return tooltip.style("visibility", "hidden");});

  var tooltip = d3.select(div[0])
                  .append("div")
                  .style("position", "absolute")
                  .style("z-index", "10")
                  .style("visibility", "hidden")


  var xAxisGroup = svgContainer.append("g")
                               .attr("transform", "translate(0, 100)")
                               .call(xAxis);

  svgContainer.append("text")
              .attr("x", 75 )
              .attr("y", 165 )
              .style("text-anchor", "middle")
              .text("negative sentiment");

  svgContainer.append("text")
              .attr("x", 425 )
              .attr("y", 165 )
              .style("text-anchor", "middle")
              .text("positive sentiment");

  return div;
}
