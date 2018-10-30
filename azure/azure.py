import requests
import datetime
from time import sleep
from dotenv import load_dotenv, find_dotenv
from os import getenv, makedirs
from sys import argv
from pathlib import Path

if __name__ == "__main__":
  assert argv[1] is not None
  images = {}
  with open(argv[1]) as lines:
    for line in lines:
      line = line.strip()
      desc, url = line.split(',')
      images[desc] = url

  load_dotenv(find_dotenv())

  subscription_key = getenv("AZURE_SUBSCRIPTION_KEY")
  vision_base_url = "https://australiaeast.api.cognitive.microsoft.com/vision/v1.0/"
  vision_analyze_url = vision_base_url + "analyze"
  timestamp = datetime.datetime.utcnow()

  for image_desc, image_url in images.items():
    headers  = {'Ocp-Apim-Subscription-Key': subscription_key }
    params   = {'visualFeatures': 'Tags'}
    data     = {'url': image_url}
    response = requests.post(vision_analyze_url, headers=headers, params=params, json=data)
    response.raise_for_status()
    for label in response.json()['tags']:
      print("{},{},{},{},{}".format(timestamp, image_desc, image_url, label['name'], label['confidence']))
    with open("log/azure/{}_{}.json".format(timestamp.isoformat(), image_desc), 'w') as log:
      log.write(response.text)
