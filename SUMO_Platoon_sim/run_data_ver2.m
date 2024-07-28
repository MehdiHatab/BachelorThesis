close all
clc
clear all


load('data_ver2_2.mat');

%%

idx2                    = find(t<318.8);
idx1                    = find(t>=318.9 & t<=620.3);
veh(1)                  = vehicle;
veh(1).distance         = zeros(length(t),1);
veh(1).distanceX        = zeros(length(t),1);
veh(1).e_distance       = zeros(length(t),1);
veh(1).velocity         = zeros(length(t),1);
veh(1).velocity(idx1)   = v_follower(idx1,9);
veh(1).velocity(idx2)   = v_Leader(idx2);
veh(1).distance(idx1)   = -sqrt(dx_follower(idx1,9).^2+dy_follower(idx1,9).^2);
veh(1).distanceX(idx1)   = e_dx(idx1,9);
veh(1).e_distance(idx1) = -sqrt(e_dx(idx1,9).^2+e_dy(idx1,9).^2);
veh(1).t                = t;
veh(1).ID               = 'veh0';

veh(1).distance  (veh(1).distance   == 0) = nan;
veh(1).e_distance(veh(1).e_distance == 0) = nan;
veh(1).velocity  (veh(1).velocity   == 0) = nan;
veh(1).distanceX (veh(1).distance   == 0) = nan;



%%
idx               = find(t>=14 & t<=820.9);
veh(2)            = vehicle;
veh(2).t          = t(idx);
veh(2).distance   = -sqrt(dx_follower(idx,1).^2+dy_follower(idx,1).^2);
veh(2).distanceX  = e_dx(idx,1);
veh(2).e_distance = -sqrt(e_dx(idx,1).^2+e_dy(idx,1).^2);
veh(2).ID         = 'veh1';
veh(2).velocity   = v_follower(idx,1);

veh(2).distance  (veh(2).distance   == 0) = nan;
veh(2).e_distance(veh(2).e_distance == 0) = nan;
veh(2).velocity  (veh(2).velocity   == 0) = nan;
veh(1).distanceX (veh(2).distance   == 0) = nan;

%%
idx               = find(t>=26.9 & t<=820.5);
veh(3)            = vehicle;
veh(3).t          = t(idx);
veh(3).distance   = -sqrt(dx_follower(idx,2).^2+dy_follower(idx,2).^2);
veh(3).distanceX  =  e_dx(idx,2);
veh(3).e_distance = -sqrt(e_dx(idx,2).^2+e_dy(idx,2).^2);
veh(3).ID         = 'veh2';
veh(3).velocity   = v_follower(idx,2);

veh(3).distance  (veh(3).distance   == 0) = nan;
veh(3).e_distance(veh(3).e_distance == 0) = nan;
veh(3).velocity  (veh(3).velocity   == 0) = nan;
veh(3).distanceX (veh(3).distance   == 0) = nan;


%%
idx               = find(t>=56.7 & t<=820.7);
veh(4)            = vehicle;
veh(4).t          = t(idx);
veh(4).distance   = -sqrt(dx_follower(idx,3).^2+dy_follower(idx,3).^2);
veh(4).distanceX  = e_dx(idx,3);
veh(4).e_distance = -sqrt(e_dx(idx,3).^2+e_dy(idx,3).^2);
veh(4).ID         = 'veh3';
veh(4).velocity   = v_follower(idx,3);


veh(4).distance  (veh(4).distance   == 0) = nan;
veh(4).e_distance(veh(4).e_distance == 0) = nan;
veh(4).velocity  (veh(4).velocity   == 0) = nan;
veh(4).distanceX (veh(4).velocity   == 0) = nan;
%%
idx               = find(t>=89.2 & t<=703.8);
veh(5)            = vehicle;
veh(5).t          = t(idx);
veh(5).distance   = -sqrt(dx_follower(idx,4).^2+dy_follower(idx,4).^2);
veh(5).distanceX  = e_dx(idx,4);
veh(5).e_distance = -sqrt(e_dx(idx,4).^2+e_dy(idx,4).^2);
veh(5).ID         = 'veh4';
veh(5).velocity   = v_follower(idx,4);

veh(5).distance  (veh(5).distance   == 0) = nan;
veh(5).e_distance(veh(5).e_distance == 0) = nan;
veh(5).velocity  (veh(5).velocity   == 0) = nan;
veh(5).distanceX (veh(5).velocity   == 0) = nan;

