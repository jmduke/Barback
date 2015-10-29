'''
A script which tests static sites.

Usage: wimshurst <folder>
'''

from http.server import (
    SimpleHTTPRequestHandler,
    HTTPServer
)
from _thread import start_new_thread

import bs4
import requests
from tabulate import tabulate
import yaml


class Test:
    def __init__(self, dictionary):
        self.url = dictionary.get('url', None)
        self.status_code = dictionary.get('status', None)
        self.title = dictionary.get('title', None)
        self.content = dictionary.get('content', [])

    def succeed(self):
        return (self.url, "success", "")

    def fail(self, explanation):
        return (self.url, "failure", explanation)


server_address = ('', 8000)
httpd = HTTPServer(server_address, SimpleHTTPRequestHandler)
start_new_thread(httpd.serve_forever, ())

configuration_filename = 'Jamesfile'
configuration_file = open(configuration_filename)
configuration = yaml.load(configuration_file.read())

folder_under_test = configuration['folder']
tests = configuration['tests']
tests = [Test(dictionary) for dictionary in tests]

print("\n")

results = []

for test in tests:
    response = requests.get("http://localhost:8000/" + folder_under_test + test.url)
    html = bs4.BeautifulSoup(response.text, "html.parser")

    # Test status code.
    if test.status_code:
        expected_status_code = test.status_code
        actual_status_code = response.status_code
        result = actual_status_code == expected_status_code
        if not result:
            results.append(test.fail("{} != {}".format(actual_status_code, expected_status_code)))
            continue

    if test.title:
        expected_title = test.title.strip()
        actual_title = html.title.text.strip()
        result = actual_title == expected_title
        if not result:
            results.append(test.fail("{} != {}".format(actual_title, expected_title)))
            continue

    if test.content:
        for content_test in test.content:
            selector = content_test.get('selector', None)
            expected_text = content_test.get('text', '')

            if selector:
                matches = html.select(selector)
                actual_text = "".join([m.text.strip() for m in matches])
            else:
                actual_text = html.get_text()

            if type(expected_text) is list:
                for expectation in expected_text:
                    if expectation not in actual_text:
                        print("!?")
            else:
                if expected_text not in actual_text:
                    print("!?")


    results.append(test.succeed())

print(tabulate([r for r in results],
      headers=['url', 'result', 'explanation'],
      tablefmt='psql'))
