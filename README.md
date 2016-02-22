# git-land
[![Build Status](https://travis-ci.org/git-land/git-land.svg?branch=master)](https://travis-ci.org/git-land/git-land)

This is a git extension that merges a pull request or topic branch via rebasing
so as to avoid a merge commit. To merge a PR or branch, the script does the
following:

1. Fetch the latest `target` from the `remote` repository and reset your local
   `target` to match it.
2. Check out the pull request or topic branch.
3. Start an interactive rebase of the PR or topic branch on `target`.
4. If merging a PR, append `[close #<PR number>]` to the last commit message so
   that Github will close the pull request when the merged commits are pushed.
5. Fast-forward merge the rebased branch into `target`.
6. Push `target` to the `remote` repository.

Note:

* `remote` defaults to `"origin"` (configurable; see below)
* `target` defaults to `"master"`

## Usage

```
git land [options] [<remote>] <pull request number>[:<target>]
git land [options] [<remote>] <branch>[:<target>]
```

### Examples

```sh
git land 123
git land my-topic-branch
git land origin 42:target-branch
git land origin feature-branch:target-branch
```

### Options

#### `-f, --force-push-topic`: force push rebased topic branch

If this option is specified, `git-land` will force push the rebased topic branch
request to the `remote` repository. [Pull request branches are
read-only][read-only-pulls], so git-land exits with an error if invoked with a
pull request number and this option specified.

#### `-F, --no-force-push-topic`: do not force push rebased topic branch

If this option is specified, `git-land` will not force push the rebased topic
branch request to the `remote` repository, even if configured to do so by
default.

## Installation

### NPM (recommended)

You can install git-land using npm install.
```sh
npm install --global git-land
```

### Manual Installation

Put the bash script in a folder that is in your `PATH` and make it executable.
For example, to install it to `~/bin/`, do the following:

```sh
curl -o ~/bin/git-land https://raw.githubusercontent.com/git-land/git-land/master/git-land
chmod +x ~/bin/git-land
```

## Repository setup

Before pull requests for a remote repository can be landed by number, the git
remote for that repository must be configured to fetch pull requests as branches
in your local fork. To do so, run the following command, replacing both
occurences of `origin` with the name of the git remote if necessary.

```sh
git config --add remote.origin.fetch '+refs/pull/*/head:refs/remotes/origin/pr/*'
```

### Configuration

#### Remote repository

By default, `git-land` assumes the remote repository is pointed to by the git
remote `origin`. To use a different default git remote, set the `git-land.remote`
option. For example, to use a remote named `upstream`:

```sh
git config git-land.remote upstream
```

#### Target branch

By default, `git-land` merges the branch or pull request into `master` if no
target branch is specified. To use a different default target branch, set the
`git-land.target` option. For example, to use a default target branch named
`dev`:

```sh
git config git-land.target dev
```

#### Whether to force push the topic branch

By default, `git-land` does nothing with the topic branch after rebasing it
locally. Specifying the `--force-push-topic` option overrides this behavior,
force pushing the rebased topic branch to the target remote. To make this
behavior the default, set the `git-land.force-push-topic` option to `true`:

```sh
git config git-land.force-push-topic true
```

## Thanks

Thanks to [@paulirish][paulirish] for [git-open](https://github.com/paulirish/git-open),
from which I cribbed the format and some content for this README.

## Contributors

- [Lon Ingram][lawnsea]
- [Taka Kojima][gigafied]
- [Reason][reason]
- [John Roesler][vvcephei]
- [Taylor McKinney][taylormck]
- [Brian Sinclair][brianarn]

## License

Copyright 2015 Bazaarvoice, Inc., RetailMeNot, Inc., and git-land contributors
Licensed under Apache 2.0

http://www.apache.org/licenses/LICENSE-2.0

[brianarn]: https://github.com/brianarn
[gigafied]: https://github.com/gigafied
[lawnsea]: https://github.com/lawnsea
[paulirish]: https://github.com/paulirish
[reason]: https://github.com/reason-bv
[taylormck]: https://github.com/taylormck
[vvcephei]: https://github.com/vvcephei

[read-only-pulls]: https://help.github.com/articles/checking-out-pull-requests-locally/#tips
