classdef LeaderGUI_ver2
    
    properties
        fig
        FollowerVehicle
        FollowerVehiclePanel
        TextMessage
        AcceptReq
        DeclineReq
    end
    
    methods
        function obj = LeaderGUI_ver2()
            obj.fig = figure;
            set(obj.fig,'NumberTitle','off',...
                'MenuBar', 'none',...
                'ToolBar', 'none',...
                'Position',[959,42,407,320],...
                'Resize','off',...
                'Name','Leader');
            
            obj.FollowerVehiclePanel = uipanel('Units','pixels',...
                'Position',[142,98,127,214],...
                'Title','Follower Vehicle');
            obj.FollowerVehicle = uicontrol(obj.FollowerVehiclePanel,...
                'Style','listbox',...
                'Position',[13,16,100,165],...
                'String',{''},...
                'Tag','FollowerVehicle');
            
            obj.AcceptReq = uicontrol(obj.fig,'Style','pushbutton',...
                'Position',[21,11,100,22],...
                'Tag','AcceptReq',...
                'String','Accept',...
                'Enable','off');
            
            obj.DeclineReq = uicontrol(obj.fig,'Style','pushbutton',...
                'Position',[290,11,100,22],...
                'Tag','DeclineReq',...
                'String','Decline',...
                'Enable','off');
            
            obj.TextMessage = uicontrol(obj.fig,'Style','text',...
                'Position',[21,48,369,35],...
                'String','');
            
            obj.FollowerVehicle.Callback = {@FollowerVehicleCall,obj};
            obj.AcceptReq.Callback = {@AcceptReqCall,obj};
            obj.DeclineReq.Callback = {@DeclineReqCall,obj};
        end
    end
end


function DeclineReqCall(src,event,obj)
global checkSignal;
    % global PlatoonGUI;
    % global FollowerGUI;
    global Leader;
    % global Follower;
    persistent temp;
    
    if isempty(temp)
        temp = 0;
    end
    
    if temp == 1
        Leader = Leader.getSignal('',0)
        SOMETHING_IS_WRONG = 1
        obj.TextMessage.String = '';
        temp  = 0;
        checkSignal = 0;
        obj.AcceptReq.Enable = 'off';
        obj.DeclineReq.Enable = 'off';
        obj.TextMessage.String
        obj.AcceptReq.Enable
        obj.DeclineReq.Enable
        pause(0.005)
        drawnow
        return
    end
    
    
    if strcmp(Leader.ID,Leader.Follower.To)
        
        traci.vehicle.setColor(Leader.ID,Leader.Color.Green);

        Leader.sig = 0;
        Leader.InPlatoon = 1;
        Leader = Leader.getSignal('',0);
        temp  = 1;
        obj.TextMessage.String = '';
        checkSignal = 0;
        obj.AcceptReq.Enable = 'off';
        obj.DeclineReq.Enable = 'off';
        return
    end
    % 
    % % 
    % % UD = get(handles.output,'UserData');
    % asd = cell(numel(Leader.Platoon),1);
    % asd(:) = {''};
    % 
    % for zxc = 1:numel(Leader.Platoon)
    %     asd(zxc) = {Leader.Platoon(zxc).ID};
    % end

%     for m = 1:numel(Follower)
%         if strcmp(Follower(m).ID,Leader.Follower.To)
%             idx = m;
%             break
%         end
%     end

    % if ismember(Leader.Follower.To,asd)
    %     Leader = Leader.getSignal('',0);
    % 
    %     set(handles.textMessage,'String','');
    %     checkSignal = 0;
    %     set(handles.acceptReq ,'Enable','off');
    %     set(handles.declineReq,'Enable','off');
    %     return
    % end

    switch Leader.Follower.Type
    case 0
        %nothing
    case 1
        Leader = Leader.sendSignal(Leader.Follower.To,4);

        Leader = Leader.getSignal('',0);
        STUPID = 10
        obj.TextMessage.String = '';
        temp  = 1
        checkSignal = 0
        obj.AcceptReq.Enable = 'off';
        obj.DeclineReq.Enable = 'off';
        pause(0.005)
    case 2
        if strcmp(Leader.ID,Leader.Follower.To)
            Leader = Leader.getSignal('',0);
            Leader = Leader.sendSignal(Leader.Follower.To,4);
            temp  = 1;
            obj.TextMessage.String = '';
            checkSignal = 0;

            obj.AcceptReq.Enable = 'off';
            obj.DeclineReq.Enable = 'off';
        else 
            Leader = Leader.sendSignal(Leader.Follower.To,4);

            Leader = Leader.getSignal('',0);
            temp  = 1;
            obj.TextMessage.String = '';

            LOSER = 256
            checkSignal = 0;

            obj.AcceptReq.Enable = 'off';
            obj.DeclineReq.Enable = 'off';
        end
        pause(0.005)
    case 20
        Leader = Leader.sendSignal(Leader.Follower.To,4);

        Leader = Leader.getSignal('',0);
        temp  = 1;
        obj.TextMessage.String = '';

        LOSER = 256
        checkSignal = 0;

        obj.AcceptReq.Enable = 'off';
        obj.DeclineReq.Enable = 'off';
        pause(0.005)