%%
idx               = find(t>=116.6 & t<=706.9);
veh(6)            = vehicle;
veh(6).t          = t(idx);
veh(6).distance   = -sqrt(dx_follower(idx,5).^2+dy_follower(idx,5).^2);
veh(6).distanceX  =  e_dx(idx,5);
veh(6).e_distance = -sqrt(e_dx(idx,5).^2+e_dy(idx,5).^2);
veh(6).ID         = 'veh5';
veh(6).velocity   = v_follower(idx,5);

veh(6).distance  (veh(6).distance   == 0) = nan;
veh(6).e_distance(veh(6).e_distance == 0) = nan;
veh(6).velocity  (veh(6).velocity   == 0) = nan;
veh(6).distanceX (veh(6).velocity   == 0) = nan;

%%
idx               = find(t>=215.1 & t<=704.4);
veh(7)            = vehicle;
veh(7).t          = t(idx);
veh(7).distance   = -sqrt(dx_follower(idx,6).^2+dy_follower(idx,6).^2);
veh(7).distanceX  =  e_dx(idx,6);
veh(7).e_distance = -sqrt(e_dx(idx,6).^2+e_dy(idx,6).^2);
veh(7).ID         = 'veh6';
veh(7).velocity   = v_follower(idx,6);

veh(7).distance  (veh(7).distance   == 0) = nan;
veh(7).e_distance(veh(7).e_distance == 0) = nan;
veh(7).velocity  (veh(7).velocity   == 0) = nan;
veh(7).distanceX (veh(7).velocity   == 0) = nan;

%%
idx               = find(t>=225.8 & t<=705.2);
veh(8)            = vehicle;
veh(8).t          = t(idx);
veh(8).distance   = -sqrt(dx_follower(idx,7).^2+dy_follower(idx,7).^2);
veh(8).distanceX  =  e_dx(idx,7);
veh(8).e_distance = -sqrt(e_dx(idx,7).^2+e_dy(idx,7).^2);
veh(8).ID         = 'veh8';
veh(8).velocity   = v_follower(idx,7);

veh(8).distance  (veh(8).distance   == 0) = nan;
veh(8).e_distance(veh(8).e_distance == 0) = nan;
veh(8).velocity  (veh(8).velocity   == 0) = nan;
veh(8).distanceX (veh(8).velocity   == 0) = nan;


%% %new Leader
% idx                   = find(t>=265.3 & t<266.8);
idx2                  = find(t >= 318.8);
veh(9)                = vehicle;
veh(9).t              = t;
veh(9).distance       = zeros(length(t),1);
veh(9).distanceX      = zeros(length(t),1);
veh(9).e_distance     = zeros(length(t),1);
veh(9).velocity       = zeros(length(t),1);
% veh(9).distance(idx) = -sqrt(dx_follower(idx,8).^2+dy_follower(idx,8).^2);
veh(9).ID             = 'veh10';
% veh(9).velocity(idx)  = v_follower(idx,8);
veh(9).velocity(idx2) = v_Leader(idx2,1);
% veh(9).e_distance = -sqrt(e_dx(:,8).^2+e_dy(:,8).^2);


veh(9).distance  (veh(9).distance   == 0) = nan;
veh(9).e_distance(veh(9).e_distance == 0) = nan;
veh(9).velocity  (veh(9).velocity   == 0) = nan;
veh(9).distanceX (veh(9).velocity   == 0) = nan;


%%
idx               = find(t>=260.7 & t<=820.9);
veh(10)            = vehicle;
veh(10).t          = t(idx);
veh(10).distance   = -sqrt(dx_follower(idx,8).^2+dy_follower(idx,8).^2);
veh(10).distanceX  =  e_dx(idx,8);
veh(10).e_distance = -sqrt(e_dx(idx,8).^2+e_dy(idx,8).^2);
veh(10).ID         = 'veh9';
veh(10).velocity   = v_follower(idx,8);

veh(10).distance  (veh(10).distance   == 0) = nan;
veh(10).e_distance(veh(10).e_distance == 0) = nan;
veh(10).velocity  (veh(10).velocity   == 0) = nan;
veh(10).distanceX (veh(10).distance   == 0) = nan;

