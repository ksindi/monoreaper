# MonoReaper

Merge multiple GitHub repositories into a monorepo while preserving commit history. Each repo will live as a subdirectory. **Currently only works in Linux**.

Features:
  - Merge multiple repos while keeping full history and commit hashes.
  - Specify branches of each repo to merge.
  - Migrate repos into existing monorepo.

Requirements:
  - git version 2.9+.

## Usage

```bash
export MONOREPO_NAME=monorepo  # defaults to monorepo
git clone git@github.com:ksindi/monoreaper.git && cd monoreaper/
chmod +x monoreaper.sh
bash monoreaper.sh owner/repo0 owner/repo1
# you can specify another default branch via `owner/repo0/some-branch`.
```

The above script will create a `monorepo` directory with a README.md file and subdirectores `repo0` and `repo1`. Note only the default branches of each repo will be included.

If you now want to add the monorepo to GitHub:

```bash
cd monorepo/
git remote add origin git@github.com:owner/monorepo
git push -f origin master
```

### Merging with existing monorepos

If you already have a monorepo and want to merge other repos into it,
all you have to do is include a `MONOREPO_DIR` env variable:

```bash
MONOREPO_DIR=path/to/my/monorepo bash monoreaper.sh owner/repo0 owner/repo1
```

Note that the `MONOREPO_DIR` must have `master` as default branch.


## Why monorepos?

- Streamlines ops logic. The overhead of setting up pipelines and deployments is cumbersome.
- Shared codebase introduces shared ownership, naming and style.
- Dependencies across services are easier to manage.
- Searching code across multiple repos is a hassle.
- Lots of great tools that take advantage of monorepos. See [awesome-monorepo](https://github.com/korfuri/awesome-monorepo).
- Lots of anecdotal evidence:
  - [Optimizing for iteration speed](https://erikbern.com/2017/07/06/optimizing-for-iteration-speed.html)
  - [Why Google Stores Billions of Lines of Code in a Single Repository](https://research.google.com/pubs/pub45424.html)
