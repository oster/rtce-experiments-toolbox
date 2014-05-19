#! /opt/local/bin/python2.7 -tt


# curl--X POST d sourcetext=tutu -d calcmethod=kandelmoles -d calcbutton="Calculate+score" http://www.standards-schmandards.com/exhibits/rix/index.php

import os
import re
import requests
import sys

filename = sys.argv[1]
with open(filename, "r") as text_file:
    text = text_file.read()

payload = { 'sourcetext': text, 'calcmethod': 'kandelmoles', 'calcbutton': 'Calculate+score' }
r = requests.post("http://www.standards-schmandards.com/exhibits/rix/index.php", data=payload)

pattern = re.compile('Kandel &amp; Moles score: <strong>(-?[0-9]+)</strong>.')
res = pattern.search(r.text)

print res.group(1)




