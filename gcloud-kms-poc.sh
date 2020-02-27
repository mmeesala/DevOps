KEYRING_NAME=demokeyring
KEY_NAME=demokey
GS_BUCKET=enc-demo-bucket
PROJECT_NAME=linisha-labs
LOCATION=us-west2
ROTATION_PERIOD=1d
FILE=demofile.txt

echo " "
echo " "
echo "Enabling Cloud KMS Services..."
echo " "
echo "gcloud services enable cloudkms.googleapis.com"
gcloud services enable cloudkms.googleapis.com

echo " "
echo " "
echo "Creating Google bucket..."
echo " "
echo "gsutil mb -l ${LOCATION} gs://${GS_BUCKET}"
gsutil mb -l ${LOCATION} gs://${GS_BUCKET}

echo " "
echo " "
echo "Creating keyring..."
echo " "
echo "gcloud kms keyrings create $KEYRING_NAME --location ${LOCATION}"
#gcloud kms keyrings create $KEYRING_NAME --location ${LOCATION}

echo " "
echo " "
echo "Creating key..."
echo " "
echo "gcloud kms keys create $KEY_NAME --location ${LOCATION} --keyring $KEYRING_NAME  --purpose encryption"
gcloud kms keys create $KEY_NAME --location ${LOCATION} --keyring $KEYRING_NAME  --purpose encryption

echo " "
echo " "
echo "Describe the keys..."
echo " "
echo "gcloud kms keys describe  $KEY_NAME  --location ${LOCATION} --keyring $KEYRING_NAME"
gcloud kms keys describe  $KEY_NAME  --location ${LOCATION} --keyring $KEYRING_NAME

echo " "
echo " "
echo "List the keys..."
echo " "
echo "gcloud kms keys list --keyring=$KEYRING_NAME --location=${LOCATION}"
gcloud kms keys list --keyring=$KEYRING_NAME --location=${LOCATION}

date
NEXT_ROTATION_TIME=`date +%Y-%m-%dT%H:%M:%S.1234Z`

echo " "
echo " "
echo "Set 1d auto-rotation for the key - $KEY_NAME..."
echo " "
echo "gcloud kms keys set-rotation-schedule  $KEY_NAME --location=${LOCATION} --keyring=$KEYRING_NAME --rotation-period=${ROTATION_PERIOD} --next-rotation-time=${NEXT_ROTATION_TIME}"
gcloud kms keys set-rotation-schedule  $KEY_NAME --location=${LOCATION} --keyring=$KEYRING_NAME --rotation-period=${ROTATION_PERIOD} --next-rotation-time=${NEXT_ROTATION_TIME}

echo " "
echo " "
echo "Describe the keys..."
echo " "
echo "gcloud kms keys describe  $KEY_NAME  --location ${LOCATION}  --keyring $KEYRING_NAME"
gcloud kms keys describe  $KEY_NAME  --location ${LOCATION}  --keyring $KEYRING_NAME

echo " "
echo " "
echo "Creating demo file called ${FILE} ..."
echo "This is new test from MLP for KMS demo" > ${FILE}

echo " "
echo " "
echo "Encrypting ${FILE} file and store it to ${FILE}.enc ..."
echo " "
echo "gcloud kms encrypt --location ${LOCATION} --keyring $KEYRING_NAME --key  $KEY_NAME --plaintext-file ${FILE} --ciphertext-file ${FILE}.enc"
gcloud kms encrypt --location ${LOCATION} --keyring $KEYRING_NAME --key  $KEY_NAME --plaintext-file ${FILE} --ciphertext-file ${FILE}.enc

echo " "
echo " "
echo "View ${FILE} contents ..."
cat ${FILE}
echo " "
echo " "
echo "View ${FILE}.enc contents ..."
cat ${FILE}.enc

echo " "
echo " "
echo "Copying encrypted file ${FILE} to gs://${GS_BUCKET}/ ..."
echo " "
echo "gsutil cp ${FILE}.enc gs://${GS_BUCKET}/"
gsutil cp ${FILE}.enc gs://${GS_BUCKET}/

echo " "
echo " "
echo "gsutil cat  gs://${GS_BUCKET}/${FILE}.enc"
echo " "
gsutil cat  gs://${GS_BUCKET}/${FILE}.enc

echo " "
echo " "
echo "Applying KMS key encryption to gs://${GS_BUCKET}/ ..."
echo " "
echo "gsutil kms encryption -k projects/${PROJECT_NAME}/locations/${LOCATION}/keyRings/$KEYRING_NAME/cryptoKeys/$KEY_NAME gs://${GS_BUCKET}/"
gsutil kms encryption -k projects/${PROJECT_NAME}/locations/${LOCATION}/keyRings/$KEYRING_NAME/cryptoKeys/$KEY_NAME gs://${GS_BUCKET}/

echo " "
echo " "
echo "Copying the ${FILE} file to gs://${GS_BUCKET}/ ..."
echo " "
echo "gsutil cp ${FILE}  gs://${GS_BUCKET}/"
gsutil cp ${FILE}  gs://${GS_BUCKET}/

echo " "
echo " "
echo "Checking the status of the GS object ..."
echo " "
echo "gsutil stat gs://${GS_BUCKET}/${FILE}"
gsutil stat gs://${GS_BUCKET}/${FILE}

echo " "
echo " "
echo "Downloading the ${FILE} file to local ..."
echo " "
echo "gsutil cp gs://${GS_BUCKET}/${FILE} ${FILE}.new"
gsutil cp gs://${GS_BUCKET}/${FILE} ${FILE}.new

echo " "
echo " "
echo "Checking the content on downloaded file ${FILE}.new ..."
echo " "
cat ${FILE}.new

echo " "
echo " "
echo "Checking the $KEY_NAME version ..."
echo " "
echo "gcloud kms keys describe  $KEY_NAME  --location ${LOCATION} --keyring $KEYRING_NAME | grep Versions"
gcloud kms keys describe  $KEY_NAME  --location ${LOCATION} --keyring $KEYRING_NAME | grep Versions

echo " "
echo " "
echo "Demo completed!"
echo " "
echo "Exiting..."
