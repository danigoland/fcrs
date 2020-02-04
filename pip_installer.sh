sed -e 's/[[:space:]]*#.*// ; /^[[:space:]]*$/d' requirements-c.txt | while read line; do
	pip install --no-cache-dir $line
done
