# MonoReaper

Merge github repositories into a monorepo directory while preserving commit history.

## Usage

```bash
git clone git@github.com:ksindi/monoreaper.git && cd monoreaper/
chmod +x monoreaper.sh
bash monoreaper.sh user/repo0 user/repo1
# you can specify branch via `user/repo0/some-branch`.
```

The above script will create a `monorepo` directory with a README.md file and subdirectores `repo0` and `repo1`.

If you now want to add the monorepo to GitHub:

```bash
cd monorepo/
git remote add origin git@github.com:user/monorepo
git push -f origin master
```

### Merging with existing monorepos

If you already have a monorepo and want to merge other repos into it,
all you have to do is include a `MONOREPO_DIR` env variable:

```bash
MONOREPO_DIR=path/to/my/monorepo bash monoreaper.sh user/repo0 user/repo1
```

Note that the `MONOREPO_DIR` must have `master` as default branch.
