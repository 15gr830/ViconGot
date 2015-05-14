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




clc
close all
clear all
%%

%% Init
status = 1;
i=1;
DroneCount=1;
est=zeros(3,DroneCount);
Names =['E1'];
%Names=['E1';'E2';'E3';'E4';'E5';'E6';'E7';'E8';'E9';'E0'];
MsgH=1;
m=1;
Time=[0]
%start position guess
%Start =    [-0.8098   -0.1647   -0.8113   -1.4796   -0.8436   -0.1875   -1.4810   -1.4919   -0.1665  0.4134;
%   -0.8735   -0.1614   -0.2522   -0.8891    0.4129    0.4394   -0.2887    0.3833   -0.8382   -0.1821 ;
%    0.0319    0.0324    0.0331    0.0338    0.0308    0.0275    0.0327    0.0337    0.0311    0.0326 ]'*1000
Start = [ -456.2051;
          -291.0266;
            74.5130];         
        
host='172.26.56.55';
port=801;
u=udp(host,port);
fopen(u); 


%% go time7


while status
    choice = questdlg('Vicon is ready', ...
        'Vicon measurment', ...
        'Run','Save data','Stop','Run');
    switch choice
        case 'Run'
            
            % Program options
            TransmitMulticast = false;
            
            % Load the SDK
            fprintf( 'Loading SDK...' );
            Client.LoadViconDataStreamSDK();
            fprintf( 'done\n' );
            
            % Program options
            HostName = 'localhost:801';
            
            % Make a new client
            MyClient = Client();
            
            % Connect to a server
            fprintf( 'Connecting to %s ...', HostName );
            while ~MyClient.IsConnected().Connected
                % Direct connection
                MyClient.Connect( HostName );
                
                % Multicast connection
                % MyClient.ConnectToMulticast( HostName, '224.0.0.0' );
                
                fprintf( '.' );
            end
            fprintf( '\n' );
            
            % Enable some different data types
            MyClient.EnableSegmentData();
            MyClient.EnableMarkerData();
            MyClient.EnableUnlabeledMarkerData();
            MyClient.EnableDeviceData();
            
            fprintf( 'Segment Data Enabled: %d\n',          MyClient.IsSegmentDataEnabled().Enabled );
            fprintf( 'Marker Data Enabled: %d\n',           MyClient.IsMarkerDataEnabled().Enabled );
            fprintf( 'Unlabeled Marker Data Enabled: %d\n', MyClient.IsUnlabeledMarkerDataEnabled().Enabled );
            fprintf( 'Device Data Enabled: %d\n',           MyClient.IsDeviceDataEnabled().Enabled );
            
            % Set the streaming mode
            MyClient.SetStreamMode( StreamMode.ClientPull );
            % MyClient.SetStreamMode( StreamMode.ClientPullPreFetch );
            % MyClient.SetStreamMode( StreamMode.ServerPush );
            
            % Set the global up axis
            MyClient.SetAxisMapping( Direction.Forward, ...
                Direction.Left,    ...
                Direction.Up );    % Z-up
            % MyClient.SetAxisMapping( Direction.Forward, ...
            %                          Direction.Up,      ...
            %                          Direction.Right ); % Y-up
            
            Output_GetAxisMapping = MyClient.GetAxisMapping();
            fprintf( 'Axis Mapping: X-%s Y-%s Z-%s\n', Output_GetAxisMapping.XAxis.ToString(), ...
                Output_GetAxisMapping.YAxis.ToString(), ...
                Output_GetAxisMapping.ZAxis.ToString() );
            
            
            % Discover the version number
            Output_GetVersion = MyClient.GetVersion();
            fprintf( 'Version: %d.%d.%d\n', Output_GetVersion.Major, ...
                Output_GetVersion.Minor, ...
                Output_GetVersion.Point );
            
            if TransmitMulticast
                MyClient.StartTransmittingMulticast( 'localhost', '224.0.0.0' );
            end
            
            %% AAUSAT vars
            
            
            % A dialog to stop the loop
           % MessageBox = msgbox( 'Stop DataStream Client', 'Vicon DataStream SDK' );
    
            
        
            
            %% Loop until the message box is dismissed
            %niklas_bendtner=0
                n=1;
                tic
            while 1 %ishandle( MessageBox )
                %niklas_bendtner = niklas_bendtner + 1;
                drawnow;
                
                % Get a frame
                %fprintf( 'Waiting for new frame...' );
                while MyClient.GetFrame().Result.Value ~= Result.Success
                    fprintf( '.' );
                end% while
                %fprintf( '\n' );
                
                % Get the frame number
                Output_GetFrameNumber = MyClient.GetFrameNumber();
                %fprintf( 'Frame Number: %d\n', Output_GetFrameNumber.FrameNumber );
                
                % Get the timecode
                Output_GetTimecode = MyClient.GetTimecode();
                %   fprintf( 'Timecode: %dh %dm %ds %df %dsf %d %s %d %d\n\n', ...
                %                      Output_GetTimecode.Hours,               ...
                %                      Output_GetTimecode.Minutes,             ...
                %                      Output_GetTimecode.Seconds,             ...
                %                      Output_GetTimecode.Frames,              ...
                %                      Output_GetTimecode.SubFrame,            ...
                %                      Output_GetTimecode.FieldFlag,           ...
                %                      Output_GetTimecode.Standard.ToString(), ...
                %                      Output_GetTimecode.SubFramesPerFrame,   ...
                %                      Output_GetTimecode.UserBits );
                
                % Get the latency
                %  fprintf( 'Latency: %gs\n', MyClient.GetLatencyTotal().Total );
                
                for LatencySampleIndex = 1:MyClient.GetLatencySampleCount().Count
                    SampleName  = MyClient.GetLatencySampleName( LatencySampleIndex ).Name;
                    SampleValue = MyClient.GetLatencySampleValue( SampleName ).Value;
                    
                    %   fprintf( '  %s %gs\n', SampleName, SampleValue );
                end% for
                %fprintf( '\n' );
                
                Output_GetSegmentGlobalTranslation = MyClient.GetSegmentGlobalTranslation( 'gr830_quad', 'gr830_quad' );
                %% Estimator
