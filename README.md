# Expectations

This application expects you to have books on `fiction` and `non-fiction`
shelves, at least. It also defaults to analyzing a `read-2014` shelf, but you
can override that.

# Usage

First, [export your books](https://www.goodreads.com/review/import) from
GoodReads and make a note of the location and name of the export file.

Then, run the following:

```
$ ruby transformer [export file] [shelf to analyze]
$ python -m SimpleHTTPServer 8000 &
$ open http://localhost:8000
```
