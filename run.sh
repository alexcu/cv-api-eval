#!/usr/bin/env sh

mkdir -p csv/aws csv/googlecloud csv/azure
mkdir -p log/aws log/googlecloud log/azure

src_images=$1 #images_test.csv,images_custom.csv,images_cocoval2017.csv
src_images_type=${src_images%.*}
mail_rcpt=$2 #xxxx@deakin.edu.au
mail_user=$3 #xxxx@gmail.com:password

run_ts=$(date +%Y-%m-%dT%H:%M:%S%z)
mail_temp=$(mktemp)

aws_temp=$(mktemp)
aws_final=csv/aws/${run_ts}_$src_images_type.csv
aws_all=csv/aws/_all_$src_images_type.csv

google_temp=$(mktemp)
google_final=csv/googlecloud/${run_ts}_$src_images_type.csv
google_all=csv/googlecloud/_all_$src_images_type.csv

azure_temp=$(mktemp)
azure_final=csv/azure/${run_ts}_$src_images_type.csv
azure_all=csv/azure/_all_$src_images_type.csv

echo Running AWS Rekognition on $src_images...
python3 aws/aws.py $src_images > $aws_temp

echo Running Google Cloud Vision on $src_images...
python3 googlecloud/googlecloud.py $src_images > $google_temp

echo Running Azure Computer Vision on $src_images...
python3 azure/azure.py $src_images > $azure_temp

cat > $mail_temp << EOF
Subject: Vision API Test - Success
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MULTIPART-MIXED-BOUNDARY"

--MULTIPART-MIXED-BOUNDARY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Success with count of rows inferred:

AWS:	$(wc -l < $aws_temp)
Google:	$(wc -l < $google_temp)
Azure:	$(wc -l < $azure_temp)

--MULTIPART-MIXED-BOUNDARY
Content-Type: text/csv
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=aws.csv

$(cat $aws_temp|base64)

--MULTIPART-MIXED-BOUNDARY
Content-Type: text/csv
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=google.csv

$(cat $google_temp|base64)

--MULTIPART-MIXED-BOUNDARY
Content-Type: text/csv
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=azure.csv

$(cat $azure_temp|base64)

--MULTIPART-MIXED-BOUNDARY--
EOF

cat $aws_temp >> $aws_final
cat $google_temp >> $google_final
cat $azure_temp >> $azure_final

cat $aws_final >> $aws_all
cat $google_final >> $google_all
cat $azure_final >> $azure_all

curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd --mail-rcpt "$mail_rcpt"  --upload-file $mail_temp --user "$mail_user" --insecure