%     case 20
%         tempID = Leader.ID;
%         Leader.ID = Follower(idx).ID;
%         Leader = Leader.update;
%         Follower(idx) = [];
%         Follower(end+1) = inf_veh(tempID,Leader.Pos,Leader.Ang);
%         Follower(end).InPlatoon = 1;
% 
%         Leader.Platoon(end+1) = Follower(end);
%         Leader = Leader.getSignal('',0);
%         Leader.camera;
%         loser = 5
% 
%         obj.fig.Name = Leader.ID;
% 
% 
%         obj.TextMessage.String = '';
%         checkSignal = 0;
%         obj.AcceptReq.Enable = 'off';
%         obj.DeclineReq.Enable = 'off';    
    end
end



function AcceptReqCall(src,event,obj)
    global checkSignal;
    % global PlatoonGUI;
    % global FollowerGUI;
    global Leader;
    global Follower;
    persistent temp;
    
    
    if isempty(temp)
        temp = 0;
    end
    
    if temp == 1
        Leader = Leader.getSignal('',0);

        obj.TextMessage.String = '';
        temp  = 0;
        checkSignal = 0;
        obj.AcceptReq.Enable = 'off';
        obj.DeclineReq.Enable = 'off';
        return
    end
    
    if strcmp(Leader.ID,Leader.Follower.To)
        
        traci.vehicle.setColor(Leader.ID,Leader.Color.Violet);

        Leader.sig = 0;
        Leader.InPlatoon = 3;
        Leader = Leader.getSignal('',0);
        temp  = 1;
        obj.TextMessage.String = '';
        checkSignal = 0;
        obj.AcceptReq.Enable = 'off';
        obj.DeclineReq.Enable = 'off';
        return
    end

    asd = cell(numel(Leader.Platoon),1);
    asd(:) = {''};

    for zxc = 1:numel(Leader.Platoon)
        asd(zxc) = {Leader.Platoon(zxc).ID};
    end

    for m = 1:numel(Follower)
        if strcmp(Follower(m).ID,Leader.Follower.To)
            idx = m;
            break
        end
    end

    if ismember(Leader.Follower.To,asd) && Leader.Follower.Type ~= 2
        Leader = Leader.getSignal('',0);

        obj.TextMessage.String = '';
        checkSignal = 0;
        obj.AcceptReq.Enable = 'off';
        obj.DeclineReq.Enable = 'off';
        temp  = 1;
        return
    end

    switch Leader.Follower.Type
    case 0
        %nothing
    case 1
        Leader = Leader.sendSignal(Leader.Follower.To,3);

        Leader = Leader.getSignal('',0);
        temp  = 1;
        obj.TextMessage.String = '';
        checkSignal = 0;
        obj.AcceptReq.Enable = 'off';
        obj.DeclineReq.Enable = 'off';
    case 2
        Leader = Leader.sendSignal(Leader.Follower.To,3);

        Leader = Leader.getSignal('',0);

        temp  = 1;
        obj.TextMessage.String = '';
        checkSignal = 0;
        obj.AcceptReq.Enable = 'off';
        obj.DeclineReq.Enable = 'off';
    case 20
        tempID = Leader.ID;
        Leader.ID = Follower(idx).ID;
        Leader = Leader.update;
        Follower(idx) = [];
        Follower(end+1) = inf_veh(tempID,Leader.Pos,Leader.Ang);
        Follower(end).InPlatoon = 1;
        traci.vehicle.setColor(Follower(end).ID,Follower(end).Color.Blue);

        Leader.Platoon(end+1) = Follower(end);
        Leader = Leader.getSignal('',0);
        Leader.camera;
        temp  = 1;

        obj.fig.Name = Leader.ID;

        obj.TextMessage.String = '';
        checkSignal = 0;
        obj.AcceptReq.Enable = 'off';
        obj.DeclineReq.Enable = 'off';
    end
end



function FollowerVehicleCall(src,event,obj)

end


