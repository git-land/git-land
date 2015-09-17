load setup

# Running the hook
# -----------------------------------------------------------------------------
@test "if no hook defined, runs as expected" {
  enter_repo "local"

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]
}

@test "if hook defined but not executable, does not run hook" {
  enter_repo "local"
  mkdir -p .git/hooks
  echo "echo 'pre-land'" > .git/hooks/pre-land
  chmod -x .git/hooks/pre-land

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]
  [[ ! "$output" =~ 'pre-land' ]]
}

@test "if hook is defined and executable, runs the hook" {
  enter_repo "local"
  mkdir -p .git/hooks
  echo "echo 'pre-land'" > .git/hooks/pre-land
  chmod +x .git/hooks/pre-land

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]
  [[ "$output" =~ 'pre-land' ]]
}

@test "hook is passed the source, target, and remote" {
  enter_repo "local"
  mkdir -p .git/hooks
  echo 'echo "$1 $2 $3"' > .git/hooks/pre-land
  chmod +x .git/hooks/pre-land

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]
  [ "${lines[0]}" = "feature-branch master origin" ]
}

@test "hook runs before the land" {
  enter_repo "local"
  mkdir -p .git/hooks
  echo 'echo `git log -1 --pretty=format:"%s"`' > .git/hooks/pre-land
  chmod +x .git/hooks/pre-land

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]
  [ "${lines[0]}" = "wrote 'second master commit' to master.txt" ]
}

# Exit conditions
# -----------------------------------------------------------------------------
@test "if hook exits with a non-zero exit code, exits with that code" {
  enter_repo "local"
  mkdir -p .git/hooks
  echo "exit 42" > .git/hooks/pre-land
  chmod +x .git/hooks/pre-land

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 42 ]
}

@test "if hook exits with a zero exit code, performs the land" {
  enter_repo "local"
  mkdir -p .git/hooks
  echo "exit 0" > .git/hooks/pre-land
  chmod +x .git/hooks/pre-land

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]

  # feature branch landed to local master
  run git log --pretty=format:"%s"
  [ "${lines[0]}" = "wrote 'second feature commit' to feature.txt" ]
  [ "${lines[1]}" = "wrote 'first feature commit' to feature.txt" ]
  [ "${lines[2]}" = "wrote 'second master commit' to master.txt" ]
  [ "${lines[3]}" = "wrote 'first master commit' to master.txt" ]

  # origin updated
  local_log=`git log --pretty=format:"%h %s"`

  enter_repo "origin"
  origin_log=`git log --pretty=format:"%h %s"`

  [ "$origin_log" = "$local_log" ]
}
