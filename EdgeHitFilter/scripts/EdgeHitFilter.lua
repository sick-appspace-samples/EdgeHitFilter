--[[----------------------------------------------------------------------------

  Application Name: 
  EdgeHitFilter
  
  Summary: 
  Applying edge hit filter on scans read from a file
  
  Description:  
  This sample shows how to apply an edge hit filter to scans read from file and 
  displays the filtered scan as a point cloud. A file scan provider is created and 
  and the scans from the file are played back. For every input scan the number of detected 
  edge hits is also printed to the console.
  
  How to run:
  Starting this sample is possible either by running the app (F5) or 
  debugging (F7+F10). Output is printed to the console and the transformed 
  point cloud can be seen on the viewer in the web page. The playback stops 
  after the last scan in the file. To replay, the sample must be restarted.
  To run this sample, a device with AppEngine >= 2.5.0 is required.
  
  Implementation: 
  To run with real device data, the file provider has to be exchanged with the 
  appropriate scan provider. 
  
------------------------------------------------------------------------------]]

--Start of Global Scope--------------------------------------------------------- 
local counter = 0
local SCAN_FILE_PATH = "resources/TestScenario.xml"
print("Input File: ", SCAN_FILE_PATH)

--------------------------------------------------------------------------------
-- Check device capabilities
assert(View,"View not available, check capability of connected device")
assert(Scan,"Scan not available, check capability of connected device")
assert(Scan.Transform,"Transform not available, check capability of connected device")
assert(Scan.EdgeHitFilter,"EdgeHitFilter not available, check capability of connected device")

-- Create a viewer instance
viewer = View.create()
assert(viewer,"Error: View could not be created.")
viewer:setID("viewer3D")

-- Create a transform instance to convert the Scan to a PointCloud
transform = Scan.Transform.create()
assert(transform,"Error: Transform could not be created.")

-- Create the filter
edgeHitFilter = Scan.EdgeHitFilter.create()
assert(edgeHitFilter,"Error: EdgeHitFilter could not be created")
Scan.EdgeHitFilter.setMaxDistNeighbor(edgeHitFilter, 30)
Scan.EdgeHitFilter.setEnabled(edgeHitFilter, true)
  
-- Create provider. Providing starts automatically with the register call
-- which is found below the callback function
provider = Scan.Provider.File.create()
assert(provider,"Error: Scan provider could not be created.")

-- Set the file path
Scan.Provider.File.setFile(provider, SCAN_FILE_PATH)

-- Set the DataSet of the recorded data which should be used.
Scan.Provider.File.setDataSetID(provider, 1)

--End of Global Scope----------------------------------------------------------- 

--Start of Function and Event Scope---------------------------------------------

--------------------------------------------------------------------------------
-- Compares the distances of two scans of the specified echo
--------------------------------------------------------------------------------
function compareScans(inputScan, filteredScan, iEcho, printDetails)
  
  -- get the beam and echo counts
  local beamCountInput = Scan.getBeamCount(inputScan)
  local echoCountInput = Scan.getEchoCount(inputScan)
  local beamCountFiltered = Scan.getBeamCount(filteredScan)
  local echoCountFiltered = Scan.getEchoCount(filteredScan)
  
  local count = 0
  
  -- Checks
  if ( iEcho <= echoCountInput and iEcho <= echoCountFiltered ) then
    if ( beamCountInput == beamCountFiltered ) then
      -- Print beams with different distances
      if ( printDetails ) then
        print("The following beams have different distance values:")
      end
      local inputDistance = Scan.toVector(inputScan, "DISTANCE", iEcho-1)
      local filteredDistance = Scan.toVector(filteredScan, "DISTANCE", iEcho-1)
      for iBeam=1, beamCountInput do
        local d1 = inputDistance[iBeam]
        local d2 = filteredDistance[iBeam]
        if ( math.abs(d1-d2) > 0.01 ) then
          if ( printDetails ) then
            print(string.format("  beam %4d:  %10.2f -->  %10.2f", iBeam, d1, d2))
          end
          count = count + 1
        end
      end
    end
  end
  return count
end

-- Callback function to process new scans
function handleNewScan(scan)
  counter = counter + 1
  
  -- Clone input scan
  inputScan = Scan.clone(scan)
  
  -- Filter edge hits; the input scan if modified in place
  filteredScan = Scan.EdgeHitFilter.filter(edgeHitFilter, scan)
  
  -- and show the changed distances of echo #1
  local hits = 0
  if ( inputScan ~= nil ) then
    hits = compareScans(inputScan, filteredScan, 1, false)
    print(DateTime.getTime(), string.format("Scan %6d: EdgeHits = %d", counter, hits))
  end
  
  -- Transform to PointCloud to view in the PointCloud viewer on the webpage
  if nil ~= Scan.Transform then
    local pointCloud = Scan.Transform.transformToPointCloud(transform, filteredScan)
    View.add(viewer, pointCloud)
    View.present(viewer)
  end
end
-- Register callback function to "OnNewScan" event. 
-- This call also starts the playback of scans
Scan.Provider.File.register(provider, "OnNewScan", handleNewScan)

--End of Function and Event Scope------------------------------------------------