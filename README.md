# Cognitive API Confidence Logger

Logs confidence of major vision-based cognitive API services in a structured CSV format and their labels. Supports [Google Cloud Vision](https://cloud.google.com/vision/), [AWS Rekognition](https://aws.amazon.com/rekognition/) and [Azure Computer Vision](https://azure.microsoft.com/en-us/services/cognitive-services/computer-vision/).

## Installation

Use Python 3 or greater and install dependencies from `requirements.txt`. We use [pyenv](https://github.com/pyenv/pyenv/) to control Python versions and specifically choose the `anaconda3-4.3.0` version, as indicated in `.python-version` file:

```
$ pyenv install anaconda3-4.3.0
$ pip install -r requirements.txt
```

## Authentication

We use a `.env` file to manage authentication between all vendors.

Create a new file, `.env`, in the root directory with the following contents:

```
GOOGLE_PROJECT_ID=
GOOGLE_PRIVATE_KEY_
GOOGLE_PRIVATE_KEY=
GOOGLE_CLIENT_EMAIL=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_X509_CERT_URL=

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

AZURE_SUBSCRIPTION_KEY=
```

Generate keys for services on each platform by following each vendor's instructions.

### Google Cloud Vision Authentication

You will need to [create a service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating_a_service_account) and then create a private key for that new service account. The key type should be downloaded as JSON. From that JSON file, you will need to copy the following keys into the respective keys in the `.env` file created above:

```json
{
  "project_id": "xxx",
  "private_key_id": "xxx",
  "private_key": "xxx",
  "client_email": "xxx",
  "client_id": "xxx",
  "client_x509_cert_url": "xxx"
}
```

**Do not escape the values in double quotes in the `.env` file.** That is, it should look like:

```
GOOGLE_PROJECT_ID=foo-bar-12345
GOOGLE_PRIVATE_KEY_ID=XXXXXXX
GOOGLE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nXXXXXX....
```

### AWS Rekognition Authentication

Create an AWS Access Key ID and Secret Access Key using the [guide](https://aws.amazon.com/premiumsupport/knowledge-center/create-access-key/) provided. You can find this under the [_Your Security Credentials_](https://console.aws.amazon.com/iam/home#/security_credential) page under AWS IAM, in the Access Key panel.

### Azure Authentication

Create a new API key under the try [_Your APIs_](https://azure.microsoft.com/en-us/try/cognitive-services/my-apis) page.

## Running

To run, use the following commands and append results to a CSV for each run:

```bash
$ python3 aws/aws.py images.csv >> aws_results.csv
$ python3 googlecloud/googlecloud.py images.csv >> googlecloud_results.csv
$ python3 azure/azure.py images.csv >> azure_results.csv
```

The output CSV format is in:

```
utc_timestamp,image_id,image_url,label,confidence
```

where `label` and `confidence` are provided by the service.
