#!/bin/bash

# Check if commit message is provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide a commit message"
    exit 1
fi

msg="$1"

echo "Deploying Updates to Github Pages"

# Remove all files in public directory
rm -rf ./public/*

# Build with hugo using anubis theme
hugo -t anubis

# Move CNAME file to public directory
# mv CNAME ./public/

# Navigate to public directory and commit changes
cd public
git add .
git commit -m "$msg"
git push origin master

# Return to original directory
cd .. 