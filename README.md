# Timelapse creator for Synology Surveillance Station

## Introduction
I set Surveillance Station to create a snaphot every 2 minutes. These snapshots are used by this Docker image to create a timelapse for the current day. So when you run this command each day at e.g. 23:59 you get a timelapse for the entire day.

To set-up Surveillance Station to automatically create snapshots, following these steps;
* Open `Action Rule`
* Press `Add` and name it something like `Timelapse`, set `Rule type` to `Triggered` and `Action type` to `Uninterruptable`
* Set the `interval` to 120 (seconds)
* Configure the event as follows (create one for each camera)
    * `Event source` -> Camera
    * `Device` -> Pick a camera
    * `Event` -> Connection normal
    * `Trigger type` -> Constant
* Configure the action as follows
    * `Action device` -> Camera
    * `Device` -> Pick a camera
    * `Action` -> Take snapshots
    * `Times` -> 1
* Configure the schedule as desired
* Check `Snapshot` to see the snapshots are actually created

## How to use

Use e.g. the Synology Cron to run this container at any prefered moment.

```
docker run \
    -v $HOME/input:/input \
    -v $HOME/output:/output \
    timelapse \
    Xiaomi
```

In the above command a couple of things happen:
* Mount a given `input` folder (e.g. /volume1/surveillance/@Snapshot)
* Mount a given `output` folder (where the create mp4 is stored)
* `timelapse` is the name of the image
* `Xiaomi` is the prefix for the filenames used to create the timelapse

This Docker image assumes the following files exist: /input/[prefix]-[currentdate]-*.jpg

E.g. When prefix "Xiaomi" is provided, and the current year is 2018, month is march, day is 23, the following files should exist: /input/Xiaomi-20180323-[numbers].jpg