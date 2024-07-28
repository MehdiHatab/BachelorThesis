classdef info_leader
    %INFO_LEADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        Platoon
        ID
        Vel
        Pos
        Ang
        Lane
        Distance = 0;
        signal    = communication;
        Follower  = communication;
        NewLeader = communication;
        Nr
        velocity
        Color = color;
        sig        = 0;
        InPlatoon  = 1;
    end
    
    methods (Access = public)
        function obj = info_leader(ID,velo)
            %INFO_LEADER Construct an instance of this class
            %   Detailed explanation goes here
            
            %obj.vel = traci.vehicle.getSpeed(ID);
            obj.ID       = ID;
            obj.velocity = velo;
            obj.Distance = traci.vehicle.getDistance(obj.ID);
%             obj.Vel  = traci.vehicle.getSpeed    (ID);
%             obj.Pos  = traci.vehicle.getPosition (ID);
%             obj.Ang  = traci.vehicle.getAngle    (ID);
%             obj.Lane = traci.vehicle.getLaneIndex(ID);
%             obj.Ang  = -(obj.Ang-90)*pi/180;
            %
%             laneID              = traci.vehicle.getLaneID   (ID);
%             EgoVMax(idxEgoCar,1)       = traci.lane.getMaxSpeed(laneID);
%             EgoNLaneWidth(idxEgoCar,1) = traci.lane.getWidth(laneID);

        end
        
        function obj = sendSignal(obj,ID,type)
            obj.signal.To{end+1}   = ID;
            obj.signal.Type(end+1) = type;
        end
        
        function obj = getSignal(obj,ID,ObjSig)
            obj.Follower.To   = ID;
            obj.Follower.Type = ObjSig;
        end
        
        function obj = update(obj)
%             obj.ID = ID;

            % set vehicle settings at the first time

            obj.Vel      = traci.vehicle.getSpeed    (obj.ID);
            obj.Pos      = traci.vehicle.getPosition (obj.ID);
            obj.Ang      = traci.vehicle.getAngle    (obj.ID);
            obj.Lane     = traci.vehicle.getLaneIndex(obj.ID);
            obj.Distance = traci.vehicle.getDistance(obj.ID);
            obj.Ang  = -(obj.Ang-90)*pi/180;
            %traci.vehicle.setColor(obj.ID,obj.Color.Green);
%             switch obj.signal
%                 case 0
%                     %nothing
%                 case 1
%                     traci.vehicle.setColor(obj.ID,obj.Color.Orange);
%                 case 2
%                     traci.vehicle.setColor(obj.ID,obj.Color.Pink);
%             end
        end
        
        function camera(obj)
            vid = traci.gui.getIDList();
            traci.gui.trackVehicle( vid{1}, obj.ID );   
