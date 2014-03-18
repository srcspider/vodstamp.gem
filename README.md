**vodstamp** is a vod timestamping helper

This tool is designed to help you create timestamps for videos based on
data you colect while making the video.

## Installing

```bash
gem install vodstamp
```

*You may need to have the ruby dev tools for some dependencies.*

## Sample configuration

You'll need a splits file, like the following. You would get the split file by
recording all the video times of the split up recorded file.

It's generally a good idea to record the start time of recording to make syncing
up with the video start time of the first video easier. You can kind of guess it
though any milestones you set. Like if at some point theres a scene with a
number that doesnt reach very often (such as a timer ingame) you can just record
that and get a pretty accurate milestone.

```text
01. 00:27:10
02. 00:28:10
03. 00:25:43
04. 00:23:33
05. 00:30:51
06. 00:30:38
07. 00:29:53
08. 00:32:22
09. 00:28:52
10. 00:29:52
11. 00:29:53
12. 00:31:07
13. 00:28:08
14. 00:33:07
15. 00:34:07
```

And a chat log, or any other kind of log, in the following format:

```text
Mar 17 18:48:44 <source> [timestamp] T-00:10 tree
```

The date part is not used, the hour, minute and seconds is. The source is
mandatory. Everything after the source is what in a normal chat log would be
the message. You have to start with [timestamp] then specify a time difference
to record; since if it's happening live you actually want timestamp to be
something like 10s earlier, which in this case is T-00:10. Everything past the
time offset is the timestamp message.