mediawiki-importer
==================

This parses the latest Wikipedia (or other media wiki) [XML dump](http://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pages-articles.xml.bz2)
and turns it into a file suitable for importing to a Directed Edge database.  It
also creates a file listing the redirects and can optionally push those to a
database.

Building
--------

You need to have [Qt](http://qt.nokia.com/) installed.  Qt comes with QMake,
which when run in the project directory will generate Makefiles, and XCode
project or a Visual Studio project depending on your platform and configuration.
You then build as you typically would on that platform.

e.g. for Linux:

    > cd mediawiki-importer
    > qmake
    > make

Running
-------

Once built you'll have an executable called MediawikiImporter.  Simply run that
with the file to import as the first parameter.  When done you'll have the files
mediawiki.xml and redirects.txt in your working directory.

If you want to avoid unzipping the (often huge) full wikimedia dump you can do
something like:

    > mkfifo mediawiki.xml
    > bzcat enwiki-latest.xml.bz2 > mediawiki.xml
    > ./MediawikiImporter mediawiki.xml

Now, since the importer reads the file in two passes, once the output freezes
you'll need to repeat:

    > bzcat enwiki-latest.xml.bz2 > mediawiki.xml

But that keeps you from needing to have 20 gb of freespace sitting around
for the import.

Copyright (c) 2008-2011 Directed Edge, released under the MIT license



