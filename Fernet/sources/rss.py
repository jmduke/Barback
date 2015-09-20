# This Python file uses the following encoding: utf-8

import random

import feedparser
from slugify import slugify


def get_text(recent_tweets):
    filename = "barback-rss.txt"

    urls = open(filename).readlines()
    random.shuffle(urls)

    for feed_url in urls:
        rss = feedparser.parse(feed_url)

        for i in range(len(rss['entries'])):
            most_recent_entry = rss['entries'][i]
            link, title, tags = (
                most_recent_entry['link'],
                most_recent_entry['title'],
                most_recent_entry.get('tags', [])
            )

            # No idea why this is necessary, but we spam articles with ampersands.
            if "&" in title:
                continue

            if len(tags) and tags[0]["term"].split():
                tag = tags[0]['term']
            else:
                tag = "cocktails"

            try:
                tweet = "{0} → {1} #{2}".format(
                    title.encode('utf-8'),
                    link.encode('utf-8'),
                    tag.encode('utf-8')
                )
            except Exception as e:
                print e, title, link, tag
            if slugify(title) not in recent_tweets:
                return tweet
