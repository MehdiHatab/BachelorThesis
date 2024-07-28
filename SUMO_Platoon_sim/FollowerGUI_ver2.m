classdef FollowerGUI_ver2

    properties
        fig
        NearVehicle
        NearVehiclesPanel
        FollowerVehicle
        FollowerVehiclePanel
        JoinReq
        LeaveReq
    end
    
    methods
        function obj = FollowerGUI_ver2()
            obj.fig = figure;
            set(obj.fig,'NumberTitle','off',...
                'MenuBar', 'none',...
                'ToolBar', 'none',...
                'Position',[885,386,480,350],...
                'Resize','off',...
                'Name','SUMO_Obj');
            
            obj.NearVehiclesPanel = uipanel('Units','pixels',...
                'Position',[47,126,127,214],...
                'Title','Near Vehicles');
            obj.NearVehicle = uicontrol(obj.NearVehiclesPanel,...
                'Style','listbox',...
                'Position',[15,16,100,170],...
                'String',{''},...
                'Tag','NearVehicle');
            
            obj.FollowerVehiclePanel = uipanel('Units','pixels',...
                'Position',[315,126,127,214],...
                'Title','Follower Vehicle');
            obj.FollowerVehicle = uicontrol(obj.FollowerVehiclePanel,...
                'Style','listbox',...
                'Position',[15,16,100,170],...
                'String',{''},...
                'Tag','FollowerVehicle');
            
            obj.JoinReq = uicontrol(obj.fig,'Style','pushbutton',...
                'Position',[61,27,100,22],...
                'Tag','JoinReq',...
                'String','Join',...
                'Enable','off');
            
            obj.LeaveReq = uicontrol(obj.fig,'Style','pushbutton',...
                'Position',[327,27,100,22],...
                'Tag','LeaveReq',...
                'String','Leave',...
                'Enable','off');
            
            obj.NearVehicle.Callback = {@NearVehicleCall,obj};
            obj.FollowerVehicle.Callback = {@FollowerVehicleCall,obj};
            obj.JoinReq.Callback = {@JoinReqCall,obj};
            obj.LeaveReq.Callback = {@LeaveReqCall,obj};
        end
    end
end


function LeaveReqCall(src,event,obj)
% global PlatoonGUI;
    global Leader;
    global Follower;
    RFGColor = color;
    value = obj.FollowerVehicle.Value;
    ID = obj.FollowerVehicle.String;
    if strcmp(ID{value},Leader.ID)
        Leader.sig = 2;
        traci.vehicle.setColor(ID{value},RFGColor.Brown);
        return
    end
    
    for idx = 1:numel(Follower)
        if strcmp(Follower(idx).ID,ID{value})
            Follower(idx).sig = 2;
            break;
%         elseif idx == numel(Follower)
%             error('LOSER, THERE IS SOMETHING WRONG');
        end
    end 
    traci.vehicle.setColor(ID{value},RFGColor.Brown);
end



function JoinReqCall(src,event,obj)
    global PlatoonGUI;
    global Leader;
    global Follower;
    
    RFGColor = color;

    value = obj.NearVehicle.Value;
    ID = obj.NearVehicle.String;
    
    if isa(Follower,'inf_veh')
        Follower(end+1)   = inf_veh(ID{value},Leader.Pos,Leader.Ang);
        Follower(end).sig = 1;
    else
        Follower        = inf_veh(ID{value},Leader.Pos,Leader.Ang);
        Follower(1).sig = 1;
    end
    traci.vehicle.setColor(ID{value},RFGColor.Brown);
end



function FollowerVehicleCall(src,event,obj)
obj.JoinReq.Enable = 'off';
obj.LeaveReq.Enable = 'on';
end


function NearVehicleCall(src,event,obj)
obj.JoinReq.Enable = 'on';
obj.LeaveReq.Enable = 'off';
end