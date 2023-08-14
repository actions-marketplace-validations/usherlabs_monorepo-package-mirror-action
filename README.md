# **Monorepo Package Mirror Action**

This GitHub Action mirrors a repository to another repository while rewriting git history to ignore certain files or directories. It is based on the original **[repository-mirroring-action](https://github.com/pixta-dev/repository-mirroring-action)** by pixta-dev, but with some added features:

- It supports .mirrorignore file to ignore certain paths when mirroring.
- It adds .gitkeep and .private files to the ignored directories that exist on the last commit.
- It commits these changes as **`github.actor`**.

This action is perfect for maintaining a clean, public-facing mirror of a private repository.

## **How It Works**

1. It's recommended to set it to run on main branch pushes and deletions. You can configure the branch in the settings of the GitHub action.
2. It runs within a Docker environment, containing the pushed repository at **`/github/workspaces`**.
3. It uses **`git-filter-repo`** to rewrite git history, removing all paths (directories and files) specified in the **`.mirrorignore`** file. See the **[documentation](https://htmlpreview.github.io/?https://github.com/newren/git-filter-repo/blob/docs/html/git-filter-repo.html)** for more details about git-filter-repo mechanisms.
4. If any removed directories were present on the last commit, they will be replaced with a directory containing **`.gitkeep`** and **`.private`** files.
5. These changes are committed and pushed to the mirror repository.

## Notes

- All caveats present in **`git-filter-repo`** apply here. Check **[here](https://htmlpreview.github.io/?https://github.com/newren/git-filter-repo/blob/docs/html/git-filter-repo.html)** for detailed limitations.
- Only one branch is mirrored, as set by `main_branch` action parameter.

## Usage

Customize following example workflow (namely replace `<username>/<target_repository_name>` with the right information) and save as `.github/workflows/main.yml` on your source repository.

To find out how to create and add the `GITLAB_SSH_PRIVATE_KEY`, follow the steps below:
1. [How to generate an SSH key pair](https://docs.gitlab.com/ee/ssh/#generate-an-ssh-key-pair). Recommended encryption would be _at least_ `2048-bit RSA`.
2. Add the _public_ key to [your gitlab account](https://gitlab.com/-/profile/keys)
3. Add the _private_ key as a secret to your workflow. More information on [creating and using secrets](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets).


```yaml
name: Mirroring

on:
  push:
    branches:
      - master

jobs:
  public_mirror:
    runs-on: ubuntu-latest
    steps:
      # <-- must use actions/checkout before mirroring!
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - uses: usher-labs/monorepo-package-mirror-action@main
        with:
          target_repo_url:
            git@github.com:<username>/<target_repository_name>.git
          ssh_private_key:
            # <-- use 'secrets' to pass credential information.
            ${{ secrets.SSH_PRIVATE_KEY }}
          main_branch: master
```

##  .mirrorignore file
To avoid copying specific files or directories on the mirrored repository, you can add a `.mirrorignore` file to the root of the source repository.

```ignore
# .mirrorignore example content
# Be aware: the mirrorignore parse isn't robust
# file path format:
# path/to/file.txt
# directory path format:
# path/to/dir or path/to/dir
# spaces on files or folders isn't supported.
# glob pattern isn't supported.

# won't copy the following files to the mirror repo
packages/broker
packages/validator
# to avoid copying again this action to the mirror
# rename to the appropriate action file
.github/workflows/public-mirror.yml
```

# Acknowledgements

This action is based on the original **[repository-mirroring-action](https://github.com/pixta-dev/repository-mirroring-action)** by pixta-dev. We've added features for more flexibility when mirroring repositories, especially when some files or directories need to be kept private.
