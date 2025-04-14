#!/bin/bash

# Check if commit message is provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide a commit message"
    exit 1
fi

msg="$1"

echo "Deploying Updates to Github Pages"

# Build Jekyll site in production mode
JEKYLL_ENV=production bundle exec jekyll build

# Remove all files in public directory
rm -rf ./public/*

# Copy the built site to public directory
cp -r _site/* public/

# Create CNAME file
echo "blog.rifhanakram.com" > public/CNAME

# Navigate to public directory and commit changes
cd public
git add .
git commit -m "$msg"
git push origin master

# Return to original directory
cd .. 