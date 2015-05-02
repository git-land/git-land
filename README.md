# git-land

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
git land [<remote>] <pull request number>[:<target>]
git land [<remote>] <branch>[:<target>]
```

### Examples

```sh
git land 123
git land my-topic-branch
git land origin 42:target-branch
git land origin feature-branch:target-branch
```

## Installation

Put the bash script in a folder that is in your `PATH` and make it executable.
For example, to install it to `~/bin/`, do the following:

```sh
curl -o ~/bin/git-land https://raw.githubusercontent.com/bazaarvoice/git-land/master/git-land
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

### Configuring remote name

By default, `git-land` assumes the remote repository is pointed to by the git
remote `origin`. To use a different default git remote, set the `git-land.remote`
option. For example, to use a remote named `upstream`:

```sh
git config git-land.remote upstream
```

## Thanks

Thanks to [@paulirish][paulirish] for [git-open](https://github.com/paulirish/git-open),
from which I cribbed the format and some content for this README.

## Contributors

- [Lon Ingram][lawnsea]
- [Taka Kojima][gigafied]
- [Reason][reason]
- [John Roesler][vvcephei]

## License

Copyright 2015 Bazaarvoice, Inc. Licensed under Apache 2.0

http://www.apache.org/licenses/LICENSE-2.0

[gigafied]: https://github.com/gigafied
[lawnsea]: https://github.com/lawnsea
[paulirish]: https://github.com/paulirish
[reason]: https://github.com/reason-bv
[vvcephei]: https://github.com/vvcephei
