close all, clear all, clc


vehicle_info = figure(123456789);

set(123456789, 'MenuBar', 'none');
set(123456789, 'ToolBar', 'none');

vehicle_info.Name = 'Follower Panel';

join_req = uicontrol(vehicle_info,'Style','pushbutton','Position',...
[50,100,100,50],'String','Join','Enable','off')

leave_req = uicontrol(vehicle_info,'Style','pushbutton','Position',...
    [200,100,100,50],'String','Leave','Enable','off','Callback',@leave_call)

all_vehicle = uicontrol(vehicle_info,'Style','listbox','Position',...
    [10,300,100,100],'Callback',{@all_vehicle_call,join_req,leave_req});

near_vehicle = uicontrol(vehicle_info,'Style','listbox','Position',...
    [150,300,100,100],'Callback',{@near_vehicle_call,join_req,leave_req});

follower_veh = uicontrol(vehicle_info,'Style','listbox','Position',...
    [150+140,300,100,100],'Callback',{@follower_veh_call,join_req,leave_req});

join_req.Callback ={ @join_call,near_vehicle};

join_req.Tag     = 'JoinReq';
leave_req.Tag    = 'LeaveReq';
all_vehicle.Tag  = 'AllVehicle';
near_vehicle.Tag = 'NearVehicle';
follower_veh.Tag = 'FollowerVehicle';

% 
FigureName = 'Follower Panel';
Fig = figure(...
'Units',           'normalized',...
'Position',        [0.7,0.5,0.3,0.4],...
'Name',            FigureName,...
'NumberTitle',     'off',...
'IntegerHandle',   'off',...
'HandleVisibility','callback',...
'Resize',          'on',...
'MenuBar',         'none',...
'ToolBar',         'none');







function all_vehicle_call(src,event,join,leave)

set(join,'Enable','off')
set(leave,'Enable','off')
end


function near_vehicle_call(src,event,join,leave)

set(join,'Enable','on')
set(leave,'Enable','off')
end



function follower_veh_call(src,event,join,leave)

set(join,'Enable','off')
set(leave,'Enable','on')
end


function join_call(src,event,s)
qwe = s.Value;
if ~isempty(qwe)
    asd = s.String(qwe);
    aaa = s.UserData;
    if ~isempty(asd)
        aaa.join_reqVeh(qwe) = 1;
        aaa
    end
end
end

function leave_call(src,event,s)
sss = 'loser'
end

