clear all; close all; clc
%% Read TCP port and send on UDP

n=1; p=1;
port=4242
samples=1000;
%echotcpip('on', port);
t=tcpip('localhost', port, 'NetworkRole', 'client');
fopen(t);
host='172.26.56.142';
Port=1212;
u=udp(host,Port);
fopen(u); 
%fclose(t)
A(n,:)=fread(t)
pause(8)
tic
while (n<samples)
%fopen(t);
p=1;
    while p<4
        B=fscanf(t,'%c');
        A(n,p)=1*str2double(B);
        p=p+1;
    end
    Mes=[A(n,:)];
     fwrite(u,Mes,'double')
    n=n+1;
%fclose(t);
end
fclose(t);
fclose(u);
delete(t); clear t
avg=toc/(n-1)
%%
n=1;
P=1;
Ai=int32(A);
while n<samples
    if Ai(n,1) ~= 0 || Ai(n,2)~=0 || Ai(n,3) ~= 0
        C(n,:)=Ai(n,:);
        n=n+1;
    else
        n=n+1;
    end  
end
%%
plot3(A(:,1),A(:,2),A(:,3))
hold on
plot3(pos(1,:),pos(2,:),pos(3,:),'g')