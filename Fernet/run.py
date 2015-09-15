# This Python file uses the following encoding: utf-8
from barbackconfig import *

import feedparser
import itertools
import random
import time

from slugify import slugify
import tweepy

TWITTER_BLACKLIST = []

TWEETS_BACK = 48 * 4
TWEETS_TO_FAVORITE = 2

api = None

favorite_search_terms = ["barback", "scotch", "cocktail"]


def check_for_new_posts():
    filename = "barback-rss.txt"
    recent_tweets = api.user_timeline(screen_name = "getbarback",count=200)
    recent_tweets = [t.text.split("→".decode('utf-8'))[0].strip() for t in recent_tweets]
    recent_tweets = [slugify(tweet) for tweet in recent_tweets]

    urls = open(filename).readlines()
    random.shuffle(urls)

    for feed_url in urls:
        rss = feedparser.parse(feed_url)

        for i in range(len(rss['entries'])):
            most_recent_entry = rss['entries'][i]
            link, title, tags = most_recent_entry['link'], most_recent_entry['title'], most_recent_entry['tags']
            tag = tags[0]['term'] if len(tags[0]['term'].split()) == 1 else "cocktails"
            try:
                tweet = "{0} → {1} #{2}".format(title.encode('utf-8'), link.encode('utf-8'), tag.encode('utf-8'))
            except Exception as e:
                print e, title, link, tag
            if slugify(title) not in recent_tweets:
                return tweet


def get_tweet_text():
    return check_for_new_posts()


def should_favorite_tweet(tweet, already_favorited_tweets=[], followers_ids=[]):
    return not (any([item in tweet.text for item in TWITTER_BLACKLIST]) or 
                tweet.id in already_favorited_tweets or 
                tweet.user.id in api.followers_ids() or
                any([term in tweet.user.screen_name.lower() for term in favorite_search_terms]) or
                tweet.user.followers_count / tweet.user.friends_count > 3)


def favorite_some_tweets():
    if not TWEETS_TO_FAVORITE:
        return

    possible_favorites = list(itertools.chain(*[api.search(term) for term in favorite_search_terms]))

    already_favorited_tweets = [tweet.id for tweet in api.favorites()]
    followers_ids = api.followers_ids()
    favorited_tweets = 0

    while favorited_tweets < TWEETS_TO_FAVORITE and possible_favorites:
        tweet = possible_favorites.pop()

        if not should_favorite_tweet(tweet, already_favorited_tweets, followers_ids):
            continue

        try:
            api.create_favorite(tweet.id)
            favorited_tweets += 1
        except Exception as e:
            print e
            continue


def unfavorite_some_tweets():
    if not TWEETS_TO_FAVORITE:
        return

    already_favorited_tweets = [tweet.id for tweet in api.favorites()] 
    random.shuffle(already_favorited_tweets)
    for tweet in already_favorited_tweets[:TWEETS_TO_FAVORITE]:
        api.destroy_favorite(tweet)


def main():
    global api

    # Do some randomization to make it feel organic.
    command_interval = 30 * 60
    delay = random.randint(1, command_interval)
    time.sleep(delay)

    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    api = tweepy.API(auth)

    text = get_tweet_text()
    if text:
        api.update_status(status=text)

    unfavorite_some_tweets()
    favorite_some_tweets()

main()
