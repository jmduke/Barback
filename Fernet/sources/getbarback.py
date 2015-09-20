# This Python file uses the following encoding: utf-8

from bs4 import BeautifulSoup
import requests

import random

sitemap_url = 'http://getbarback.com/sitemap.xml'


def get_parsed_html(url):
    r = requests.get(url)
    data = r.text
    soup = BeautifulSoup(data, 'html.parser')
    return soup


def get_text():
    soup = get_parsed_html(sitemap_url)
    urls = [url.text for url in soup.findAll('loc') if 'recipe' in url.text]
    random.shuffle(urls)
    recipe_url = urls[0]
    recipe_html = get_parsed_html(recipe_url)
    recipe_name = recipe_html.find('h2').text

    return "{} → {}".format(recipe_name, recipe_url)
