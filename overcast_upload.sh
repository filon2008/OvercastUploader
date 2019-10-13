echo Log In...
curl -L -d "then=podcasts" -d "email=your@email.com" -d "password=yourpassword" -X POST -c overcast_cookies https://overcast.fm/login || exit 1
curl -L -b overcast_cookies -o upload.tmp https://overcast.fm/uploads || exit 1
policy=$(grep -o -E '<input type="hidden" id="upload_policy" name="policy" value=".*"/>' upload.tmp |sed 's/<input type="hidden" id="upload_policy" name="policy" value="//g' |sed 's/"\/>//g')
signature=$(grep -o -E '<input type="hidden" id="upload_signature" name="signature" value=".*"/>' upload.tmp |sed 's/<input type="hidden" id="upload_signature" name="signature" value="//g' |sed 's/"\/>//g')
AWSAccessKeyId=$(grep -o -E '<input type="hidden" name="AWSAccessKeyId" value=".*"/>' upload.tmp |sed 's/<input type="hidden" name="AWSAccessKeyId" value="//g' |sed 's/"\/>//g')
filename=$(basename $1)
key=$(grep -o -E '<input type="hidden" name="key" value=".*"/>' upload.tmp |sed 's/<input type="hidden" name="key" value="//g' |sed 's/"\/>//g'|sed "s/\${filename}/$filename/g")
rm upload.tmp
echo Uploading $1
curl -L -F "bucket=uploads-overcast" -F "key=$key" -F "AWSAccessKeyId=$AWSAccessKeyId" -F "acl=authenticated-read" -F "policy=$policy" -F "signature=$signature" -F "Content-Type=audio/mpeg" -F "file=@$1" -X POST -b overcast_cookies https://uploads-overcast.s3.amazonaws.com/ || exit 1
curl -L -F "key=$key" -X POST -b overcast_cookies https://overcast.fm/podcasts/upload_succeeded/ || exit 1