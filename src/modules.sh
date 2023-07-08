#!/usr/bin/env bash

# if it's a file: don't do nothing
# else checks if it is already a dir
# if there's no dir on path
# - create recursively <dir>
# finally touches .gitkeep and .private to dir
add_private_files() {
    if [ -z "$1" ]; then
        echo "Error: path to the directory is required"
        return 1
    fi
  dir=$1
    if [ -f "$dir" ]; then
        echo "$dir is a file. Skipping..."
    else
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
        fi
        touch "$dir/.gitkeep"
        touch "$dir/.private"
    fi
}

apply_changes_git() {
  if [ -z "$1" ]; then
    echo "Error: commit message is required" >&2
    return 1
  fi
  msg=$1
  git add .
  git commit -m "$msg"
}

# parses .mirrorignore
# - filters directories only
# - removes lines that starts with # comment
# we must check if is a directory manually, it may or may not have a slash
parse_mirror_ignore() {
  if [ -z "$1" ]; then
    echo "Error: path to the .mirrorignore file is required" >&2
    return 1
  fi
  mirror_ignore_path=$1

  ls -la "$GITHUB_WORKSPACE" >&2
  if [ ! -f "$mirror_ignore_path" ]; then
    echo "Error: $mirror_ignore_path does not exist" >&2
    return 1
  fi

  # get valid lines
  valid_lines=$(grep -v '^#' "$mirror_ignore_path" | grep '[^[:blank:]]')

  # exclude files from this list
  valid_directories=()
  for line in $valid_lines; do
    if [ -d "$line" ]; then
      valid_directories+=("$line")
    elif [ ! -f "$line" ]; then
      #if isn't file nor directory, we can add to as it will be created later
      valid_directories+=("$line")
    fi
  done

  # return array
  echo "${valid_directories[@]}"
}
