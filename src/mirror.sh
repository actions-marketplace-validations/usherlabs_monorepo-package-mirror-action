#!/usr/bin/env bash
set -eu

setup-ssh.sh
source modules.sh

# else it errors
git config --global --add safe.directory $GITHUB_WORKSPACE

export GIT_SSH_COMMAND="ssh -v -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -l $INPUT_SSH_USERNAME"
git remote add mirror "$INPUT_TARGET_REPO_URL"

command="python3 /git-filter-repo --force --refs $INPUT_MAIN_BRANCH"

if [ -f "$GITHUB_WORKSPACE/.mirrorignore" ]; then
  echo "Found .mirrorignore file."
  cp "$GITHUB_WORKSPACE/.mirrorignore" /.mirrorignore
    # execute if file exists
    $command --paths-from-file /.mirrorignore
    if [ $? -ne 0 ]; then
        echo "git-filter-repo command failed."
        exit 1
    fi

    # add private files
    echo "Parsing .mirrorignore file..."
    directories=$(parse_mirror_ignore "/.mirrorignore")
    echo "Adding private files..."
    echo "$directories"
    add_private_files "${directories[@]}"

    echo "Applying changes..."
    apply_changes_git "Set as private files"
else
    echo "No .mirrorignore file found."
    # execute without --paths-from-file if file does not exist
    $command
fi


echo "Pushing to mirror..."
# get files from .mirrorignore
git push --tags --force --prune mirror "$INPUT_MAIN_BRANCH"

# NOTE: Since `post` execution is not supported for local action from './' for now, we need to
# run the command by hand.
/cleanup.sh mirror