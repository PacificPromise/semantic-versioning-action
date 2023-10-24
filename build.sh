rm -rf index.sh

search_dir=./src
for entry in "$search_dir"/*; do
  cat $entry >>index.sh
done
