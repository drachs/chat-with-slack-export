# Bash script to ingest data
# This involves scraping the data from the web and then cleaning up and putting in Weaviate.
# Error if any command fails

if [ ! -f slack-export.zip ]; then
    echo You must provide a slack-export.zip
    exit 1
fi

mkdir docs-json
cd docs-json
unzip ../slack-export.zip
cd ..
mkdir docs-txt
python3 ./slack_archive_to_text.py

#python3 ingest.py
