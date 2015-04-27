# Ensure git finds the local git-land
project_root=`echo $(git rev-parse --show-toplevel)`
export PATH=$project_root:$PATH

# Fixture setup
fixture_root="$project_root/scratch"

setup() {
  cd $project_root

  # initialize origin
  init_repo "origin"

  # initialize local
  clone_repo "origin" "local"

  enter_repo "local"

  # add an initial commit to master
  write_commit "first master commit" "master.txt"
  git push origin master

  # create a feature branch with two commits
  git checkout -b feature-branch
  write_commit "first feature commit" "feature.txt"
  write_commit "second feature commit" "feature.txt"

  # add a commit to master after feature branch diverges
  git checkout master
  write_commit "second master commit" "master.txt"
  git push origin master
}

function init_repo() {
  repo=$1

  rm -rf $fixture_root/$repo
  mkdir -p $fixture_root/$repo
  cd $fixture_root/$repo
  git init --bare

  cd -
}

function clone_repo() {
  from=$fixture_root/$1
  to=$fixture_root/$2

  rm -rf $to
  git clone $from $to

  # use the mock editor
  cd $to
  git config core.editor $project_root/test/editor.bash
  cd -
}

function write_commit() {
  echo "$1" > $2
  git add $2
  git commit -m "wrote '$1' to $2"
}

function enter_repo() {
  cd $fixture_root/$1
}
