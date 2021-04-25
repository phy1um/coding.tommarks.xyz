PAGES="blog.html contact.html index.html projects.html thanks.html"
BLOG_FILES="src/blog/*.md"
BLOG_PREFIX="blog-"

python3 make-blog-index.py "$BLOG_PREFIX" $BLOG_FILES

for p in $PAGES; do
    echo "$p"
    ./make-page.sh "src/$p" > "http/$p"
done

./make-page.sh "src/tmp-blog-post.html" > "blog-template.html"

for p in $BLOG_FILES; do
    echo "$p"
    fn=$(basename -s .md $p)
    $PANDOC --template blog-template.html $p > "http/$BLOG_PREFIX$fn.html"
done
