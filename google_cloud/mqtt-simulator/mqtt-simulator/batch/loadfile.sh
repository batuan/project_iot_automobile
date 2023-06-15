TOKEN="ya29.a0AWY7CknP2Hx-gpDO1ZCyl7YHnBpbEWcY-N_IiqJ4iCwIn0YQQdl6hMdZ6pYVLJia99JnfPPIZFJrITn6519ejxZgZ73EwqbfehYq0LDYeshQn6v1haDfXuLfIkZwZTEjGKyZ8wT0HiXWmMtTxGFgwTN1O8xE3f8aCgYKAY0SARISFQG1tDrpFaifSlLNraAWE7aA1BM48g0166"
BUCKET="data_sensor_demo_eu3"

files=$(find . -type f -name '*.csv') #(find . -type f -name '*.csv')
for file in $files; 
do
    filepath=$(echo "$file" | sed 's|^./||')
    # echo $filepath
    curl -X POST -T $filepath \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/csv" \
    "https://storage.googleapis.com/upload/storage/v1/b/$BUCKET/o?uploadType=media&name=$filepath"
done

files=$(find . -type f -name '*.jpeg') #(find . -type f -name '*.csv')
for file in $files; 
do
    filepath=$(echo "$file" | sed 's|^./||')
    # echo $filepath
    curl -X POST -T $filepath \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: image/jpeg" \
    "https://storage.googleapis.com/upload/storage/v1/b/$BUCKET/o?uploadType=media&name=$filepath"
done
# we can delete all data after uploading. But currently, we won't do that.