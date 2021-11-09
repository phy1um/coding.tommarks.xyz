import datetime

def toRCF822(time):
    return time.strftime("%a, %d %b %Y %H:%M:%S GMT")

def tagOpen(name):
    return f"<{name}>"

def tagClose(name):
    return f"</{name}>"

def tagLine(name, content):
    return "".join([tagOpen(name), content, tagClose(name)])

class Item(object):
    def __init__(self, title, link, desc, time):
        self.title = title
        self.link = link
        self.desc = desc
        self.time = time

    def render(self):
        return "\n".join([
            tagOpen("item"),
                tagLine("title", self.title),
                tagLine("link", self.link),
                tagLine("guid", self.link),
                tagLine("description", self.desc),
                tagLine("pubDate", self.time),
            tagClose("item")])


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

    def addItem(self, title, link, desc, at):
        self.items.append(Item(title, self.link + link, desc, at))

    def render(self):
        return "\n".join([
            tagOpen("channel"),
                tagLine("title", self.title),
                tagLine("link", self.link),
                tagLine("description", self.desc),
                tagLine("language", "en-us"),
                tagLine("copyright", f"Copyright {self.yearStart} - {self.yearEnd} {self.owner}"),
                tagLine("generator", "https://github.com/phy1um/coding.tommarks.xyz -- rss.py"),
                tagLine("managingEditor", f"{self.email} {self.owner}"),
                tagLine("webMaster", f"{self.email} {self.owner}"),
                tagLine("ttl", "40"),
                "".join([i.render() for i in self.items]),
            tagClose("channel")])

def render_feed(channel):
    return f"<rss version=\"2.0\">\n{channel.render()}\n</rss>\n"

if __name__ == "__main__":
    c = Channel("Test Blog", "localhost:8000", "foobar this is a blog", "Tom Marks", "2020", "coding@tommarks.xyz")
    c.addItem("Post 1", "/some-post.html", "description of post 1", "Mon, 01 Jan 2020 10:01:10")
    c.addItem("Post 2", "/some-post.html", "description of post 2", "Mon, 02 Jan 2020 20:02:20")
    print(f"<rss version=\"2.0\">{c.render()}</rss>")

