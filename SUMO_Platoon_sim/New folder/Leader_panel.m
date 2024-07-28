% close all, clear all, clc
clc, clear all

follower_info = figure(789);

set(789, 'MenuBar', 'none');
set(789, 'ToolBar', 'none');



accept_btn.Tag   = 'Accept';
decline_btn.Tag  = 'Decline';
text1.Tag        = 'Text';
% near_vehicle.Tag = 'NearVehicle';
follower_veh.Tag = 'FollowerVehicle';


IDs      =   [];
vel      =   [];
dist     =   [];
accepted =   [];
declined =   [];


leader_block = 'Example_SOMU_SYNC/Leader';
temp = table(IDs, vel, dist, accepted, declined);
set_param(leader_block,'UserData',temp);


% function all_vehicle_call(src,event,join,leave)
% 
% set(join,'Enable','off')
% set(leave,'Enable','off')
% end
% 
% 
% function near_vehicle_call(src,event,join,leave)
% 
% set(join,'Enable','on')
% set(leave,'Enable','off')
% end



function accept_btn_callback(src,event,follower_list,text1)
request_info = findobj(123456789,'Tag','NearVehicle');
idx = find(strcmp({'x'}, request_info.UserData(:,1)));
follower_list.UserData = request_info.UserData(idx,:);

leader_block = 'Example_SOMU_SYNC/Leader';

follower_list.String = {follower_list.String,'x'};
text1.String = '';

ud = get_param(leader_block,'UserData');
[a,~] = size(ud);

ud(a+1,:) = [{''},0,0,0,0];
ud.IDs(a+1) = request_info.UserData.idVeh(idx);
ud.dist(a+1) = request_info.UserData.dist(idx);
ud.vel(a+1) = request_info.UserData.vel(idx);
ud.accepted(a+1) = 1;
ud.declined(a+1) = 0;
set_param(leader_block,'UserData',ud);
end


