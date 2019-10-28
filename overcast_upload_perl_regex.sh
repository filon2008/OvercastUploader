echo Log In...
curl -L -d "then=podcasts" -d "email=your@email.com" -d "password=yourpassword" -X POST -c overcast_cookies https://overcast.fm/login || exit 1
curl -L -b overcast_cookies -o upload.tmp https://overcast.fm/uploads || exit 1
policy=$(grep -Po '<input type="hidden" id="upload_policy" name="policy" value="\K.+(?="/>)' upload.tmp)
signature=$(grep -Po '<input type="hidden" id="upload_signature" name="signature" value="\K.+(?="/>)' upload.tmp)
AWSAccessKeyId=$(grep -Po '<input type="hidden" name="AWSAccessKeyId" value="\K.+(?="/>)' upload.tmp)
filename=$(basename "$1")
key=$(grep -Po '<input type="hidden" name="key" value="\K.+(?="/>)' upload.tmp|sed "s/\${filename}/$filename/g")
rm upload.tmp
echo Uploading $1
curl -L -F "bucket=uploads-overcast" -F "key=$key" -F "AWSAccessKeyId=$AWSAccessKeyId" -F "acl=authenticated-read" -F "policy=$policy" -F "signature=$signature" -F "Content-Type=audio/mpeg" -F "file=@$1" -X POST -b overcast_cookies https://uploads-overcast.s3.amazonaws.com/ || exit 1
curl -L -F "key=$key" -X POST -b overcast_cookies https://overcast.fm/podcasts/upload_succeeded/ || exit 1