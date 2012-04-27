$(function() {
  var escape, socket, processTweetLinks, iterator = 0;

  escape = function(html) {
    return String(html)
      .replace(/&(?!\w+;)/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  processTweetLinks = function(text) {
      var exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/i;
      text = text.replace(exp, "<a href='$1' target='_blank'>$1</a>");
      exp = /(^|\s)#(\w+)/g;
      text = text.replace(exp, "$1<a href='http://search.twitter.com/search?q=%23$2' target='_blank'>#$2</a>");
      exp = /(^|\s)@(\w+)/g;
      text = text.replace(exp, "$1<a href='http://www.twitter.com/$2' target='_blank'>@$2</a>");
      return text;
  }

  processTweet = function(tweet) {
    var tweetContent, userLink = '', el, _class;

    _class = (iterator % 2 === 1) ? ' class="odd"' : '';
    iterator++;

    if (console && console.log) { console.log(tweet); }
    tweetContent = '<img src="' + tweet.user.profile_image_url + '" alt="" />';
    tweetContent += '<p>' + processTweetLinks(escape(tweet.text)) + '</p>';
    tweetContent += '<a href="https://twitter.com/' + tweet.user.screen_name;
    tweetContent += '" class="user_name">' + tweet.user.name + '</a>';

    el = '<li' + _class + '>' + tweetContent + '</li>';
    $('#latest_tweets').prepend(el);
  }

});
