import urllib.request
import datetime
from google.cloud import vision
from google.cloud.vision import types
from google.oauth2 import service_account
from google.protobuf.json_format import MessageToJson
from dotenv import load_dotenv, find_dotenv
from os import getenv
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

  google_creds = {
    "type": "service_account",
    "project_id": getenv("GOOGLE_PROJECT_ID"),
    "private_key_id": getenv("GOOGLE_PRIVATE_KEY_ID"),
    "private_key": getenv("GOOGLE_PRIVATE_KEY").replace('\\\\n', '\n'),
    "client_email": getenv("GOOGLE_CLIENT_EMAIL"),
    "client_id": getenv("GOOGLE_CLIENT_ID"),
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://accounts.google.com/o/oauth2/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": getenv("GOOGLE_CLIENT_X509_CERT_URL")
  }

  credentials = service_account.Credentials.from_service_account_info(google_creds)
  client = vision.ImageAnnotatorClient(credentials=credentials)

  timestamp = datetime.datetime.utcnow()

  for image_desc, image_url in images.items():
    bytes = urllib.request.urlopen(image_url).read()
    response = client.label_detection(image=types.Image(content=bytes))
    for label in response.label_annotations:
      print("{},{},{},{},{}".format(timestamp, image_desc, image_url, label.description, label.score))
    with open("logs/googlecloud/{}_{}.json".format(timestamp.isoformat(), image_desc), 'w') as log:
      log.write(MessageToJson(response, preserving_proto_field_name=True))

