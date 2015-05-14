clear all; close all; clc
%% Setup TCP port and UDP
system('C:\Users\proces\Desktop\GOTSDK\GOTSDKSample\bin\Debug\Run.bat')
port=4242
t=tcpip('localhost', port, 'NetworkRole', 'client');
fopen(t);
host='172.26.56.142'; %router
Port=1212;
u=udp(host,Port);
fopen(u); 

%% setup and Init Vicon
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

%% While loop, stop with ctrl + c
n=1; p=1; i=1;
A(n,:)=fread(t)
pause(8)
tic
n=n+1;
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
        
    end
    
    p=1;
    while p<4
        B=fscanf(t,'%c');
        A(n,p)=1*str2double(B);
        p=p+1;
    end
    A(n,3)=A(n,3)+983; % calbration of z in got
    Mes=[A(n,(1:3)), pos(1,i),pos(2,i),pos(3,i),ATT(1,i),ATT(2,i),ATT(3,i),ATT(4,i)];
    fwrite(u,Mes,'double')
    n=n+1;
    i=i+1;
    
    
end

%%
plot3(A(:,1),A(:,2),A(:,3))
hold on
plot3(pos(1,:),pos(2,:),pos(3,:),'g')