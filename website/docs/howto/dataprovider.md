---
sidebar_position: 5
id: dataprovider
title: Accessing Sensor Data
---

# Accessing Project Aria Sensor Data
## Introduction

The Project Aria Data Provider provides a customized way to retrieve and read data from [VRS](aria-vrs.md
) files in an intuitive and effective way.

Project Aria data can also be loaded by reading VRS files directly, using [VRS tools](https://facebookresearch.github.io/vrs/) or other tools that leverage VRS APIs. This page contains instructions for the most common uses of Project Aria Data Provider and then describes how we have used VRS.

## Instructions

Use the following commands in Python3 to retrieve and read sensor data from VRS.

### 1. Create an Aria Data Provider instance

```
>>> import pyark.datatools as datatools
>>> vrs_data_provider = datatools.dataprovider.AriaVrsDataProvider()
```

### 2. Select your VRS file

Enter the name (and path if you are in a different directory) for the VRS file you wish to read. Here it is represented as ‘recording.vrs’.

```
vrs_data_provider.openFile(‘recording.vrs’)
```

### 3. Set which sensor data the Project Aria Data Provider should read

#### By high-level API

Use `vrs_data_provider` to set which sensor stream/s the Aria Data Provider should read. The available sensor stream is constructed by `set`*`<streamType>`*`Player`

* See [Sensors and Measurements](sensors-measurements.md) for a list of all the stream types.

This example is for SLAM left camera:

```
vrs_data_provider.setSlamLeftCameraPlayer()
```

#### Or by StreamId

Use the following commands if you wish to set this directly using the VRS [StreamId](https://github.com/facebookresearch/vrs/tree/main/vrs).

```
>>> slam_camera_recordable_type_id = 1201
>>> slam_left_camera_instance_id = 1
>>> slam_left_camera_stream_id = datatools.dataprovider.StreamId(slam_camera_recordable_type_id, slam_left_camera_instance_id)
>>> vrs_data_provider.setStreamPlayer(slam_left_camera_stream_id)
```

### 4.  Set whether to print data layouts (optional)

By default data layouts are not printed while reading records. Set the verbosity to True to print data layouts and False to not print data layouts:

```
vrs_data_provider.setVerbose(True)
```

### 5. Read the data stream

All records in timestamp order:

```
>>> vrs_data_provider.readAllRecords()
4822.486 Camera Data (SLAM) #1 [1201-1]: jpg, 44338 bytes. # JPEG compressed image data size before decompression
...
4832.286 Camera Data (SLAM) #1 [1201-1]: jpg, 64148 bytes.
4832.386 Camera Data (SLAM) #1 [1201-1]: jpg, 64174 bytes.
```

Read a single data record by timestamp:

```
vrs_data_provider.readDataRecordByTime(slam_left_camera_stream_id, someTimestamp)
```

You can also use a higher level API that reads a data record in a specific stream and proceeds next timestamp in the player internally.

```
vrs_data_provider.tryFetchNextData(slam_left_camera_stream_id)
```

### 6. Access the data stream

Once you’ve read and stored records in the players. All streams have configuration and data records.

You can access:

* `getConfigRecord()` -  one per stream.
* `getDataRecord()` - All streams use data records to store information
* `getData()` - Audio and image streams only. This accesses data from content blocks that contain raw image and audio data

To find out what is in a configuration or data record, go to [vrs/vrs/oss/aria](https://github.com/facebookresearch/vrs/tree/main/vrs/oss/aria). These definitions provide an overview of what information can be extracted for each stream from a Project Aria sequence.

In this example, one SLAM left camera data record is accessed. What is read is defined by the records loaded when setting how to read the data stream.

```
>>> slam_left_camera_player = vrs_data_provider.getSlamLeftCameraPlayer()
>>> slam_left_camera_data_record = slam_left_camera_player.getDataRecord()
>>> slam_left_camera_data_record.captureTimestampNs
 4832385508212
```

In this example  `getData()`  is used to get raw SLAM left camera data. Raw data is compressed into JPG formatting when it is read by the Aria visualization tool.

```
>>> slam_left_camera_data = slam_left_camera_player.getData()
>>> pixel_frame = slam_left_camera_data.pixelFrame
>>> buffer = pixel_frame.getBuffer()
>>> len(buffer)
307200 # JPEG image data decompressed internally in AriaImageSensorPlayer
# equal to SLAM camera image width (640) * image height(480)
```

In this example, `getConfigRecord()` is used to read the configuration records for the SLAM left Camera.

```
vrs_data_provider.readFirstConfigurationRecord(slam_left_camera_stream_id)
```

### 7. Loading device model

There are calibration strings for each image and motion stream. Reading the configuration record for any one of them will load the device model. Load the device model:

```
>>> slam_left_camera_stream_id = slam_left_camera_player.getStreamId()
>>> slam_left_camera_stream_id
<pyark.datatools.dataprovider.StreamId object at 0x7f955808c270>
>>> vrs_data_provider.readFirstConfigurationRecord(slam_left_camera_stream_id)
True
>>> vrs_data_provider.loadDeviceModel()
True
>>> device_model = vrs_data_provider.getDeviceModel()
>>> device_model
<pyark.datatools.sensors.DeviceModel object at 0x7f955808c2b0>
```

Then a 3D point from one sensor coordinate system can be transformed into another with:

```
>>> import numpy as np
>>> p_slamLeft = np.array([3.0, 2.0, 1.0])
>>> p_imuRight = device_model.transform(p_slamLeft, 'camera-slam-left', 'imu-right')
>>> p_imuRight
array([ 3.32648252, -1.50695095, 1.10720445])
```

To find out more about Calibration go to [Using Project Aria Calibration Sensor Data](calibration.md)

## How the Project Aria Data Provider works

The Project Aria Data Provider uses  `RecordFileReader` and `StreamPlayer` classes to retrieve and read data from VRS files in an intuitive and effective way.

Through the Project Aria Data Provider, a player is implemented for every Project Aria data stream. This player allows VRS configuration and data records to be stored and retrieved. The configuration and data record structure contents in each player are defined by the Project Aria `DataLayout` definitions.

Project Aria VRS data provider class exposes the functionality needed to read and access Project Aria data intuitively. It enables:

* Project Aria players to be configured correctly (see below)
* Retrieving players and accessing their latest content, and handling the VRS operations required for all these actions internally.
* Utilizing the power of VRS tools for reading records via `RecordFileReader` wrapper functions.

## How Project Aria players are configured

So that data layouts of a stream can be read, a `RecordFileStreamPlayer` instance for it has to be set in `RecordFileReader`. Using custom classes for each stream type that inherit `RecordFileStreamPlayer` allows reading configuration/data records in the VRS file by overriding `RecordFileStreamPlayer::onDataLayoutRead` function. Project Aria players that follow this pattern are open sourced under `src/dataprovider/players`.

Each player header file contains configuration and data record structure definitions, matching their stream data layout definitions. There are getter methods in the player classes to retrieve these records.

## Project Aria `DataLayout` definitions

DataLayout definitions of the metadata blocks in Project Aria VRS files are open sourced under [vrs/vrs/oss/aria](https://github.com/facebookresearch/vrs/tree/main/vrs/oss/aria). These definitions provide an overview of what information can be extracted for each stream from a Project Aria sequence.
