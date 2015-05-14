% Script for plotting in status figure: UpdateStatus(data,Expected)
function UpdateStatus(data,Expected)
figure(1)
plot3(data(1,:),data(2,:),data(3,:),'o')
xlim([-10000 10000]); ylim([-10000 10000]); zlim([-100 5000]);
hold on
plot3(Expected(1,:),Expected(2,:),Expected(3,:),'rx')
hold off
%figure(2)
end

