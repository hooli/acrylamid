Commands
========

Unlike other popular static blog compiler Acrylamid uses a CLI interface that
uses positional arguments for each task. Long options are used for special
flags like force or dry run. The basic call is ``acrylamid <subcommand>
[options] [args]``.

Note that Acrylamid always will change to the directory containing the
``conf.py``. In addition Acrylamid will first look for a configuration
file in the current directory named ``conf.py`` and then in any folder
above.

-h, --help      show this help message and exit
-v, --verbose   more verbose
-q, --quiet     less verbose
-C, --no-color  disable color
--conf=FILE     alternate conf.py
--version       show program's version number and exit

Built-in Commands
*****************

new
---

With ``acrylamid new`` you specify a title in [args] or you'll get prompted to
enter a title and Acrylamid automatically create the post using the current
datetime and places the file into ``CONTENT_DIR`` (defaults to content/) using
``PERMALINK_FORMAT`` as path expansion. The filename extension used is the first
value specified in ``CONTENT_EXTENSION``. Afterwards it'll launch your favourite $EDITOR.

.. raw:: html

    <pre>
    $ acrylamid new
    Entry's title: This rocks!
    <span style="font-weight: bold; color: #00aa00">   create</span>  content/2012/this-rocks.txt
         [opens TextMate for me]
    </pre>


compile / generate
------------------

Compiles all your content using global, view and entry filters with some magic
and generates all files into ``OUTPUT_DIR`` (defaults to output/). Note that
this command will *not* remove orphaned files. Depending on your changes and
content size it may take some time.

.. code-block:: sh

    $ acrylamid [compile co generate gen] [-fin]

-f, --force     clear cache before compilation
-n, --dry-run   show what would have been compiled
--ignore        ignore critical errors (e.g. missing module used in a filter)
--search        build search index (if search view is enabled)

.. raw:: html

    <pre>
    $ acrylamid compile
      <span style="font-weight: bold; color: #aa5500">   update</span>  [0.03s] output/articles/index.html
      <span style="font-weight: bold; color: #000316">     skip</span>  output/2012/die-verwandlung/index.html
      <span style="font-weight: bold; color: #00aa00">   create</span>  [0.41s] output/2012/this-rocks/index.html
      <span style="font-weight: bold; color: #aa5500">   update</span>  [0.00s] output/index.html
      <span style="font-weight: bold; color: #000316">     skip</span>  output/tag/die-verwandlung/index.html
      <span style="font-weight: bold; color: #000316">     skip</span>  output/tag/franz-kafka/index.html
      <span style="font-weight: bold; color: #aa5500">   update</span>  [0.01s] output/atom/index.html
      <span style="font-weight: bold; color: #aa5500">   update</span>  [0.01s] output/rss/index.html
      <span style="font-weight: bold; color: #aa5500">   update</span>  [0.00s] output/sitemap.xml
    Blog compiled in 0.52s
    </pre>


view
----

After you compiled your blog you could ``cd output/ && python -m
SimpleHTTPServer`` to view the output, but this is rather exhausting. Its much
simpler to run ``acrylamid view`` and it automatically serves on port 8000.
Hit *Ctrl-C* to exit.

-p PORT, --port=PORT  webserver port

::

    $ acrylamid view -p 1234
     * Running on http://127.0.0.1:1234/


autocompile
-----------

If you need visual feedback while you write an entry, Acrylamid can
automatically compile and serve when you save your document. Hit *Ctrl-C* to
quit.

.. code-block:: sh

    $ acrylamid [autocompile aco] [-fip]

-f, --force           clear cache before compilation
-i, --ignore    ignore critical errors (e.g. missing module used in a filter)
-p PORT, --port=PORT  webserver port

.. raw:: html

    <pre>
    $ acrylamid aco
     * Running on http://127.0.0.1:8000/
    Blog compiled in 0.12s
     * [echo 1 >> content/sample-entry.txt]
      <span style="font-weight: bold; color: #aa5500">   update</span>  [0.32s] output/2011/die-verwandlung/index.html
      <span style="font-weight: bold; color: #aa5500">   update</span>  [0.02s] output/rss/index.html
      <span style="font-weight: bold; color: #aa5500">   update</span>  [0.01s] output/atom/index.html
    Blog compiled in 0.40s
    </pre>


