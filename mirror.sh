#!/usr/bin/env sh
set -eu

/setup-ssh.sh

git config --global --add safe.directory $GITHUB_WORKSPACE

export GIT_SSH_COMMAND="ssh -v -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -l $INPUT_SSH_USERNAME"
git remote add mirror "$INPUT_TARGET_REPO_URL"

# https://github.com/orgs/community/discussions/26855 github/workspace is common way to get mirrorignore from action
python3 ../git-filter-repo --invert-paths --paths-from-file "$GITHUB_WORKSPACE/.mirrorignore" --refs "$INPUT_MAIN_BRANCH"
git push --tags --force --prune mirror "refs/remotes/origin/$INPUT_MAIN_BRANCH:refs/heads/$INPUT_MAIN_BRANCH"

# NOTE: Since `post` execution is not supported for local action from './' for now, we need to
# run the command by hand.
/cleanup.sh mirror
