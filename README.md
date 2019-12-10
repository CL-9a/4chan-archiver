A set of scripts to archive threads from 4chan / 4channel, using the [site's API](https://github.com/4chan/4chan-API/). Format based on [BASC-archiver](https://basc-archiver.readthedocs.io/en/stable/documents/chan.zip-standard/). The reason for archiving 4chan are explained in BASC-archiver's docs. I plan on using it to feed some computer brain projects at some point.

By default, saves data in an `./archives` folder. You can edit this in the first lines of `archive.sh`. `Last-Modified` dates from the API are stored in `./_sharchiverLastModified`.

Threads stored as archived aren't re-downloaded, so if you interrupted the script while it was downloading a thread's files and want it to finish that, you should delete the `<threadId>.json` and `curlheaders.txt` file.

```
sh archivethearchive.sh diy
sh archivewholeboard.sh diy
sh archivepage.sh diy 1
sh archiveUntilArchived.sh someThreadId
```


I'm not sure how I feel about having the json's stored as `<threadId>.json` vs `thread.json`. I might change that in the future, and add scripts to rename from one to the other.


It uses (jq)[https://stedolan.github.io/jq/].
