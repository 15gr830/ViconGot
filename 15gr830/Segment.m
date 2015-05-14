clc
close all
clear all
%% go time
% Program options
TransmitMulticast = false;
% Load the SDK
Client.LoadViconDataStreamSDK();
% Program options
HostName = 'localhost:801';
MyClient = Client();
while ~MyClient.IsConnected().Connected
    MyClient.Connect( HostName );
    fprintf( '.' );
end
fprintf( '\n' );

% Enable some different data types
MyClient.EnableSegmentData();
MyClient.EnableMarkerData();
MyClient.EnableUnlabeledMarkerData();
MyClient.EnableDeviceData();

fprintf( 'Hammer TIME!: %d\n',          MyClient.IsSegmentDataEnabled().Enabled );

MyClient.SetStreamMode( StreamMode.ClientPull );
MyClient.SetAxisMapping( Direction.Forward, ...
    Direction.Left,    ...
    Direction.Up );    % Z-up
i=1;
while 1
    if MyClient.GetFrame().Result.Value == Result.Success
        Output_GetFrameNumber = MyClient.GetFrameNumber();
        Output_GetTimecode = MyClient.GetTimecode();
        
        Output_GetSegmentGlobalTranslation = MyClient.GetSegmentGlobalTranslation( 'Gr839', 'Gr839' );
        pos(1,i)=Output_GetSegmentGlobalTranslation.Translation( 1 );
        pos(2,i)=Output_GetSegmentGlobalTranslation.Translation( 2 );
        pos(3,i)=Output_GetSegmentGlobalTranslation.Translation( 3 );
        c=clock;
        pos(4,i)=c(4);
        pos(5,i)=c(5);
        pos(6,i)=c(6);
        AT = MyClient.GetSegmentGlobalRotationQuaternion( 'Gr839', 'Gr839' );
        ATT(:,i)=AT.Rotation;
        i=i+1;
    end
end% while true