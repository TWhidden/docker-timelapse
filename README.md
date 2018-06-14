# Timelapse creator for Synology Surveillance Station

## Introduction

I use Synology Surveillance Station with a couple of IP cameras. Surveillance Station is configured to create a snaphot every 2 minutes on each of these cameras. These snapshots are used by this Docker image to create a timelapse when the day is over.

The fun thing is this way I have a (around 30 second long in my setup) timelapse of each day in the past. So what weather was it 3 weeks ago? Or just for fun :)

## Set-up Synology to create snapshots

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

## How to use this container

Use e.g. the Synology Cron (see next section) to run this container at any prefered moment.

```
docker run \
    --rm
    -v $HOME/input:/input \
    -v $HOME/output:/output \
    -v /etc/localtime:/etc/localtime:ro \
    erikdevries/timelapse \
    -p Xiaomi
    -d 1
    -f mp4
    -r 1920
```

In the above command a couple of things happen:
* `--rm` means the container is removed after it has run (otherwise each docker run will create, and keep a container)
* `-v [input]` mount a given `input` folder (e.g. /volume1/surveillance/@Snapshot)
* `-v [output]` mount a given `output` folder (where the created timelapse is stored)
* `-v /etc/localtime:/etc/localtime:ro` to make sure the time inside the Docker container is the same as on the host system
* `erikdevries/timelapse` is the name of the image (on Docker Hub, see https://hub.docker.com/r/erikdevries/timelapse/)
* `-p Xiaomi` is the **prefix** for the filenames used to create the timelapse (when prefix contains spaces put quotes around the name, e.g. "Foscam FI9831P")
* `-d 1` tells the application to create a timelapse with files from 1 **day** ago (optional, by default the current date is used, this is a number, so providing 14 means, create a timelapse with files from 2 weeks ago)
* `-f mp4` tells the application to output the timelapse in MP4 **format** (optional, mp4 by default, gif is the other option, which will output a optimized animated gif)
* `-r 1920` tell the application to **resize** the output to the given width (optional, 1280 by default, aspect ratio is preserved, for gif use something like 320 to keep the filesize down)

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
docker run --rm -v /etc/localtime:/etc/localtime:ro -v /volume1/surveillance/@Snapshot:/input -v /volume1/Video/Timelapse:/output erikdevries/timelapse -p Xiaomi -d 1
``

* Finally check that the timelapse is actually created (you can manually execute the created task)

## Additional tips

If you like to create timelapses for a range of X days in the past, you can use a simple bash script like the following. This example executes the command with 1 to 10 days in the past (so this results in several timelapses).

```
#!/bin/bash
for i in {1..10}
    do
        docker run --rm -v /etc/localtime:/etc/localtime:ro -v /volume1/surveillance/@Snapshot:/input -v /volume1/Video/Timelapse:/output erikdevries/timelapse -p Xiaomi -d $i
done
```