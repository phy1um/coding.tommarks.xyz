import sys
target="src/blog.html"

def read_fm(f):
    with open(f, "r") as fi:
        lines = []
        rd = fi.readline().strip()
        if rd != "---":
            raise Exception("Markdown file does not contain frontmatter. \nExpected \"---\", got: \"", rd, "\"")
        for line in fi:
            stripped = line.strip()
            if stripped == "...":
                return lines
            lines.append(stripped)
        raise Exception("Markdown frontmatter never terminated")

def parse_fm(l):
    res = {}
    for line in l:
        if len(line) == 0:
            continue
        if ":" not in line:
            raise Exception("Invalid frontmatter line: " + line)
        pts = line.split(":")
        res[pts[0].strip()] = pts[1].strip()
    return res

posts = []
for tgt in sys.argv[2:]:
    print("Processing",tgt)
    fm_lines = read_fm(tgt)
    fields = parse_fm(fm_lines)
    fields["path"] = tgt
    posts.append(fields)

blog_prefix = sys.argv[1]
with open(target, "w") as f:
    f.write("<section><h1>Blog Index</h1></section><section><ul>")
    for post in sorted(posts, key=lambda x: x["date"], reverse=True):
        path_t = post['path'].split("/")[-1]
        name = path_t.split(".")[0]
        prefixed_name = blog_prefix + name + ".html"
        f.write("".join(["<li>(",post['date'],") <a href='",prefixed_name,"'>",post['title'],"</a></li>"]))
    f.write("</ul></section>")

