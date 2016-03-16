$(function() {

  $("#profile").on("ajax:success", function(event, data) {
    // debugger;
    $("#content").empty();
    $("#content").append($("<div id=scatter><h3>Scatter of your samples</h3></div>"));
    $("#content").append($("<div id='highlighted-text'></div>"));

    var samples = data.samples.map(function(sample) { return new Sample(sample) });
    var keywords = data.keywords.map(function(keyword) { return new Keyword(keyword) });
    keywords.forEach(function(keyword) {
      var sample = samples.find(function(sample) { return sample.id === keyword.sample_id });
      sample.addKeyword(keyword);
    })
    samples.forEach(function(sample) { sample.averages = sample.calculateAverages() });

    var samplesView = new SamplesView(samples)
    $("#scatter").append(samplesView.drawScatter());

    samples.forEach(function(sample) {
      var view = new SampleView(sample);
      $("#highlighted-text").append(view.render());
      // view.bindPopups();
    })

  });
});