if i<3
    old3=Start';
    old2=Start';
    old1=Start';
end
                
    E(i,:,:) = old1+(old1-old2)+((old1-old2)-(old2-old3))/10;
    old3(:,:)=old2(:,:);
    old2(:,:)=old1(:,:);
    old1(:,:)=est(:,:)';

    for j=1:DroneCount
        for k=1:Markercount.MarkerCount
            error(j,k) = sqrt(((Marker(1,k)-E(i,j,1))^2)+((Marker(2,k)-E(i,j,2))^2)+((Marker(3,k)-E(i,j,3))^2));
        end
    end
    
    %"selector" rows: estimator, coloum: error (measurement)
    est(:,:)=zeros(3,DroneCount);
    for r=1:size(error,1)
        x=10000;
        rx=1;
        cx=1;
        for c=1:size(error,2)
            if error(r,c)<x
                x=error(r,c);
                rx=r;
                cx=c;
            end
        end
        if (abs(x) < 600)% && (i > 2)
            est(:,r)=Marker(:,cx);
            valid(i,r)=1;
            %x
            
        elseif (i > 2)
            est(:,r)=old1(r,:)';
            disp('big error')
            x
            %z=est(3,r)
            valid(i,r)=0;
        else
            est(:,r)=Start(:,r);
            disp('err0r - init /ignore this')
            i
            valid(i,r)=0;
        end
    end
    
    
    i=i+1;      
    
    
