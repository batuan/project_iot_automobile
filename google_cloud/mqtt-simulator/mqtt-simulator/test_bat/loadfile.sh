TOKEN="ya29.a0AWY7CkkJQmBTdSClVJ2LLpoZpcvmQFVeTInhzGI_ZhuRVaHqnDKohRgoN8_QQ7eTo-ZqVTMiGfqyNZnGncAkIpArCHWAX9_m0Db51G4L8AM4ZIzQ4qk0dB2yqtx2Ay35tR5s3ctu4WRIBPthMOFmhQAXv9wYV9gaCgYKAXkSARISFQG1tDrpO4AAWboiAsXlJY0EfDWGHg0166"
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