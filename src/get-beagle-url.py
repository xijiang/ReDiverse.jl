#!/usr/bin/env python
"""Descriptions
This is to abtain the URL of the lastest Beagle.jar.
I printed the Beagle link that were updated in current year.
What you are going to do is to wget or curl the file into ../bin dir.
Remember to make a soft link beagle.jar to the newly downloaded file.
I will write an automatic function later.
"""

import time
import httplib2
from bs4 import BeautifulSoup, SoupStrainer

http = httplib2.Http()
url = 'https://faculty.washington.edu/browning/beagle/'
cyr = time.strftime("%y")

status, response = http.request(url)

for link in BeautifulSoup(response,
                          parse_only = SoupStrainer('a'),
                          features="html.parser"):
    if link.has_attr('href'):
        f = link['href']
        if len(f) == 22 and f[12:14] == cyr:
            print(url, f)
