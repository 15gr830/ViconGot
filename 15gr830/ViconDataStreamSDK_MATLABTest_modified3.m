% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright (C) OMG Plc 2009.
% All rights reserved.  This software is protected by copyright
% law and international treaties.  No part of this software / document
% may be reproduced or distributed in any form or by any means,
% whether transiently or incidentally to some other use of this software,
% without the written permission of the copyright owner.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part of the Vicon DataStream SDK for MATLAB.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Costume hax by group: 731 (Search for XXX to find added code:)
close all; clc;

if (~exist('testcnt'))
    testcnt = input('Test number?');
end

disp(['Press enter to start']);
pause;

while(1)
%%
N = 6000; % Maximum amount of saved samples
nMarker = 20;
markerPos = zeros(nMarker,3,N);
frameNr = zeros(1,N);
i = 1;
%%
disp(['Starting test ' num2str(testcnt,'%03d')]);


% Program options
TransmitMulticast = false;

% A dialog to stop the loop
MessageBox = msgbox( 'Stop DataStream Client', 'Vicon DataStream SDK' );

% Load the SDK
%fprintf( 'Loading SDK...' );
Client.LoadViconDataStreamSDK();
%fprintf( 'done\n' );

% Program options
HostName = 'localhost:801';

% Make a new client
MyClient = Client();

% Connect to a server
%fprintf( 'Connecting to %s ...', HostName );
while ~MyClient.IsConnected().Connected
  % Direct connection
  MyClient.Connect( HostName );
   
  fprintf( '.' );
end
fprintf( '\n' );

% Enable some different data types
MyClient.EnableSegmentData();
MyClient.EnableMarkerData();
MyClient.EnableUnlabeledMarkerData();
MyClient.EnableDeviceData();

%fprintf( 'Segment Data Enabled: %d\n',          MyClient.IsSegmentDataEnabled().Enabled );
%fprintf( 'Marker Data Enabled: %d\n',           MyClient.IsMarkerDataEnabled().Enabled );
%fprintf( 'Unlabeled Marker Data Enabled: %d\n', MyClient.IsUnlabeledMarkerDataEnabled().Enabled );
%fprintf( 'Device Data Enabled: %d\n',           MyClient.IsDeviceDataEnabled().Enabled );

% Set the streaming mode
MyClient.SetStreamMode( StreamMode.ClientPull );
% MyClient.SetStreamMode( StreamMode.ClientPullPreFetch );
% MyClient.SetStreamMode( StreamMode.ServerPush );

% Set the global up axis
MyClient.SetAxisMapping( Direction.Forward, ...
                         Direction.Left,    ...
                         Direction.Up );    % Z-up

Output_GetAxisMapping = MyClient.GetAxisMapping();
fprintf( 'Axis Mapping: X-%s Y-%s Z-%s\n', Output_GetAxisMapping.XAxis.ToString(), ...
                                           Output_GetAxisMapping.YAxis.ToString(), ...
                                           Output_GetAxisMapping.ZAxis.ToString() );
 
if TransmitMulticast
  MyClient.StartTransmittingMulticast( 'localhost', '224.0.0.0' );
end  
  
% Loop until the message box is dismissed
while ishandle( MessageBox )
  drawnow;
    
  % Get a frame
  %fprintf( 'Waiting for new frame...' );
  while MyClient.GetFrame().Result.Value ~= Result.Success
    fprintf( '.' );
  end% while

  % Get the frame nplumber
  Output_GetFrameNumber = MyClient.GetFrameNumber();
  frameNr(i) = Output_GetFrameNumber.FrameNumber; 

  % Get the unlabeled markers 
  UnlabeledMarkerCount = MyClient.GetUnlabeledMarkerCount().MarkerCount;
  for UnlabeledMarkerIndex = 1:min(UnlabeledMarkerCount,nMarker);   % save max nMarker markers
    % Get the global marker translation
    Output_GetUnlabeledMarkerGlobalTranslation = MyClient.GetUnlabeledMarkerGlobalTranslation( UnlabeledMarkerIndex );   
    
    markerPos(UnlabeledMarkerIndex,1:3,i) = [   Output_GetUnlabeledMarkerGlobalTranslation.Translation( 1 ) ...
                                                Output_GetUnlabeledMarkerGlobalTranslation.Translation( 2 ) ...
                                                Output_GetUnlabeledMarkerGlobalTranslation.Translation( 3 )];    
  end% UnlabeledMarkerIndex
  
  i = i+1;
  
  if mod(i,100) == 0
      fprintf('Frame number: %d received  , marker count: %d \n',i, UnlabeledMarkerCount);
  end
    
end% while true  

if TransmitMulticast
  MyClient.StopTransmittingMulticast();
end  

% Disconnect and dispose
MyClient.Disconnect();

% Unload the SDK
fprintf( 'Unloading SDK...' );
Client.UnloadViconDataStreamSDK();
fprintf( 'done\n' );

% Clear all unused!
clearvars -except markerPos frameNr testcnt;

filename = ['C:\Users\proces\Desktop\13gr730\filename' num2str(testcnt,'%03d') '.mat'];

disp(['Save as:' filename '?']);
pause;

save(filename);

testcnt = testcnt+1;

disp(['File saved press enter to start new test!']);
pause;

end