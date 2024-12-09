PAGES="contact.md index.md projects.md thanks.md patreon.md tutoring.md"
PROJECT_FOLDER="src/project" 
BLOG_FILES="src/blog/*.md"
BLOG_PREFIX="blog-"
BLOG_TEMPLATE="blog-template.html"

PATH_FAILED=0

function test_in_path {
    echo " ------------- "
    echo "   Locating $1..."
    which $1 > /dev/null 2>&1
    if [ $? == 0 ]; then
        echo "    Found $1 @ $(which $1)"
        vstr=$($1 $2 | head -n 1)
        echo "    Version: $vstr"
    else
        echo " /!\\ NOT FOUND /!\\"
        PATH_FAILED=1
    fi

}

function log_init_status {
    echo "=== BUILDING SITE ==="
    echo " DEPLOYING TO: $URL"
    echo " > source: $REPOSITORY_URL"
    echo " > branch: $BRANCH"
    echo " > commit: $COMMIT_REF"
    test_in_path "python3" "--version"
    test_in_path "pandoc" "-v"
}

function make_page {
    cat "src/tmp-header.html" "$1" "src/tmp-footer.html"
}

if [ -z $PANDOC ]; then
    PANDOC="pandoc"
fi

log_init_status
if [ $PATH_FAILED == 1 ]; then
  echo "FATAL: Could not find required tools in path"
  exit 1
fi

echo
echo
echo " === Building Blog Index === "
echo "   Blog posts found: $BLOG_FILES"
python3 make-blog-index.py "$BLOG_PREFIX" $BLOG_FILES

echo
echo " === Making Main Pages === "

for p in $PAGES; do
    base=$(basename $p .md)
    tgt="$base.html"
    echo " > Pandoc $p -> $tgt"
    pandoc -f markdown+footnotes -t html "src/$p" > "src/$tgt"
    echo " > Building page: $tgt"
    make_page "src/$tgt" > "http/$tgt"
    rm -f "src/$tgt"
done

echo " === Vendoring Project Docs (TomVM) ==="
git clone https://github.com/phy1um/rust-simple-vm vendor-tomvm
mkdir "${PROJECT_FOLDER}/tomvm"
cp -r vendor-tomvm/docs/html/* "${PROJECT_FOLDER}/tomvm"

echo " === Copying Projects (static pages) ==="
cp -r ${PROJECT_FOLDER} "http"


echo " > Building page: blog.html"
make_page "src/blog.html" > "http/blog.html"

echo
echo " === Making Blog === "

make_page "src/tmp-blog-post.html" > "$BLOG_TEMPLATE"

for p in $BLOG_FILES; do
    echo " > Building blog post: $p"
    fn=$(basename -s .md $p)
    $PANDOC --template "$BLOG_TEMPLATE" $p > "http/$BLOG_PREFIX$fn.html"
done

echo "=== Building notes === "
cd notes && bash build.sh ../http/notes.txt

echo
echo
echo " =========="
