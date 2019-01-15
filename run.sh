#!/usr/bin/env bash

convertsecs() {
 ((h=${1}/3600))
 ((m=(${1}%3600)/60))
 ((s=${1}%60))
 printf "%02d:%02d:%02d\n" $h $m $s
}

mkdir -p csv/aws csv/googlecloud csv/azure
mkdir -p log/aws log/googlecloud log/azure

#echo "PWD IS: $(pwd)"
echo Starting at: $(date $T)

src_images=$1 #images_test.csv,images_custom.csv,images_cocoval2017.csv
src_images_type=${src_images%.*}
mail_rcpt=$2 #xxxx@deakin.edu.au
mail_user=$3 #xxxx@gmail.com:password

#echo the head is
#head $src_images

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

start_time="$(date -u +%s)"
start_time_fmt=$(date $T)

date $T
echo Running AWS Rekognition on $src_images...
aws_start_time="$(date -u +%s)"
aws_start_time_fmt=$(date $T)
python3 aws/aws.py $src_images > $aws_temp
aws_end_time="$(date -u +%s)"
aws_end_time_fmt=$(date $T)
aws_elapsed_seconds="$(($aws_end_time-$aws_start_time))"

date $T
echo Running Google Cloud Vision on $src_images...
google_start_time="$(date -u +%s)"
google_start_time_fmt=$(date $T)
python3 googlecloud/googlecloud.py $src_images > $google_temp
google_end_time="$(date -u +%s)"
google_end_time_fmt=$(date $T)
google_elapsed_seconds="$(($google_end_time-$google_start_time))"

date $T
echo Running Azure Computer Vision on $src_images...
azure_start_time="$(date -u +%s)"
azure_start_time_fmt=$(date $T)
python3 azure/azure.py $src_images > $azure_temp
azure_end_time="$(date -u +%s)"
azure_end_time_fmt=$(date $T)
azure_elapsed_seconds="$(($azure_end_time-$azure_start_time))"

end_time="$(date -u +%s)"
end_time_fmt=$(date $T)
elapsed_seconds="$(($end_time-$start_time))"

cat > $mail_temp << EOF
Subject: Vision API Test - Success [$src_images]
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MULTIPART-MIXED-BOUNDARY"

--MULTIPART-MIXED-BOUNDARY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Success with count of rows inferred:

AWS:	$(wc -l < $aws_temp)
Google:	$(wc -l < $google_temp)
Azure:	$(wc -l < $azure_temp)

Host:  $(hostname)

AWS Time Start:	$aws_start_time_fmt
AWS Time End:	$aws_end_time_fmt
AWS Duration:	$(convertsecs $aws_elapsed_seconds)

Google Time Start:	$google_start_time_fmt
Google Time End:	$google_end_time_fmt
Google Duration:	$(convertsecs $google_elapsed_seconds)

Azure Time Start:	$azure_start_time_fmt
Azure Time End:	$azure_end_time_fmt
Azure Duration:	$(convertsecs $azure_elapsed_seconds)

Total Time Start:	$start_time_fmt
Total Time End:	$end_time_fmt
Total  Duration:	$(convertsecs $elapsed_seconds)

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

echo Finished at $(date $T)
echo -----------------------------
