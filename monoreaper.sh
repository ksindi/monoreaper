#!/bin/bash
#
# Merge multiple GitHub repos into a master-repo.
#
# chmod +x monoreaper.sh
# Usage: bash monoreaper.sh monorepo repo0 repo1

# check number of arguments at least 1
if (( $# < 2 )); then
  printf "Error: At least one repo required.\n"
  printf "Usage: bash monoreaper.sh monorepo repo0 repo1"
  printf "Exiting...\n"
  exit 1
fi

WORK_DIR=$(mktemp -d)
MASTER_DIR=$1 && mkdir $MASTER_DIR

#######################################
# Move repo contents into a subdirectory of the same name
# Globals:
#   WORK_DIR
# Arguments:
#   Repository
# Returns:
#   None
#######################################
prepare_repo () {
  local old_repo=$1
  repo_name=$(basename $repo)
  local new_repo=$WORK_DIR/$repo_name
  mkdir -p $new_repo
  mv $old_repo/.git/ $new_repo
  mv $old_repo/.gitignore $new_repo
  mv $old_repo/ $new_repo/$repo_name
  pushd $new_repo
  git add $repo_name
  git commit -am "Preparing ${repo_name} repository for merging."
  popd
}

# create root directory
pushd $MASTER_DIR
git init
touch README.md
git add README.md
git commit -am "Inital commit (monorepo)"
# create clean branch which will be used to stage new repos
git branch clean

for repo in "${@:2}"
do
  git checkout clean
  prepare_repo $repo
  repo_name=$(basename $repo)
  remote_name=remote_${repo_name}
  git remote add $remote_name $WORK_DIR/$repo_name
  git fetch --all
  git branch $repo_name $remote_name/master
  git checkout $repo_name
  git checkout master
  git merge $repo_name master --no-commit --no-ff
  git commit -am "Merge repo ${repo_name}"
  git remote remove $remote_name
done
popd

# clean up
printf "Cleaning up...\n"
rm -rf $WORK_DIR
