# This Python file uses the following encoding: utf-8
from config import *

import itertools
import random

from slugify import slugify
import tweepy

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth)


def get_tweets(page=1):
    return api.user_timeline(screen_name="getbarback", count=200, page=page)


def get_recent_tweets():
    recent_tweets = [get_tweets(page) for page in range(1, 4)]
    recent_tweets = [item for sublist in recent_tweets for item in sublist]
    recent_tweets = [t.text.split("→".decode('utf-8'))[0].strip() for t in recent_tweets]
    recent_tweets = [slugify(tweet) for tweet in recent_tweets]
    return recent_tweets


def should_favorite_tweet(tweet, already_favorited_tweets=[], followers_ids=[], terms=[]):
    return not (tweet.id in already_favorited_tweets or
                tweet.user.id in api.followers_ids() or
                any([term in tweet.user.screen_name.lower() for term in terms]) or
                tweet.user.followers_count / tweet.user.friends_count > 3)


def unfavorite_tweets(count):
    if not count:
        return

    already_favorited_tweets = [tweet.id for tweet in api.favorites()]
    random.shuffle(already_favorited_tweets)
    for tweet in already_favorited_tweets[:count]:
        api.destroy_favorite(tweet)


def favorite_tweets(count, terms):
    if not count:
        return

    possible_favorites = list(itertools.chain(*[api.search(term) for term in terms]))

    already_favorited_tweets = [tweet.id for tweet in api.favorites()]
    followers_ids = api.followers_ids()
    favorited_tweets = 0

    while favorited_tweets < count and possible_favorites:
        tweet = possible_favorites.pop()

        if not should_favorite_tweet(tweet, already_favorited_tweets, followers_ids, terms):
            continue

        try:
            api.create_favorite(tweet.id)
            favorited_tweets += 1
        except Exception as e:
            print e
            continue


def create_tweet(text):
    api.update_status(status=text)
