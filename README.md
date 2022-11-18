# twitter_archiver
Garbage twitter account archiver for Tweets and Spaces

A poor but working implementation to create an updating archive of a twitter account using snscrape for tweets and twspace-dl for any running spaces. Tweets are saved in a json file, media is saved in a directory similar to the url path of the media on twitter's media servers, both pictures and video.
Tweets and their media are updated as they come through without complete re-download based on published date, and this works still if a tweet is pinned. Each monitored user will be saved to a separate subfolder.

How to run:

`docker run
  -d
  --name='TwitterArchiver'
  -e 'interval'='120'
  -e 'usernames'='gawrgura hakosbaelz'
  -v '$HOME/Twitter':'/app/output':'rw' 
  'canofsocks/twitter_archiver:latest'
`

Where `interval` is the time to sleep between checking for new tweets/spaces (default 60 seconds),
`usernames` is a list of twitter usernames to monitor, with space separation
and `$HOME/Twitter` is where any files will be saved.

______________
Known issues:

There are many issue with this container and how it works. Improvements may or may not be implemented in the future. 

Some main issues include:
- Tweets only download the latest ~3200 tweets - This is due to using the "twitter-profile" scraper from snscrape (because I wanted retweets too) as it uses the Twitter API. The "twitter-user" may be able to get all, but this container was designed around the output of the "twitter-profile" scraper.
- Poor resilience against errors - If media downloads fail for whatever reason and the container continues running, the new tweets will be merged into the current archive json file. To redownload from a certain time/date, the json file must be manually edited to remove any tweets up to the required date or the json deleted completely. If the container stops during collecting media, it should re-download the new media as it might not have merged yet.
