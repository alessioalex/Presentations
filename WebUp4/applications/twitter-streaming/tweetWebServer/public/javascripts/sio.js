$(function() {
  var socket = io.connect('/tweets');
  socket.on('tweet', function (tweet) {
    processTweet(tweet);
  });
});
