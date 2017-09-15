#!/bin/bash
#
# Merge multiple GitHub repos into a master-repo.
#
# chmod +x monoreaper.sh
# Usage: bash monoreaper.sh master-dir owner0/repo0 owner1/repo1

# check number of arguments at least 1
if (( $# < 2 )); then
  printf 'Error: At least one repo required.\n'
  printf 'Usage: bash merge-repos.sh master-dir owner0/repo0 owner1/repo1'
  printf 'Exiting...\n'
  exit 1
fi

WORK_DIR=/tmp/github-merge-repos
rm -rf $WORK_DIR
WORK_SRC_DIR=$WORK_DIR/src && mkdir -p $WORK_SRC_DIR
WORK_TGT_DIR=$WORK_DIR/tgt && mkdir -p $WORK_TGT_DIR
MASTER_DIR=$1 && mkdir $MASTER_DIR

#######################################
# Move repo contents into a subdirectory of the same name
# Globals:
#   WORK_SRC_DIR
#   WORK_TGT_DIR
# Arguments:
#   Repository name
# Returns:
#   None
#######################################
prepare_repo () {
  local repo_name=$1
  local old_repo=$WORK_SRC_DIR/$repo_name
  local new_repo=$WORK_TGT_DIR/$repo_name
  mkdir -p $new_repo
  mv $old_repo/.git/ $new_repo
  mv $old_repo/.gitignore $new_repo
  mv $old_repo/ $new_repo/$repo_name
  pushd $new_repo
  git add $repo_name
  git commit -am "Preparing ${repo_name} repository for merging."
  popd
}

# create master-repo directory
pushd $MASTER_DIR
git init
touch README.md
git add README.md
git commit -am 'Inital Commit'
# create clean branch which will be used to stage new repos
git branch clean

for repo in "${@:2}"
do
  git checkout clean
  IFS='/' read owner repo_name <<<$repo
  gh_url="https://github.com/${owner}/${repo_name}.git"
  git clone $gh_url $WORK_SRC_DIR/$repo_name
  prepare_repo $repo_name
  remote_name=remote_${repo_name}
  git remote add $remote_name $WORK_TGT_DIR/$repo_name
  git fetch --all
  git branch $repo_name $remote_name/master
  git checkout $repo_name
  git checkout master
  git merge --squash $repo_name master
  git commit -am "Squashed ${repo_name}"
  git remote remove $remote_name 
done
popd

# clean up
printf 'Cleaning up...\n'
rm -rf WORK_DIR
