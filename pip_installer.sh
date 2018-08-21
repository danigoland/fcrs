sed -e 's/[[:space:]]*#.*// ; /^[[:space:]]*$/d' requirements.txt | while read line; do
	pip install --no-cache-dir $line
done
