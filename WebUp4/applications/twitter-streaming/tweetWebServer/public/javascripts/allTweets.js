$(function() {
  var oneTweetAtATime;

  oneTweetAtATime = function(tweets, iterator) {
    if (!iterator) {
      $('div.overlay').remove();
      $('div.loading').remove();
      return;
    }

    setTimeout(function() {
      processTweet(tweets[iterator--]);
      oneTweetAtATime(tweets, iterator);
    }, 1);
  }

  $.ajax({
    url: 'tweets.json',
    dataType: 'json',
    success: function(tweets) {
      iterator = tweets.length - 1;
      oneTweetAtATime(tweets, iterator);
    }
  });
});
