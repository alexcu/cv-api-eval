import boto3
import urllib.request
import datetime
from dotenv import load_dotenv, find_dotenv
from os import getenv
from sys import argv
from pathlib import Path
from json import dump

if __name__ == "__main__":
  assert argv[1] is not None
  images = {}
  with open(argv[1]) as lines:
    for line in lines:
      line = line.strip()
      desc, url = line.split(',')
      images[desc] = url

  load_dotenv(find_dotenv())

  client = boto3.client('rekognition',
                        region_name='us-east-1',
                        api_version='2016-06-27',
                        aws_access_key_id=getenv("AWS_ACCESS_KEY_ID"),
                        aws_secret_access_key=getenv("AWS_SECRET_ACCESS_KEY"))

  timestamp = datetime.datetime.utcnow()

  for image_desc, image_url in images.items():
    bytes = urllib.request.urlopen(image_url).read()
    response = client.detect_labels(
      Image={
          'Bytes': bytes
      }
    )
    for label in response['Labels']:
      print("{},{},{},{},{}".format(timestamp, image_desc, image_url, label['Name'].lower(), label['Confidence'] * 0.01))
    with open("log/aws/{}_{}.json".format(timestamp.isoformat(), image_desc), 'w') as log:
      dump(response, log)