%             traci.gui.setSchema( vid{1}, 'real world');
%             traci.gui.setZoom(vid{1}, 1000);
            traci.vehicle.setTau      ( obj.ID, 0    );
            traci.vehicle.setSpeedMode( obj.ID , 31    );
            %traci.vehicle.setAccel    ( obj.ID, 3 );
            %traci.vehicle.setDecel    ( obj.ID, 7 );
            %traci.vehicle.setMaxSpeed ( obj.ID, 40 );
            %traci.vehicle.setEmergencyDecel( obj.ID, 10);
            traci.vehicle.setColor(obj.ID,[0,255,0,255]);
        end
        
        function obj = getNewSpeed(obj,kT,Ts,V,r,v_old)
            NrOfFollower = numel(obj.Platoon);
            if NrOfFollower == 0
                obj.velocity.To(:) = '';
                obj.velocity.v(:) = [];
                return
            end

            for asd = 1:NrOfFollower
                ID(asd)     = {obj.Platoon(asd).ID};
                dx(asd)     = obj.Platoon(asd).dist(1);
                dy(asd)     = obj.Platoon(asd).dist(2);
                v(asd)      = obj.Platoon(asd).velo;
                sig(asd)    = obj.Platoon(asd).InPlatoon;
                lane(asd)   = obj.Platoon(asd).lane;
                Length(asd) = obj.Platoon(asd).Length;
            end
            global PlatoonGUI;
            global Follower;
            PlatoonGUI.FollowerVehicle.String = [{obj.ID}, ID];
            
            edx  = zeros(NrOfFollower,1);
            edy  = zeros(NrOfFollower,1);
            ed   = zeros(NrOfFollower,1);
            ev   = zeros(NrOfFollower,1);
            ref1 = ones(1,NrOfFollower)*r;
            a    = zeros(NrOfFollower,1);
            temp = zeros(NrOfFollower,1);
            
            v_leader = obj.Vel;
            idx1 = find(dx <= 0);
            idx2 = find(dx > 0);

            
            if ~isempty(idx1)
                %d = sqrt(dx(idx1).^2 + dy(idx1).^2);
                d = sqrt(dx(idx1).^2);
                [~,sortIdx] = sort(d);
                sortIdx = idx1(sortIdx);
                switch length(sortIdx)
                    case 1
                        edx(sortIdx) = dx(sortIdx) + Length(sortIdx);
                        edy(sortIdx) = dy(sortIdx);
                        ev(sortIdx)  = v(sortIdx) - v_leader;
                        %ed(sortIdx)  = -sqrt(edx(sortIdx).^2 + edy(sortIdx).^2);
                        ed(sortIdx)  = -sqrt(edx(sortIdx).^2);
                    otherwise
                        edx(sortIdx(1)) = dx(sortIdx(1)) + Length(sortIdx(1));
                        edy(sortIdx(1)) = dy(sortIdx(1));
                        edx([sortIdx(2:end)]) = dx([sortIdx(2:end)]) - dx([sortIdx(1:end-1)]) + Length([sortIdx(2:end)]);
                        edy([sortIdx(2:end)]) = dy([sortIdx(2:end)]) - dy([sortIdx(1:end-1)]);

                        ev(sortIdx(1)) = v(sortIdx(1)) - v_leader;
                        ev([sortIdx(2:end)]) = v([sortIdx(2:end)]) - v([sortIdx(1:end-1)]);

                        %ed(sortIdx)  = -sqrt(edx(sortIdx).^2 + edy(sortIdx).^2);
                        ed(sortIdx)  = -sqrt(edx(sortIdx).^2);
                end
                
                idx3 = find(sig == 2);
                for idx5 = idx3
                    idx4 = find(sortIdx == idx5);
                    if lane(idx5) ~= 0 & (length(sortIdx) == 1 | idx4 == length(sortIdx))
                        r1 = 15;
                        er = -r1 - ed(sortIdx(idx4))
                        if ed(sortIdx(idx4)) + r1 <= 1
                            obj = obj.sendSignal(ID{idx5},101);
                        end
                        temp1 = r1-abs(r);
                        %ed(sortIdx(idx4)) = ed(sortIdx(idx4)) + temp1;  
                        ref1(sortIdx(idx4)) = -abs(r1);
                    elseif lane(idx5) ~= 0  & length(sortIdx) ~= 1 & idx4 ~= length(sortIdx)
                        r1 = 15;
                        r2 = 2*r1 + Length(sortIdx(idx4));
                        temp1 = r1-abs(r);
                        temp2 = r2-abs(r);
                        asd = sortIdx(idx4+1);
                        temp(asd) = 1;
                        if (idx4-1) ==  0
                            ed(asd) = dx(asd) + Length(asd);
                            ed(asd) = -abs(ed(asd));
                            ev(asd)  = v(asd) - v_leader;
                        else
                            ed(asd) = dx(asd) - dx(sortIdx(idx4-1))...
                                + Length(asd);
                            ed(asd) = -abs(ed(asd));
                            ev(asd) = v(asd) - v([sortIdx(idx4-1)]);
                        end
                        %er1 = (-r1 - ed(sortIdx(idx4)));
                        %er2 = (-r2 - ed(asd));
                        if ed(sortIdx(idx4)) + r1 <= 1 & ed(asd) + r1 <= 1
                            zxcasd = 1
                            obj = obj.sendSignal(ID{idx5},101);
                        end
%                         ed(sortIdx(idx4)) = ed(sortIdx(idx4)) + temp1;
%                         ed(asd) = ed(asd) + temp2;
                        ref1(sortIdx(idx4)) = -abs(r1);
                        fprintf('error speed %d\n',ev(sortIdx(idx4)))
                        if ev(sortIdx(idx4)) <= 1
                            ref1(asd) = -abs(r2);
                        end
                        %sortIdx(asd)
                        %sortIdx(sortIdx(idx4))
                        
                    end
                end

                idx3 = find(sig == 3);
                idx3
                for idx5 = idx3
                    idx4 = find(sortIdx == idx5);
                    if lane(idx5) == 0 & (length(sortIdx) == 1 | idx4 == length(sortIdx))
                        r1 = 15;
                        er = -r1 - ed(sortIdx(idx4));
                        if ed(sortIdx(idx4)) + r1 <= 1
                            obj = obj.sendSignal(ID{idx5},102);
                        end
                        temp1 = r1-abs(r);
                        %ed(sortIdx(idx4)) = ed(sortIdx(idx4)) + temp1;
                        ref1(sortIdx(idx4)) = -abs(r1);
                    elseif lane(idx5) == 0  & length(sortIdx) ~= 1 & idx4 ~= length(sortIdx)
                        r1 = 15;
                        r2 = 15;
                        temp1 = r1-abs(r);
                        temp2 = r2-abs(r);
                        asd = sortIdx(idx4+1);
                        %er1 = (-r1 - ed(sortIdx(idx4)))
                        %er2 = (-r2 - ed(asd))
                        if ed(sortIdx(idx4)) + r1 <= 1 & ed(asd) + r1 <= 1
                            zxcasd = 1
                            obj = obj.sendSignal(ID{idx5},102);
                        end
                        %ed(sortIdx(idx4)) = ed(sortIdx(idx4)) + temp1;
                        %ed(asd) = ed(asd) + temp2;
                        ref1(sortIdx(idx4)) = -abs(r1);
                        ref1(asd) = -abs(r2);
                        %sortIdx(asd)
                        %sortIdx(sortIdx(idx4))
                        
                    end
                end
                
                if obj.InPlatoon == 3
                    r1 = 15;
                    ref1(sortIdx(1)) = -abs(r1);
                end
                
                
                if obj.InPlatoon == 3 && ed(sortIdx(1)) - ref1(sortIdx(1)) <= 1 
                    traci.vehicle.changeLane(obj.ID,1,5)
                    if traci.vehicle.getLaneIndex(obj.ID) ~= 0
                        obj.NewLeader.To = ID(sortIdx(1));
                        obj.NewLeader.Type = 1000;
                    end
                end
                for idx6 = 1:numel(ID)
                    if lane(idx6) == 0 & abs(-ed(idx6)+r) <= 1 & sig(idx6) == 2
                        for idx7 = 1:numel(Follower)
                            if strcmp(Follower(idx7).ID,ID{idx6})
                                Follower(idx7).InPlatoon = 1;
                                traci.vehicle.setColor(ID{idx6},obj.Color.Blue);
                                break;
                            end
                        end
                    end
                end
