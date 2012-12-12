Test (incremental) compilation.

  $ [ -n "$PYTHON" ] || PYTHON="`which python`"
  $ LANG="en_US.UTF-8" && unset LC_ALL && unset LANGUAGE
  $ acrylamid init -q $TMPDIR
  $ cd $TMPDIR

... (already tested in compile.t)

  $ acrylamid compile -Cq
  $ acrylamid new -q Spam
  $ acrylamid compile -q

Removal of an article should trigger the next and previous posts.

  $ rm content/2012/spam.txt
  $ acrylamid compile -C
  update  [?.??s] output/articles/index.html (glob)
  update  [?.??s] output/2012/die-verwandlung/index.html (glob)
  update  [?.??s] output/index.html (glob)
  update  [?.??s] output/atom/index.html (glob)
  update  [?.??s] output/rss/index.html (glob)
  update  [?.??s] output/sitemap.xml (glob)
  0 new, 6 updated, 3 skipped [?.??s] (glob)

Generate a bunch of posts to play with (not particular useful though).

  $ for i in $(seq 10 30); do
  >   acrylamid new -q "Spam $i";
  > done
  $ acrylamid compile -q

Now remove a post somewhere in between and test that only the affected
pages re-compile.

  $ rm content/2012/spam-23.txt
  $ acrylamid compile -C
  update  [?.??s] output/articles/index.html (glob)
  update  [?.??s] output/2012/spam-22/index.html (glob)
  update  [?.??s] output/2012/spam-24/index.html (glob)
  update  [?.??s] output/page/2/index.html (glob)
  update  [?.??s] output/page/3/index.html (glob)
  update  [?.??s] output/atom/index.html (glob)
  update  [?.??s] output/rss/index.html (glob)
  update  [?.??s] output/sitemap.xml (glob)
  0 new, 8 updated, 23 skipped [?.??s] (glob)

Same as above but create a new post. Unlike above also list identical
files (should be nearly the same as above).

  $ cat > content/tag.txt << EOF
  > ---
  > title: Test
  > date: 2012/12/21
  > tags: [Foo, Bar]
  > ---
  > EOF
  $ acrylamid compile -Cv
  update  [?.??s] output/articles/index.html (glob)
  create  [?.??s] output/2012/test/index.html (glob)
  update  [?.??s] output/2012/spam-10/index.html (glob)
  identical  output/2012/spam-11/index.html
  identical  output/2012/spam-12/index.html
  identical  output/2012/spam-13/index.html
  identical  output/2012/spam-14/index.html
  identical  output/2012/spam-15/index.html
  identical  output/2012/spam-16/index.html
  identical  output/2012/spam-17/index.html
  identical  output/2012/spam-18/index.html
  identical  output/2012/spam-19/index.html
  identical  output/2012/spam-20/index.html
  identical  output/2012/spam-21/index.html
  identical  output/2012/spam-22/index.html
  identical  output/2012/spam-24/index.html
  identical  output/2012/spam-25/index.html
  identical  output/2012/spam-26/index.html
  identical  output/2012/spam-27/index.html
  identical  output/2012/spam-28/index.html
  identical  output/2012/spam-29/index.html
  identical  output/2012/spam-30/index.html
  identical  output/2012/die-verwandlung/index.html
  update  [?.??s] output/index.html (glob)
  update  [?.??s] output/page/2/index.html (glob)
  update  [?.??s] output/page/3/index.html (glob)
  identical  output/tag/die-verwandlung/index.html
  create  [?.??s] output/tag/bar/index.html (glob)
  create  [?.??s] output/tag/foo/index.html (glob)
  identical  output/tag/franz-kafka/index.html
  update  [?.??s] output/atom/index.html (glob)
  update  [?.??s] output/rss/index.html (glob)
  update  [?.??s] output/sitemap.xml (glob)
  skip  output/style.css
  3 new, 8 updated, 23 skipped [?.??s] (glob)

Clean up everything.

  $ rm -rf output/ theme/ content/ .cache/ conf.py
