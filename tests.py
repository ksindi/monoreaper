import os
import os.path
import uuid
import tempfile

from git import Repo
from git.repo.fun import touch

from monoreaper import main


def create_repo(repo_path, num_commits=1):
    repo = Repo.init(path=repo_path, bare=True, mkdir=True)
    for _ in range(num_commits):
        filename = uuid.uuid4().hex
        new_file_path = os.path.join(repo_path, '{}.ext'.format(filename))
        touch(new_file_path)
        repo.index.add([new_file_path])
        repo.index.commit("Add file {}".format(filename))
    commits = list(repo.iter_commits('HEAD', max_count=num_commits))
    return repo, commits


def test_monoreaper():
    target_dir = 'monorepo'
    num_commits = 10
    tmp_dir = tempfile.mkdtemp()
    repo_a, commits_a = create_repo(os.path.join(tmp_dir, 'a'), num_commits)
    repo_b, commits_b = create_repo(os.path.join(tmp_dir, 'b'), num_commits)
    main(target_dir, repo_a.working_dir, repo_b.working_dir)
    monorepo = Repo(target_dir)
    monorepo_commits = list(monorepo.iter_commits('HEAD'))
    assert (commits_a + commits_b) == monorepo_commits[:num_commits * 2]
