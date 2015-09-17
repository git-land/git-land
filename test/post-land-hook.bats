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
  echo "echo 'post-land'" > .git/hooks/post-land
  chmod -x .git/hooks/post-land

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]
  [[ ! "$output" =~ 'post-land' ]]
}

@test "if hook is defined and executable, runs the hook" {
  enter_repo "local"
  mkdir -p .git/hooks
  echo "echo 'post-land'" > .git/hooks/post-land
  chmod +x .git/hooks/post-land

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]
  [[ "$output" =~ 'post-land' ]]
}

@test "hook is passed the source, target, and remote" {
  enter_repo "local"
  mkdir -p .git/hooks
  echo 'echo "$1 $2 $3"' > .git/hooks/post-land
  chmod +x .git/hooks/post-land

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]
  [ "${lines[${#lines[@]} - 1]}" = "feature-branch master origin" ]
}

@test "hook runs after the land" {
  enter_repo "local"
  mkdir -p .git/hooks
  echo 'echo `git log -1 --pretty=format:"%s"`' > .git/hooks/post-land
  chmod +x .git/hooks/post-land

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]
  [ "${lines[${#lines[@]} - 1]}" = "wrote 'second feature commit' to feature.txt" ]
}

# Exit conditions
# -----------------------------------------------------------------------------
@test "if hook exits with a non-zero exit code, exits with that code" {
  enter_repo "local"
  mkdir -p .git/hooks
  echo "exit 42" > .git/hooks/post-land
  chmod +x .git/hooks/post-land

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 42 ]
}

@test "if hook exits with a zero exit code, so does git-land" {
  enter_repo "local"
  mkdir -p .git/hooks
  echo "exit 0" > .git/hooks/post-land
  chmod +x .git/hooks/post-land

  run bash -c "yes | git land origin feature-branch:master"
  [ $status -eq 0 ]
}
