## EdgeHitFilter
Applying edge hit filter on scans read from a file.

### Description:
This sample shows how to apply an edge hit filter to scans read from file and
displays the filtered scan as a point cloud. A file scan provider is created and
and the scans from the file are played back. For every input scan the number of detected
edge hits is also printed to the console.

### How To Run:
Starting this sample is possible either by running the app (F5) or
debugging (F7+F10). Output is printed to the console and the transformed
point cloud can be seen on the viewer in the web page. The playback stops
after the last scan in the file. To replay, the sample must be restarted.
To run this sample, a device with AppEngine >= 2.5.0 is required.

### Implementation:
To run with real device data, the file provider has to be exchanged with the
appropriate scan provider.

### Topics
Algorithm, Scan, Filtering, Sample, SICK-AppSpace
