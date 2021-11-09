import datetime

def toRCF822(time):
    return time.strftime("%a, %d %b %Y %H:%M:%S GMT")

def tag_open(name):
    return f"<{name}>"

def tag_close(name):
    return f"</{name}>"

def tag_line(name, content):
    return "".join([tag_open(name), content, tag_close(name)])

class Item(object):
    def __init__(self, title, link, desc, time):
        self.title = title
        self.link = link
        self.desc = desc
        self.time = time

    def render(self):
        return "\n".join([
            tag_open("item"),
                tag_line("title", self.title),
                tag_line("link", self.link),
                tag_line("guid", self.link),
                tag_line("description", self.desc),
                tag_line("pubDate", self.time),
            tag_close("item")])


class Channel(object):
    def __init__(self, title, link, desc, owner, yearStart, email):
        self.title = title
        self.link = link
        self.desc = desc
        self.owner = owner
        self.yearStart = yearStart
        self.email = email
        self.yearEnd = datetime.datetime.now().year
        self.items = []

    def add_item(self, title, link, desc, at):
        self.items.append(Item(title, self.link + link, desc, at))

    def render(self):
        return "\n".join([
            tag_open("channel"),
                tag_line("title", self.title),
                tag_line("link", self.link),
                tag_line("description", self.desc),
                tag_line("language", "en-us"),
                tag_line("copyright", f"Copyright {self.yearStart} - {self.yearEnd} {self.owner}"),
                tag_line("generator", "https://github.com/phy1um/coding.tommarks.xyz -- rss.py"),
                tag_line("managingEditor", f"{self.email} {self.owner}"),
                tag_line("webMaster", f"{self.email} {self.owner}"),
                tag_line("ttl", "40"),
                "".join([i.render() for i in self.items]),
            tag_close("channel")])

def render_feed(channel):
    return f"<rss version=\"2.0\">\n{channel.render()}\n</rss>\n"

if __name__ == "__main__":
    c = Channel("Test Blog", "localhost:8000", "foobar this is a blog", "Tom Marks", "2020", "coding@tommarks.xyz")
    c.add_item("Post 1", "/some-post.html", "description of post 1", "Mon, 01 Jan 2020 10:01:10")
    c.add_item("Post 2", "/some-post.html", "description of post 2", "Mon, 02 Jan 2020 20:02:20")
    print(render_feed(c))

