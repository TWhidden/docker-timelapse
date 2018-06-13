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
    --rm
    -v $HOME/input:/input \
    -v $HOME/output:/output \
    erikdevries/timelapse \
    Xiaomi
    1
```

In the above command a couple of things happen:
* `--rm` means the container is removed after it has run (otherwise each docker run will create, and keep a container)
* Mount a given `input` folder (e.g. /volume1/surveillance/@Snapshot)
* Mount a given `output` folder (where the create mp4 is stored)
* `timelapse` is the name of the image
* `Xiaomi` is the prefix for the filenames used to create the timelapse
* `1` tells the application to create a timelapse with files from 1 day ago (this argument is optional, by default the current date is used, this is an number, so providing 14 means, create a timelapse with files from 2 weeks ago)

This Docker image assumes the following files exist: /input/[prefix]-[currentdate]-*.jpg

E.g. When prefix "Xiaomi" is provided, and the current year is 2018, month is march, day is 23, the following files should exist: /input/Xiaomi-20180323-[numbers].jpg

## Setup cronjob on Synology

* Open `Task Scheduler`
* Create a new task
    * `Task` -> Create Timelapse
    * `User` -> root (not prefered, but by default Synology does not allow other users to run Docker)
    * `Schedule` -> I use 00:05 to create a timelapse from the entire day before
    * `Run command` -> See the command below as an example

``
docker run --rm -v /volume1/surveillance/@Snapshot:/input -v /volume1/Video/Timelapse:/output erikdevries/timelapse Xiaomi 1
``

* Finally check that the timelapse is actually created (you can manually execute the created task)