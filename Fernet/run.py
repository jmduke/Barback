# This Python file uses the following encoding: utf-8
from sources.getbarback import get_text as get_text_from_barback
from sources.rss import get_text as get_text_from_rss
from twitter import (
    create_tweet,
    favorite_tweets,
    get_recent_tweets,
    unfavorite_tweets
)

import random
import time


TWEETS_BACK = 48 * 4
TWEETS_TO_FAVORITE = 2
FAVORITE_SEARCH_TERMS = ["barback", "scotch", "cocktail"]


def get_tweet_text(recent_tweets):
    if random.random() > 0.855555:
        return get_text_from_barback()
    return get_text_from_rss(recent_tweets)


def wait():
    command_interval = 30 * 60
    delay = random.randint(1, command_interval)
    time.sleep(delay)


def main():
    global api

    # Do some randomization to make it feel organic.
    wait()

    recent_tweets = get_recent_tweets()

    text = get_tweet_text(recent_tweets)
    if text:
        create_tweet(text)

    unfavorite_tweets(TWEETS_TO_FAVORITE)
    favorite_tweets(TWEETS_TO_FAVORITE, FAVORITE_SEARCH_TERMS)

main()
