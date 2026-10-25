"""PR ごとの CI がある repo か。.github/workflows に、PR が開いている間に走る pull_request の workflow があれば exit 0。
merge 後だけ走る物(types: [closed])は CI に数えない。"""
import glob, os, re, sys

top = sys.argv[1] if len(sys.argv) > 1 else "."
for path in glob.glob(os.path.join(top, ".github/workflows/*.y*ml")):
    try:
        text = open(path, encoding="utf-8").read()
    except OSError:
        continue
    text = re.sub(r"#.*", "", text)
    if not re.search(r"\bpull_request\b", text):
        continue
    if re.search(r"\bpull_request\s*:\s*\n\s+types\s*:\s*\[\s*closed\s*\]", text):
        continue
    sys.exit(0)
sys.exit(1)