import
------

Acrylamid features a basic RSS and Atom feed importer as well as a WordPress
dump importer to make it more easy to move to Acrylamid. To import a feed,
point to any URL or local FILE. By default, all HTML is reconversed to Markdown
using, first html2text_ if found then pandoc_ if found, otherwise it uses the
HTML. reStructuredText is also supported via html2rest_ and optionally by pandoc_.

The table below shows the current status for the supported import methods.

==============  ===  ====  =========
Feature         RSS  Atom  WordPress
==============  ===  ====  =========
posts           yes  yes   yes
pages           no   no    yes
drafts          no   no    yes
tags            no   yes   yes
repair HTML     n/a  n/a   yes
basic conf.py   yes  yes   yes
==============  ===  ====  =========

Migrating from WordPress is more difficult than an RSS/Atom feed because WP does
not store a valid HTML content but a pre-HTML state. Thus we fix this with some
stupid <br />-foo to allow conversion back to Markdown/reStructuredText. It is
not recommended to import WordPress blogs without any reconversion due to the
broken HTML.

.. _html2text: http://www.aaronsw.com/2002/html2text/
.. _html2rest: http://pypi.python.org/pypi/html2rest
.. _pandoc: http://johnmacfarlane.net/pandoc/

.. raw:: html

    <pre>
    $ acrylamid init .  # we need a base structure before we import

    $ acrylamid import http://example.com/rss/
      <span style="font-weight: bold; color: #00aa00">   create</span>  content/2012/entry.txt
      <span style="font-weight: bold; color: #00aa00">   create</span>  content/2012/another-entry.txt
         ...
    $ acrylamid import -k example.wordpress.xml
      <span style="font-weight: bold; color: #00aa00">   create</span>  content/dan/wordpress/2008/08/a-simple-post-with-text.txt
      <span style="font-weight: bold; color: #00aa00">   create</span>  content/dan/wordpress/news/our-company.txt
         ...
    </pre>

.. note::

    If you get a *critical  Entry already exists u'content/2012/update.txt'*,
    you may need to change your ``PERMALINK_FORMAT`` to a more fine-grained
    ``"/:year/:month/:day/:slug/index.html"`` import strategy. If you don't
    wish a re-layout of your entries, you can use ``--keep-links`` to use the
    permalink as path.

-f, --force         override existing entries, use with care!
-m FMT              reconversion of HTML to FMT, supports every language that
                    pandoc supports (if you have pandoc installed). Use "HTML"
                    if you don't wish any reconversion.
-k, --keep-links    keep original permanent-links and also create content
                    structure in that way. This does *not* work, if you links
                    are like this: ``/?p=23``.
-p, --pandoc        use pandoc first, then ``html2rest`` or ``html2text``
-a  ARG [ARG ...]   add arg to header section, such as ``-a "imported: True"``.


info
----

Shows information about your blog. It can print a short summary (default) or
shows you your current tag usage and coverage.

-2                a git-like digit to show the last N articles (default: 5)
                  during summary or 100 most used tags.
--coverage N      discover posts with uncommon tags

Summarize mode (gray items are drafts):

.. raw:: html

    <pre>
    $ acrylamid info -2
    acrylamid <span style="color: #0000aa">0.3.4</span>, cache size: <span style="color: #0000aa">1.24</span> mb

       <span style="color: #00aa00">13 hours ago</span> Linkschleuder #24
       <span style="color: #00aa00">14 hours ago</span> <span style="color: #888888">About Python Packages</span>

    <span style="color: #0000aa">157</span> published, <span style="color: #0000aa">2</span> drafted articles
    last compilation at <span style="color: #0000aa">01. June 2012, 10:41</span>
    </pre>

Tag usage and coverage:

.. code-block:: sh

    $ acrylamid info tags | head -n 2
    34 Python          4 Jena      2 TextMate         2 Open Source
    28 Links           4 V-Server  2 iOS              2 munin

    $ acrylamid info tags --coverage 1 | head -n 2
    Diaspora content/2012/diaspora.txt
    FreeBSD content/2012/abseits-von-linux-freebsd.txt