%%
idx               = find(t>=597.5 & t<=820.4);
veh(11)            = vehicle;
veh(11).t          = t(idx);
veh(11).distance   = -sqrt(dx_follower(idx,10).^2+dy_follower(idx,10).^2);
veh(11).distanceX  =  e_dx(idx,10);
veh(11).e_distance = -sqrt(e_dx(idx,10).^2+e_dy(idx,10).^2);
veh(11).ID         = 'veh11';
veh(11).velocity   = v_follower(idx,10);


veh(11).distance  (veh(11).distance   == 0) = nan;
veh(11).e_distance(veh(11).e_distance == 0) = nan;
veh(11).velocity  (veh(11).velocity   == 0) = nan;
veh(11).distanceX (veh(11).velocity   == 0) = nan;


for m = 1:11
    veh(m).distance = veh(m).distance + 4;
end

%%

rgb = zeros(11,4);
rgb(1,:)  = color.Red/255;
rgb(2,:)  = color.Black/255;
rgb(3,:)  = color.Green/255;
rgb(4,:)  = color.Orange/255;
rgb(5,:)  = color.Blue/255;
rgb(6,:)  = color.Violet/255;
rgb(7,:)  = color.Silver/255;
rgb(8,:)  = color.Pink/255;
rgb(9,:)  = color.Olive/255;
rgb(10,:) = color.Brown/255;
rgb(11,:) = color.Cyan/255;

asd = cell(11,1);
asd(:) = {''};

vehicle = 1:4;

figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).velocity,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Speed in m/s'
xlim([0,88.9])
ylim([22,36])
legend(asd(vehicle),'NumColumns',2,'Location','southeast')

figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).distance,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
set(gca,'YTick',[-150 -125 -100 -75 -50 -25 0]);
xlabel 'Time in Second'
ylabel 'Distance in m'
xlim([0,88.9])
ylim([-150,0])
legend(asd(vehicle),'NumColumns',2,'Location','southeast')


% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).e_distance,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Error Distance in m'
% xlim([0,88.9])
% ylim([-100,0])
% legend(asd(vehicle),'Location','Best')
% 

% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).distanceX,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Distance in m'
% xlim([0,88.9])
% ylim([-100,0])
% legend(asd(vehicle),'Location','Best')

%%

% close all

rgb = zeros(11,4);
rgb(1,:)  = color.Red/255;
rgb(2,:)  = color.Black/255;
rgb(3,:)  = color.Green/255;
rgb(4,:)  = color.Orange/255;
rgb(5,:)  = color.Blue/255;
rgb(6,:)  = color.Violet/255;
rgb(7,:)  = color.Silver/255;
rgb(8,:)  = color.Pink/255;
rgb(9,:)  = color.Olive/255;
rgb(10,:) = color.Brown/255;
rgb(11,:) = color.Cyan/255;

rear  = [1,7,8];
side  = [5,6,11];
front = [9];

asd = cell(11,1);
asd(:) = {''};

vehicle = 1:6;

figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).velocity,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Speed in m/s'
xlim([86,180])
ylim([22,36])
legend(asd(vehicle),'NumColumns',3,'Location','southeast')


figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).distance,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Distance in m'
xlim([86,180])
ylim([-120,0])
legend(asd(vehicle),'NumColumns',3,'Location','southeast')



% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).e_distance,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Error Distance in m'
% xlim([86,180])
% ylim([-50,0])
% legend(asd(vehicle),'Location','Best')
% 
% 
% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).distanceX,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Distance in m'
% xlim([86,180])
% ylim([-50,6])
% legend(asd(vehicle),'Location','Best')

%%
% close all

rgb = zeros(11,4);
rgb(1,:)  = color.Red/255;
rgb(2,:)  = color.Black/255;
rgb(3,:)  = color.Green/255;
rgb(4,:)  = color.Orange/255;
rgb(5,:)  = color.Blue/255;
rgb(6,:)  = color.Violet/255;
rgb(7,:)  = color.Silver/255;
rgb(8,:)  = color.Pink/255;
rgb(9,:)  = color.Olive/255;
rgb(10,:) = color.Brown/255;
rgb(11,:) = color.Cyan/255;

asd = cell(11,1);
asd(:) = {''};

vehicle = [1:8,10];


figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).velocity,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Speed in m/s'
xlim([210,310])
ylim([22,36])
legend(asd(vehicle),'NumColumns',2,'Location','southeast')


figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).distance,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end

xlabel 'Time in Second'
ylabel 'Distance in m'
xlim([210,310])
ylim([-160,0])
legend(asd(vehicle),'NumColumns',2,'Location','southwest')


% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).e_distance,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Error Distance in m'
% xlim([210,310])
% ylim([-50,0])
% legend(asd(vehicle),'Location','Best')
% 
% 
% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).distanceX,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Error Distance in m'
% xlim([210,310])
% ylim([-50,6])
% legend(asd(vehicle),'Location','Best')
%%
% close all

rgb = zeros(11,4);
rgb(1,:)  = color.Red/255;
rgb(2,:)  = color.Black/255;
rgb(3,:)  = color.Green/255;
rgb(4,:)  = color.Orange/255;
rgb(5,:)  = color.Blue/255;
rgb(6,:)  = color.Violet/255;
rgb(7,:)  = color.Silver/255;
rgb(8,:)  = color.Pink/255;
rgb(9,:)  = color.Olive/255;
rgb(10,:) = color.Brown/255;
rgb(11,:) = color.Cyan/255;


asd = cell(11,1);
asd(:) = {''};


vehicle = 1:10;

figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).velocity,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Speed in m/s'
xlim([310,400])
ylim([22,36])
legend(asd(vehicle),'NumColumns',3,'Location','southeast')


figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).distance,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Distance in m'
xlim([310,400])
ylim([-200,0])
legend(asd(vehicle),'NumColumns',3,'Location','southeast')



% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).e_distance,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Error Distance in m'
% xlim([310,400])
% ylim([-60,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',4)
% 
% 
% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).distanceX,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Distance in m'
% xlim([310,400])
% ylim([-60,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',4)
%%
% close all

rgb = zeros(11,4);
rgb(1,:)  = color.Red/255;
rgb(2,:)  = color.Black/255;
rgb(3,:)  = color.Green/255;
rgb(4,:)  = color.Orange/255;
rgb(5,:)  = color.Blue/255;
rgb(6,:)  = color.Violet/255;
rgb(7,:)  = color.Silver/255;
rgb(8,:)  = color.Pink/255;
rgb(9,:)  = color.Olive/255;
rgb(10,:) = color.Brown/255;
rgb(11,:) = color.Cyan/255;

asd = cell(11,1);
asd(:) = {''};

vehicle = 1:10;

figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).velocity,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Speed in m/s'
xlim([400,580])
ylim([22,36])
legend(asd(vehicle),'NumColumns',3,'Location','southeast')


figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).distance,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Distance in m'
xlim([400,580])
ylim([-160,0])
legend(asd(vehicle),'NumColumns',3,'Location','southeast')



% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).e_distance,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Error Distance in m'
% xlim([400,580])
% ylim([-20,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',4)
% 
% 
% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).distanceX,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Distance in m'
% xlim([400,580])
% ylim([-20,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',4)
%%
% close all

rgb = zeros(11,4);
rgb(1,:)  = color.Red/255;
rgb(2,:)  = color.Black/255;
rgb(3,:)  = color.Green/255;
rgb(4,:)  = color.Orange/255;
rgb(5,:)  = color.Blue/255;
rgb(6,:)  = color.Violet/255;
rgb(7,:)  = color.Silver/255;
rgb(8,:)  = color.Pink/255;
rgb(9,:)  = color.Olive/255;
rgb(10,:) = color.Brown/255;
rgb(11,:) = color.Cyan/255;


asd = cell(11,1);
asd(:) = {''};

vehicle = 1:11;

figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).velocity,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Speed in m/s'
xlim([590,685])
ylim([22,36])
legend(asd(vehicle),'NumColumns',3,'Location','southeast')


figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).distance,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Distance in m'
xlim([590,685])
ylim([-200,0])
legend(asd(vehicle),'NumColumns',3,'Location','southeast')



% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).e_distance,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Error Distance in m'
% xlim([590,685])
% ylim([-40,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',4)
% 
% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).distanceX,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Distance in m'
% xlim([590,685])
% ylim([-40,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',4)
%%
% % close all

rgb = zeros(11,4);
rgb(1,:)  = color.Red/255;
rgb(2,:)  = color.Black/255;
rgb(3,:)  = color.Green/255;
rgb(4,:)  = color.Orange/255;
rgb(5,:)  = color.Blue/255;
rgb(6,:)  = color.Violet/255;
rgb(7,:)  = color.Silver/255;
rgb(8,:)  = color.Pink/255;
rgb(9,:)  = color.Olive/255;
rgb(10,:) = color.Brown/255;
rgb(11,:) = color.Cyan/255;

% rear  = [1,7,8];
% side  = [5,6,11];
% front = [9];

asd = cell(11,1);
asd(:) = {''};

vehicle = 2:11;

figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).velocity,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Speed in m/s'
xlim([680,790])
ylim([22,36])
legend(asd(vehicle),'NumColumns',3,'Location','southeast')


figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).distance,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Distance in m'
xlim([680,790])
ylim([-160,0])
legend(asd(vehicle),'NumColumns',3,'Location','southeast')



% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).e_distance,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Error Distance in m'
% xlim([680,790])
% ylim([-60,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',1)
% 
% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).distanceX,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Distance in m'
% xlim([680,790])
% ylim([-60,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',1)
%%
% % close all

rgb = zeros(11,4);
rgb(1,:)  = color.Red/255;
rgb(2,:)  = color.Black/255;
rgb(3,:)  = color.Green/255;
rgb(4,:)  = color.Orange/255;
rgb(5,:)  = color.Blue/255;
rgb(6,:)  = color.Violet/255;
rgb(7,:)  = color.Silver/255;
rgb(8,:)  = color.Pink/255;
rgb(9,:)  = color.Olive/255;
rgb(10,:) = color.Brown/255;
rgb(11,:) = color.Cyan/255;

rear  = [1,7,8];
side  = [5,6,11];
front = [9];

asd = cell(11,1);
asd(:) = {''};

vehicle = [3,4,9,10,11];

figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).velocity,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Speed in m/s'
xlim([790,830])
ylim([22,36])
legend(asd(vehicle),'NumColumns',3,'Location','southeast')


figure
for idx = vehicle
    stairs(veh(idx).t,veh(idx).distance,'LineWidth',1.5,'Color',rgb(idx,:))
    hold on
    grid on
    asd{idx} = veh(idx).ID;
end
xlabel 'Time in Second'
ylabel 'Distance in m'
xlim([790,830])
ylim([-120,0])
legend(asd(vehicle),'NumColumns',3,'Location','southeast')



% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).e_distance,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Speed in m/s'
% xlim([790,830])
% ylim([-120,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',3)
% 
% 
% figure
% for idx = vehicle
%     stairs(veh(idx).t,veh(idx).distanceX,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Distance in m'
% xlim([790,830])
% ylim([-120,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',1)
%%
% rgb = zeros(11,4);
% rgb(1,:)  = color.Red/255;
% rgb(2,:)  = color.Black/255;
% rgb(3,:)  = color.Green/255;
% rgb(4,:)  = color.Orange/255;
% rgb(5,:)  = color.Blue/255;
% rgb(6,:)  = color.Violet/255;
% rgb(7,:)  = color.Silver/255;
% rgb(8,:)  = color.Pink/255;
% rgb(9,:)  = color.Olive/255;
% rgb(10,:) = color.Brown/255;
% rgb(11,:) = color.Cyan/255;
% 
% 
% asd = cell(11,1);
% asd(:) = {''};
% 
% 
% vehicle = 1:10;
% 
% figure
% for idx = vehicle
%     stairs(t,veh(idx).velocity,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Speed in m/s'
% xlim([200,400])
% ylim([14,32])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',5)
% 
% 
% figure
% for idx = vehicle
%     stairs(t,veh(idx).distance,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Distance in m'
% xlim([260,330])
% ylim([-200,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',4)
% 
% 
% 
% figure
% for idx = vehicle
%     stairs(t,veh(idx).e_distance,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'Error Distance in m'
% xlim([260,330])
% ylim([-60,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',4)
% 
% 
% 
% 
% figure
% for idx = vehicle
%     stairs(t,veh(idx).distanceX,'LineWidth',1.5,'Color',rgb(idx,:))
%     hold on
%     grid on
%     asd{idx} = veh(idx).ID;
% end
% xlabel 'Time in Second'
% ylabel 'EDistanceX in m'
% xlim([260,330])
% ylim([-200,0])
% legend(asd(vehicle),'Location','Best','Orientation','horizontal','NumColumns',4)

