"""Export tracked and new customization files without staging or committing upstream repos."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[1]
patches = root / "patches"
patches.mkdir(exist_ok=True)
for name in ("keepassxc", "keepassdx", "keepassxc-browser"):
    repo = root / "upstream" / name
    patch = subprocess.check_output(["git", "diff", "--binary", "HEAD"], cwd=repo)
    new_files = subprocess.check_output(
        ["git", "ls-files", "--others", "--exclude-standard", "-z"], cwd=repo
    ).decode().strip("\0").split("\0")
    for path in filter(None, new_files):
        result = subprocess.run(["git", "diff", "--no-index", "--binary", "--", "/dev/null", path],
                                cwd=repo, capture_output=True)
        if result.returncode != 1:
            raise RuntimeError(f"Cannot export {name}/{path}: {result.stderr.decode()}")
        patch += result.stdout
    (patches / f"{name}.patch").write_bytes(patch)
    print(f"{name}: {len(patch)} patch bytes")
