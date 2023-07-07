#!/bin/bash

# Check if required commands are installed
if ! command -v git &> /dev/null
then
    echo "git could not be found. Please install git and rerun the script."
    exit 1
fi

#if awk is not available
if ! command -v awk &> /dev/null
then
    echo "awk could not be found. Please install awk and rerun the script."
    exit 1
fi


# Perform version comparison
git_version=$(git --version | awk '{print $3}')
minimum_version="2.25.2"

if [ "$(printf '%s\n' "$git_version" "$minimum_version" | sort -V | head -n1)" = "$git_version" ]; then
  echo "git version is $git_version, which is too low. Minimum version is $minimum_version."
  exit 1
fi


# Run git filter-repo
python3 ../git-filter-repo --invert-paths --paths-from-file '.mirrorignore' --target './test-destination/' --source './test-repo/' --debug
if [ $? -ne 0 ]; then
    echo "git-filter-repo command failed."
    exit 1
fi

echo "git-filter-repo command succeeded."