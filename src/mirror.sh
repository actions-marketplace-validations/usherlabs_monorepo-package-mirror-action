#!/usr/bin/env bash
set -eu

setup-ssh.sh
source modules.sh

# else it errors
git config --global --add safe.directory $GITHUB_WORKSPACE
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git config --global user.name "$GITHUB_ACTOR"


export GIT_SSH_COMMAND="ssh -v -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -l $INPUT_SSH_USERNAME"
git remote add mirror "$INPUT_TARGET_REPO_URL"

command="python3 /git-filter-repo --force --refs $INPUT_MAIN_BRANCH"

if [ -f "$GITHUB_WORKSPACE/.mirrorignore" ]; then
  echo "Found .mirrorignore file."

  # we must parse before resetting, otherwise things will be bad
  echo "Parsing .mirrorignore file..."
  directories=$(parse_mirror_ignore "/.mirrorignore")

  cp "$GITHUB_WORKSPACE/.mirrorignore" /.mirrorignore
    # execute if file exists
    $command --invert-paths --paths-from-file /.mirrorignore
    if [ $? -ne 0 ]; then
        echo "git-filter-repo command failed."
        exit 1
    fi

    echo "Adding private files..."
    echo "$directories"

    for dir in $directories; do
        add_private_files "$dir"
    done

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
cleanup.sh mirror