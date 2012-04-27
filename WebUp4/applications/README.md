Disclamer: these apps were made in a rush somewhat, so they can be optimized ;)

Before everything:

- make sure you have Node.js & NPM installed (checkout my slides for details on how to do that)
- after that install CoffeeScript, as I coded these sample apps in it. Just run the following command in the terminal:
npm install -g coffee-script
- for the twitter application you must have MongoDB and Redis running on your localhost

Running the twitter app:

- Install dependencies (run cmd in the directory of the app): npm install .
- Register a Twitter application to https://dev.twitter.com/ and obtain the consumer key, consumer secret, access key token and access key secret. Put them all into config.json.
- Start the broadcaster into the terminal:
coffee tweetBroadcaster.coffee "nodejs, html5, javascript, css3"

Wait a few seconds and you'll see the tweets in the terminal.

- Put all the streamed tweets into the db, run:
coffee tweetToDb.coffee

- Starting the server:
sudo coffee tweetWebServer.coffee

Then visit http://localhost/ and enjoy the live stream. For the memory stats in realtime checkout http://localhost/liveStream

Running the localbox app (sync files app):

- Install dependencies (run cmd in the directory of the app): npm install .
- Run the following command into the terminal:
coffee app.coffee

You'll see something like:

stdout {"port":"3000"}
Static file server port: 3000
MessageBus server up on:  { port: 49863, family: 2, address: '0.0.0.0' }
emitting serverMsg { files: [], port: '3000' } 1

- Copy the MessageBus port and then run the following command (replace 49863 with that port):
coffee testClient.coffee 49863

Make some .txt files into the folder /shared and then check to see that /fromOthers gets in sync

Enjoy ;-)

For questions email me.
