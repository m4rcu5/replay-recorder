# ZFM Replay Recorder

This script is used at the local radio ZFM Zandvoort to record live broadcast which should be replayed at a later date.

## Requirements

* `fmedia`: This is the recording software used by this script. [Link][1]
* `ToneDet`: Used to trigger the script from out automation. [Link][2]

[1]: http://fmedia.firmdev.com/
[2]: https://www.nch.com.au/action/misc.html

## Usage

The file `RecordDatabase.csv` contains the entries per day/hour. When the script `StartRecording.ps1` is triggered, it will look up the current day and hour in the database and start recording if found.
It will record until the next top of the hour, after which the successful recoding is written to the designated file.

## Configuration

Bitrate, file format and storage locations can be set at the top of the script.

```
# Variables
$fmediaDev  = 1
$fmediaExe  = 'fmedia.exe'
$recFormat  = 'mp3'
$recBitrate = 192
$recDir     = 'C:\Data\Opnames'
$database   = 'C:\Data\RecordDatabase.csv'
```

## Background

At ZFM we run an radio automation system called 'AIR2000'. At the early days of the implementation it used to trigger our recording machine using an ISA relay card. This was no longer supported when I migrated the machine to Windows 10.
To still be able to trigger recordings, the system now sends out a 35hz tone at the beginning of the hours that contain live broadcasts. This is picked up by `ToneDet`, which in turn executes the script contained in this repository to record the hour for later use.
