#!/bin/bash
#
# Merge multiple GitHub repos into a monorepo.
#
# chmod +x monoreaper.sh
# Usage: bash monoreaper.sh owner0/repo0 owner1/repo1

# check number of arguments at least 1
if (( $# < 1 )); then
  printf "Error: At least one repo required.\n"
  printf "Usage: bash monoreaper.sh owner0/repo0 owner1/repo1"
  printf "Exiting...\n"
  exit 1
fi

WORK_DIR=$(mktemp -d)
rm -rf $WORK_DIR
WORK_SRC_DIR=$WORK_DIR/src && mkdir -p $WORK_SRC_DIR
WORK_TGT_DIR=$WORK_DIR/tgt && mkdir -p $WORK_TGT_DIR

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
  mv $old_repo/ $new_repo/$repo_name
  pushd $new_repo
  git add $repo_name
  git commit -am "Preparing ${repo_name} repository for merging."
  popd
}

# create monorepo directory if it doesn't already exist
if [ -z "$MONOREPO_DIR" ]; then
  MONOREPO_DIR=$PWD/monorepo/ && mkdir -p $MONOREPO_DIR
  pushd $MONOREPO_DIR
  git init
  touch README.md
  git add README.md
  git commit -am "Inital commit [MONOREAPER]"
  popd
fi

pushd $MONOREPO_DIR
# create clean branch which will be used to stage new repos
git branch clean

for repo in "${@:1}"
do
  git checkout clean
  IFS="/" read owner repo_name repo_branch <<<$repo
  remote_branch="${repo_branch:-master}"
  gh_url="git@github.com:${owner}/${repo_name}.git"
  git clone $gh_url $WORK_SRC_DIR/$repo_name
  prepare_repo $repo_name
  remote_name=remote_${repo_name}
  git remote add $remote_name $WORK_TGT_DIR/$repo_name
  git fetch --all
  git branch $repo_name $remote_name/$remote_branch
  git checkout $repo_name
  git checkout master
  git merge $repo_name master --no-commit --no-ff
  git commit -am "Merge repo ${repo_name}"
  git remote remove $remote_name
done
popd

# clean up
printf "Cleaning up...\n"
rm -rf WORK_DIR
