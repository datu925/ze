$(function() {
  $(".compare").on("ajax:success", function(event, data) {

    var samples = data.samples.map(function(sample) { return new Sample(sample) });
    var keywords = data.keywords.map(function(keyword) { return new Keyword(keyword) });
    keywords.forEach(function(keyword) {
      var sample = samples.find(function(sample) { return sample.id === keyword.sample_id });
      sample.addKeyword(keyword);
      keyword.sampleName = sample.name;
    })

    var renderers = $.extend($.pivotUtilities.renderers,
            $.pivotUtilities.c3_renderers);
    var averages = samples.map(function(sample) { return sample.calculateAverages() });
    samples.forEach(function(sample) { sample.female = sample.calculateAverages().female || 0; sample.male = sample.calculateAverages().male || 0 });

    $("#pivot").pivotUI(keywords, {
      renderers: renderers
    });

  })
})
