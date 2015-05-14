%% This is a function for the UI for the quadcopter swarm
function UIStart
% Setup of Status window
Status  = figure('name','Status','NumberTitle','off');

%Setup of Status window
ax=axes('parent',Status, 'position',[0.1 0.3 0.8 0.65]);
xlim([-100 100]); ylim([-100 100]); zlim([-100 100]); %defines the axis sizes
%Button spawn and configuration
hpb = uicontrol('Style','pushbutton','string','Connect');
set(hpb, 'callback',@Connect,'position',[30 80 50 20])

hpb = uicontrol('Style','pushbutton','string','Start Vicon');
set(hpb, 'callback',@StartVicon,'position',[100 80 80 20])

hpb = uicontrol('Style','pushbutton','string','Stop Vicon');
set(hpb, 'callback',@StopVicon,'position',[200 80 80 20])

% xbee status
S='0';
TXT=uicontrol('style','text','string','Xbee status:');
set(TXT,'position',[25 40 70 20]);

TXT=uicontrol('style','text','string',S);
set(TXT, 'callback',@Xupdate,'position',[100 40 10 20])

% Setup of control window
CTRL    = figure('name','Ground station','NumberTitle','off');
NumDrones = input('Number of drones?')
figure(2)


for i=1:NumDrones
    n=strcat('Drone ',int2str(i),':');
    TXT=uicontrol('style','text','string', n);
    set(TXT,'position',[25 390-(40*i-1) 70 20]);
    
    TXT=uicontrol('style','text','string', 'Status:');
    set(TXT,'position',[90 390-(40*i-1) 50 20]);
    
    TXT=uicontrol('style','text','string', 'Priority:');
    set(TXT,'position',[140 390-(40*i-1) 50 20]);
    
    TXT=uicontrol('style','text','string', 'Battery:');
    set(TXT,'position',[190 390-(40*i-1) 50 20]);
end
TXT=uicontrol('style','text','string', 'Mode:');
    set(TXT,'position',[300 400 50 20]);
    
hpb = uicontrol('Style','pushbutton','string','1');
set(hpb, 'callback',@Mode1,'position',[360 400 20 20])

hpb = uicontrol('Style','pushbutton','string','2');
set(hpb, 'callback',@Mode2,'position',[380 400 20 20])

hpb = uicontrol('Style','pushbutton','string','3');
set(hpb, 'callback',@Mode3,'position',[400 400 20 20])

hpb = uicontrol('Style','pushbutton','string','4');
set(hpb, 'callback',@Mode4,'position',[420 400 20 20])

end

%% Connect to swarm function
function Connect(Obj,Event)
testvar = exist('xBee');
if testvar ~= 1
    %clear all
    [xBee, err] = setupSerial();
end
clear testvar
end

%% Vicon controls
function StartVicon(Obj,Event)
 
            Vicon=1
end

function StopVicon(Obj,Event)
Vicon=0
end

function Mode1(Obj,Event)
disp('test1')
end

function Mode2(Obj,Event)
disp('test2')
end

function Mode3(Obj,Event)
disp('test3')
end

function Mode4(Obj,Event)
disp('test4')
end