External Commands
*****************

The following commands are not part of the Acrylamid core but you may find them
already in your blog because you bootstrapped from the default theme. You'll
find the scripts in the *tasks/* directory in the root directory of your blog.
If not, `get a copy`_ (just wget them to the task directory) from GitHub.

.. _get a copy: https://github.com/posativ/default/blob/master/tasks/

.. _deploy:

deploy
------

.. note:: GitHub source: https://github.com/posativ/default/blob/master/tasks/deploy.py

With ``acrylamid deploy TASK`` you can run single commands, e.g. push just
generated content to your server. Write new tasks into the DEPLOYMENT dict
inside your ``conf.py`` and then you can invoke *ls*, *echo* and *deploy*
as TASK.

.. code-block:: sh

    $ acrylamid [deploy dp] [--list] TASK

.. code-block:: python

    DEPLOYMENT = {
        "ls": "ls $OUTPUT_DIR",
        "echo": "echo '$OUTPUT_DIR'",
        "default": "rsync -av --delete $OUTPUT_DIR www@server:~/blog.example.org/"
    }

The first task will print out a file listing from your output directory. The
command is pure shell, you could also use ``$HOME`` as variable. Most
configuration parameters are added to the execution environment. The second
task echoes the substitution parameter. The last task is might be a command to
deploy your blog directly to the server. If you don't supply TASK, Acrylamid
runs *default*.

.. raw:: html

    <pre>
    $ acrylamid deploy ls
    <span style="font-weight: bold; color: #000316">    execute</span> ls output/
    2009
    2010
    ...
    tag

    $ acrylamid dp echo
    <span style="font-weight: bold; color: #000316">    execute</span> echo '$OUTPUT_DIR'
    $OUTPUT_DIR

    $ acrylamid deploy blog
    <span style="font-weight: bold; color: #000316">    execute</span> rsync -av --delete output/ www@server:~/blog.example.org/
    building file list ... done

    sent 19701 bytes  received 20 bytes  7888.40 bytes/sec
    total size is 13017005  speedup is 660.06
    </pre>

It's also possible to pass additional commands to tasks. Every argument and
flag/option after the task identifier is passed to:

.. raw:: html

    <pre>
    $ acrylamid deploy ls -- content/ -d
    <span style="font-weight: bold; color: #000316">    execute</span> ls output/ content/ -d
    content/
    output/
    </pre>


ping
----

.. note:: GitHub source: https://github.com/posativ/default/blob/master/tasks/pingback.py

Send Pingbacks to other blogs (still experimental) with one command. Without
any arguments the newest article is submitted to any referenced url that
supports Pingback. As positional argument you can ping Twitter with your
article.

-h, --help            show this help message and exit
-a, --all             ping all entries (default: only the newest)
-p FILE               ping specific article
-n, --dry-run         show what would have been pingbacked
-j JOBS, --jobs JOBS  N parallel requests
-2                    a git-like digit to ping the last N articles. Defaults to the last one.

First we do a dry-run and look what blogs we may ping back:

::

    $ acrylamid ping --dry-run
    Pingback crypto.junod.info from blog.posativ.org/2012/linkschleuder-27/.

Now without ``--dry-run`` you actually ping that blog. Note that you may ping
a ressource several times without any drawback. That's part of the protocol to
handle that. After that we'll post your article to Twitter (note that you must
have ``twitter`` from PyPi installed):

::

    $ acrylamid ping twitter
    tweet  New Blog Entry: Linkschleuder #27
           http://blog.posativ.org/2012/linkschleuder-27/ #links
           #unix #html5 #javascript #planet

Of course, you must first allow Acrylamid to post tweets for you. From all
optional argumments above you can only use ``--all`` and ``-2`` to increase
the amount of pinged articles.


Custom Commands
***************

You can of course extend Acrylamid with custom commands. Just create -- if not
already there -- a *tasks/* directory in your blog root and add this little
hello world script:

.. code-block:: python

    # tasks/hello.py

    @task("hello", help="say hello")
    def hello(conf, env, options):

        print 'Hello, World.'

For documentation, refer to already existing tasks as there is currently no
public documentation available.