%     % Plot estimated positions 2D
%     plot(est(1,:),est(3,:),'o')
%     hold on
%     text(est(1,:)+20,est(3,:)+70,Names); %name of estimated position
%     hold off
%     xlim([-4000 4000])
%     ylim([0 4000])
%     %pause(0.05)
    

%     %Plot estimated positions 3D
%     plot3(est(1,:),est(2,:),est(3,:),'o')

%     grid on
%     hold on
%     text(est(1,:)+20,est(2,:)+70,est(3,:)+70,Names)
%     hold off
%     xlim([-4000 4000])
%     ylim([-4000 4000])
%     zlim([0 4000])
    
    
    T(i)=toc;    
    F(i)=1/T(i);
    Data(i,:,:)=est(:,:);
    if T(i)>=0.1
        Time=[Time, T(i)];
        m=m+1;
        Mes=[m];
        tom=[0, 0, -1];
        for d=1:DroneCount
            Mes=[Mes,est(:,d)'];
        end
        for t=1:(10-DroneCount)
            Mes=[Mes,tom];
        end
            
        
        fwrite(u,Mes,'double')
        MsgH=0;
        tic;
    end
    if m>9
        m=0;
    end
    
%                 % Count the number of subjects
%                 SubjectCount = MyClient.GetSubjectCount().SubjectCount;
%                 %fprintf( 'Subjects (%d):\n', SubjectCount );
%                 for SubjectIndex = 1:SubjectCount
%                     % fprintf( '  Subject #%d\n', SubjectIndex );
%                     
%                     % Get the subject name
%                     SubjectName = MyClient.GetSubjectName( SubjectIndex ).SubjectName;
%                     %fprintf( '    Name: %s\n', SubjectName );
%                     
%                     % Get the root segment
%                     RootSegment = MyClient.GetSubjectRootSegmentName( SubjectName ).SegmentName;
%                     %fprintf( '    Root Segment: %s\n', RootSegment );
%                     
%                     % Count the number of segments
%                     SegmentCount = MyClient.GetSegmentCount( SubjectName ).SegmentCount;
%                     %fprintf( '    Segments (%d):\n', SegmentCount );
%                     for SegmentIndex = 1:SegmentCount
%                         % fprintf( '      Segment #%d\n', SegmentIndex );
%                         
%                         % Get the segment name
%                         SegmentName = MyClient.GetSegmentName( SubjectName, SegmentIndex ).SegmentName;
%                         %fprintf( '        Name: %s\n', SegmentName );
%                         
%                         % Get the segment parent
%                         SegmentParentName = MyClient.GetSegmentParentName( SubjectName, SegmentName ).SegmentName;
%                         %fprintf( '        Parent: %s\n',  SegmentParentName );
%                         
%                         % Get the segment's children
%                         ChildCount = MyClient.GetSegmentChildCount( SubjectName, SegmentName ).SegmentCount;
%                         %fprintf( '     Children (%d)\n', ChildCount );
%                         for ChildIndex = 1:ChildCount
%                             ChildName = MyClient.GetSegmentChildName( SubjectName, SegmentName, ChildIndex ).SegmentName;
%                             %fprintf( '       %s\n', ChildName );
%                         end% for
%                         
%                         % Get the global segment rotation in quaternion co-ordinates
%                         Output_GetSegmentGlobalRotationQuaternion = MyClient.GetSegmentGlobalRotationQuaternion( SubjectName, SegmentName );
%                         %       fprintf( '        Global Rotation Quaternion: (%g,%g,%g,%g) %d\n', ...
%                         %                          Output_GetSegmentGlobalRotationQuaternion.Rotation( 1 ),       ...
%                         %                          Output_GetSegmentGlobalRotationQuaternion.Rotation( 2 ),       ...
%                         %                          Output_GetSegmentGlobalRotationQuaternion.Rotation( 3 ),       ...
%                         %                          Output_GetSegmentGlobalRotationQuaternion.Rotation( 4 ),       ...
%                         %                          Output_GetSegmentGlobalRotationQuaternion.Occluded );
%                         
%                         % Get the local segment rotation in quaternion co-ordinates
%                         Output_GetSegmentLocalRotationQuaternion = MyClient.GetSegmentLocalRotationQuaternion( SubjectName, SegmentName );
%                         %       fprintf( '        Local Rotation Quaternion: (%g,%g,%g,%g) %d\n', ...
%                         %                          Output_GetSegmentLocalRotationQuaternion.Rotation( 1 ),       ...
%                         %                          Output_GetSegmentLocalRotationQuaternion.Rotation( 2 ),       ...
%                         %                          Output_GetSegmentLocalRotationQuaternion.Rotation( 3 ),       ...
%                         %                          Output_GetSegmentLocalRotationQuaternion.Rotation( 4 ),       ...
%                         %                          Output_GetSegmentLocalRotationQuaternion.Occluded );
%                         
%                         
%                     end% SegmentIndex
%                     
%                     % Count the number of markers
%                     MarkerCount = MyClient.GetMarkerCount( SubjectName ).MarkerCount;
%                     %fprintf( '    Markers (%d):\n', MarkerCount );
%                     %     for MarkerIndex = 1:MarkerCount
%                     %       % Get the marker name
%                     %       MarkerName = MyClient.GetMarkerName( SubjectName, MarkerIndex ).MarkerName;
%                     %
%                     %       % Get the marker parent
%                     %       MarkerParentName = MyClient.GetMarkerParentName( SubjectName, MarkerName ).SegmentName;
%                     %
%                     %       % Get the global marker translation
%                     %       Output_GetMarkerGlobalTranslation = MyClient.GetMarkerGlobalTranslation( SubjectName, MarkerName );
%                     %
%                     %       fprintf( '      Marker #%d: %s (%g,%g,%g) %d\n',                       ...
%                     %                          MarkerIndex,                                        ...
%                     %                          MarkerName,                                         ...
%                     %                          Output_GetMarkerGlobalTranslation.Translation( 1 ), ...
%                     %                          Output_GetMarkerGlobalTranslation.Translation( 2 ), ...
%                     %                          Output_GetMarkerGlobalTranslation.Translation( 3 ), ...
%                     %                          Output_GetMarkerGlobalTranslation.Occluded );
%                     %     end% MarkerIndex
%                     
%                 end% SubjectIndex
%                 
%                 % Get the unlabeled markers
%                 UnlabeledMarkerCount = MyClient.GetUnlabeledMarkerCount().MarkerCount;
%                 %fprintf( '  Unlabeled Markers (%d):\n', UnlabeledMarkerCount );
%                 for UnlabeledMarkerIndex = 1:UnlabeledMarkerCount
%                     % Get the global marker translation
%                     Output_GetUnlabeledMarkerGlobalTranslation = MyClient.GetUnlabeledMarkerGlobalTranslation( UnlabeledMarkerIndex );
%                     %     fprintf( '    Marker #%d: (%g,%g,%g)\n',                                        ...
%                     %                        UnlabeledMarkerIndex,                                        ...
%                     %                        Output_GetUnlabeledMarkerGlobalTranslation.Translation( 1 ), ...
%                     %                        Output_GetUnlabeledMarkerGlobalTranslation.Translation( 2 ), ...
%                     %                        Output_GetUnlabeledMarkerGlobalTranslation.Translation( 3 ) );
%                 end% UnlabeledMarkerIndex
%                 
%                 % Count the number of devices
%                 DeviceCount = MyClient.GetDeviceCount().DeviceCount;
%                 % fprintf( '  Devices (%d):\n', DeviceCount );
%                 for DeviceIndex = 1:DeviceCount
%                     % fprintf( '    Device #%d:\n', DeviceIndex );
%                     
%                     % Get the device name and type
%                     Output_GetDeviceName = MyClient.GetDeviceName( DeviceIndex );
%                     %fprintf( '      Name: %s\n', Output_GetDeviceName.DeviceName );
%                     %fprintf( '      Type: %s\n', Output_GetDeviceName.DeviceType.ToString() );
%                     
%                     
%                     % Count the number of device outputs
%                     DeviceOutputCount = MyClient.GetDeviceOutputCount( Output_GetDeviceName.DeviceName ).DeviceOutputCount;
%                     %fprintf( '      Device Outputs (%d):\n', DeviceOutputCount );
%                     for DeviceOutputIndex = 1:DeviceOutputCount
%                         % Get the device output name and unit
%                         Output_GetDeviceOutputName = MyClient.GetDeviceOutputName( Output_GetDeviceName.DeviceName, DeviceOutputIndex );
%                         
%                         % Get the device output value
%                         Output_GetDeviceOutputValue = MyClient.GetDeviceOutputValue( Output_GetDeviceName.DeviceName, Output_GetDeviceOutputName.DeviceOutputName );
%                         
%                         %       fprintf( '        Device Output #%d: %s %g %s %d\n',                       ...
%                         %                          DeviceOutputIndex,                                      ...
%                         %                          Output_GetDeviceOutputName.DeviceOutputName,            ...
%                         %                          Output_GetDeviceOutputValue.Value,                      ...
%                         %                          Output_GetDeviceOutputName.DeviceOutputUnit.ToString(), ...
%                         %                          Output_GetDeviceOutputValue.Occluded );
%                     end% DeviceOutputIndex
%                     
%                 end% DeviceIndex
%                 
%                 % Count the number of force plates
%                 ForcePlateCount = MyClient.GetForcePlateCount().ForcePlateCount;
%                 %fprintf( '  Devices (%d):\n', ForcePlateCount );
%                 for ForcePlateIndex = 1:ForcePlateCount
%                     %fprintf( '    Device #%d:\n', ForcePlateIndex );
%                     
%                     Output_GetGlobalForceVector = MyClient.GetGlobalForceVector( ForcePlateIndex );
%                     %     fprintf( '    Force Vector: (%g,%g,%g)\n',                       ...
%                     %                        Output_GetGlobalForceVector.ForceVector( 1 ), ...
%                     %                        Output_GetGlobalForceVector.ForceVector( 2 ), ...
%                     %                        Output_GetGlobalForceVector.ForceVector( 3 ) );
%                     %
%                     Output_GetGlobalMomentVector = MyClient.GetGlobalMomentVector( ForcePlateIndex );
%                     %     fprintf( '    Moment Vector: (%g,%g,%g)\n',                        ...
%                     %                        Output_GetGlobalMomentVector.MomentVector( 1 ), ...
%                     %                        Output_GetGlobalMomentVector.MomentVector( 2 ), ...
%                     %                        Output_GetGlobalMomentVector.MomentVector( 3 ) );
%                     %
%                     Output_GetGlobalCentreOfPressure = MyClient.GetGlobalCentreOfPressure( ForcePlateIndex );
%                     %     fprintf( '    CoP: (%g,%g,%g)\n',                                          ...
%                     %                        Output_GetGlobalCentreOfPressure.CentreOfPressure( 1 ), ...
%                     %                        Output_GetGlobalCentreOfPressure.CentreOfPressure( 2 ), ...
%                     %                        Output_GetGlobalCentreOfPressure.CentreOfPressure( 3 ) );
%                 end% ForcePlateIndex
                
            end% while true
            
            
            if TransmitMulticast
                MyClient.StopTransmittingMulticast();
            end
            
            % Disconnect and dispose
            MyClient.Disconnect();
            
            % Unload the SDK
            fprintf( 'Unloading SDK...' );
            Client.UnloadViconDataStreamSDK();
            
          
            
        case 'Save data'
            uisave('aausat_quaternion_matrix','aausat_test');
        case 'Stop'
            fprintf('Have a nice day =)')
            status = ~status;
    end
end
fclose(u);

