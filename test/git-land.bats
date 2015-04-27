load setup

# Usage
# -----------------------------------------------------------------------------
@test "invoking git-land with no arguments prints usage and exits" {
  run git land
  [ $status -ne 0 ]
  [[ "$output" =~ 'Usage: git land' ]]
}

@test "invoking git-land with three arguments prints usage and exits" {
  run git land foo bar applesauce
  [ $status -ne 0 ]
  [[ "$output" =~ 'Usage: git land' ]]
}

# General error conditions
# -----------------------------------------------------------------------------
@test "exits with an error if user doesn't confirm merge" {
  run bash -c "yes no | git land 123"
  [ $status -eq 1 ]
}

# All options fully specified
# -----------------------------------------------------------------------------
@test "'git land origin feature-branch:master' fetches latest target branch and updates the local copy" {
  clone_repo "origin" "local-two"
  enter_repo "local-two"
  write_commit "third master commit" "master.txt"
  run git push origin master

  enter_repo "local"

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]

  run git log --pretty=format:"%s"
  [[ "${lines[0]}" =~ 'second feature commit' ]]
  [[ "${lines[1]}" =~ 'first feature commit' ]]
  [[ "${lines[2]}" =~ 'third master commit' ]]
  [[ "${lines[3]}" =~ 'second master commit' ]]
  [[ "${lines[4]}" =~ 'first master commit' ]]
}

@test "'git land origin feature-branch:master' aborts and exits with an error if updating the target branch fails" {
  enter_repo "local"
  git remote remove origin

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -ne 0 ]
}

@test "'git land origin feature-branch:master' does an interactive rebase of feature-branch on master" {
  enter_repo "local"

  master_tip=`git log master -n1 --pretty=format:"%h"`
  feature_branch_tip=`git log feature-branch -n1 --pretty=format:"%h"`
  expected=`git log feature-branch --reverse --pretty=format:"pick %h %s" | tail -2`

  yes | git land origin feature-branch:master

  # the first two lines should pick the feature commits
  observed=`cat editor-input | head -2`
  [ "$expected" == "$observed" ]

  # the comment should describe a rebase of the feature onto the tip of master
  observed=`cat editor-input | head -4 | tail -1`
  [[ "$observed" =~ "Rebase $master_tip..$feature_branch_tip onto $master_tip" ]]
}

@test "'git land origin feature-branch:master' aborts and exits with an error if the rebase fails" {
  enter_repo "local"

  git checkout feature-branch
  write_commit "conflicting feature commit" "master.txt"

  local_master_log_before=`git log master --pretty=format:"%s"`

  run bash -c "yes | git land origin feature-branch:master"
  # it should exit with a non-zero status
  [ $status -ne 0 ]

  # master should not have changed
  master_log=`git log master --pretty=format:"%s"`
  [[ ! master_log =~ 'feature commit' ]]

  # origin should not have been updated
  enter_repo "origin"
  master_log=`git log master --pretty=format:"%s"`
  [[ ! master_log =~ 'feature commit' ]]
}

@test "'git land origin feature-branch:master' fast-forward merges feature-branch on top of local master" {
  enter_repo "local"

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]

  run git log --pretty=format:"%s"
  [[ "${lines[0]}" =~ 'second feature commit' ]]
  [[ "${lines[1]}" =~ 'first feature commit' ]]
  [[ "${lines[2]}" =~ 'second master commit' ]]
  [[ "${lines[3]}" =~ 'first master commit' ]]
}

@test "'git land origin feature-branch:master' pushes local master to origin" {
  enter_repo "local"

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]

  local_log=`git log --pretty=format:"%h %s"`

  enter_repo "origin"
  origin_log=`git log --pretty=format:"%h %s"`

  [ "$origin_log" = "$local_log" ]
}
