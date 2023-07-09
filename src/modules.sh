#!/usr/bin/env bash

# if it's a file: don't do nothing
# else checks if it is already a dir
# if there's no dir on path should error
# finally touches .gitkeep and .private to dir
add_private_files() {
    if [ -z "$1" ]; then
        echo "Error: path to the directory is required" >&2
        return 1
    fi
  dir=$1
  echo "Adding private files to $dir..."
    if [ ! -d "$dir" ]; then
        echo "Error: $dir is not a directory" >&2
        return 1
    fi
        touch "$dir/.gitkeep"
        touch "$dir/.private"
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
# if it is a existent directory, we will use it. Otherwise we won't.
# it's important to confirm that, as we just want to consider directories to add something to it if they are currently
# live at the repository, and not previously commited and deleted
get_actual_directories_from_mirror_ignore() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: mirror ignore path and root directory are required" >&2
    return 1
  fi
  mirror_ignore_path=$1
  root_dir=$2

  if [ ! -f "$mirror_ignore_path" ]; then
    echo "Error: $mirror_ignore_path does not exist" >&2
    return 1
  fi

  # get valid lines
  valid_lines=$(grep -v '^#' "$mirror_ignore_path" | grep '[^[:blank:]]')

  # exclude files from this list
  valid_directories=()
  for line in $valid_lines; do
    complete_path="$root_dir/$line"
    if [ -d "$complete_path" ]; then
      valid_directories+=("$complete_path")
    fi
  done

  # return array
  echo "${valid_directories[@]}"
}