%                 ed = min(ed,-4);
                a_leader = (obj.Vel-v_old)/Ts;
                ref1
                for m = 1:NrOfFollower
                    if sortIdx(m) == sortIdx(1)
                        a(sortIdx(m)) = -kT*[ed(sortIdx(m));ev(sortIdx(m))] + ...
                            V*ref1(sortIdx(m)) + a_leader;
                    else
                        if temp(sortIdx(m)) == 1 & lane(sortIdx(m)) == 0
                            a(sortIdx(m)) = -kT*[ed(sortIdx(m));ev(sortIdx(m))] +...
                                V*ref1(sortIdx(m)) + a(sortIdx(m-2));
                        else
                            a(sortIdx(m)) = -kT*[ed(sortIdx(m));ev(sortIdx(m))] +...
                                V*ref1(sortIdx(m)) + a(sortIdx(m-1));
                        end
                    end
                end
%                 y = [ed,ev]';
%                 a = -kT*y + V*ref1;
                
                %a = PD(ed,r,Ts);
                %a = PD(ed,ref1',Ts);

%                 if ~isempty(idx3)
%                     a(idx3) = min(3,max(a(idx3),-3));
%                 end
                a = a(:);
%                 a = a + [a_leader;a(1:end-1)];
                v = v(:);
                a = min(3,max(a,-5));
                obj.velocity.To = ID;
                v_new = a*Ts + v;
%                 v_new = min(v_leader+5,max(v_new,15));
                v_new'
                obj.velocity.v = v_new;
            end
            
            if ~isempty(idx2)
                d = sqrt(dx(idx2).^2 + dy(idx2).^2);
                [~,sortIdx] = sort(d);
                sortIdx = idx2(sortIdx);
                switch length(sortIdx)
                    case 1
                        edx(sortIdx) = dx(sortIdx);
                        edy(sortIdx) = dy(sortIdx);
                        ev(sortIdx)  = v(sortIdx) - v_leader;
                        ed(sortIdx)  = sqrt(edx(sortIdx).^2 + edy(sortIdx).^2);
                    otherwise
                        edx(sortIdx(1)) = dx(sortIdx(1));
                        edy(sortIdx(1)) = dy(sortIdx(1));
                        edx([sortIdx(2:end)]) = dx([sortIdx(2:end)]) - dx([sortIdx(1:end-1)]);
                        edy([sortIdx(2:end)]) = dy([sortIdx(2:end)]) - dy([sortIdx(1:end-1)]);

                        ev(sortIdx(1)) = v(sortIdx(1)) - v_leader;
                        ev([sortIdx(2:end)]) = v([sortIdx(2:end)]) - v([sortIdx(1:end-1)]);

                        ed(sortIdx)  = sqrt(edx(sortIdx).^2 + edy(sortIdx).^2)-13;
                end
                y = [ed,ev]';
                a = -kT*y + V*r;

                a = min(3,max(a,-5));
                obj.velocity.To = ID;
                v_new = a*Ts + v;;
                v_new = min(27,max(v_new,15));
                obj.velocity.v = v_new;
            end

        end
    end
end

function u = PD(ed,r,Ts)
persistent temp;
if isempty(temp)
    temp = zeros(size(ed));
end

if length(temp) < length(ed)
    temp = [temp;0];
elseif length(temp) > length(ed)
    temp = temp(1:end-1);
end

e0 = r-temp;
e1 = r-ed;

kp = 1.1;
kd = 2;
N = 30*Ts;
a = Ts/(Ts+N);
 u = kp*e1 + kd*(e1/a - (1-a)*e0/a);
%u = kp*e1 + kd*(e1-e0)/Ts;
u
temp(:) = ed;
end
