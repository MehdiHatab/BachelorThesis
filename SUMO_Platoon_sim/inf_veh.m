classdef inf_veh
    %INF_VEH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        dist
        velo
        ang
        sig        = 0;
        lane
        ID         = '';
        InPlatoon  = 0;
        findLeader = 0;
        Nr
        Length
        Distance = 0;
        leader = 0;
        Color = color;
        CO2
        CO
        Fuel
        HC
        Noise
        NOx
        PMx
    end
    
    methods (Access = public)
        function obj = inf_veh(ID,RefPosLeader,RefAngLeader)
            %INF_VEH Construct an instance of this class
            %   Detailed explanation goes here
%             obj.Property1 = inputArg1 + inputArg2;
            obj.ID       = ID;
            pos          = traci.vehicle.getPosition (ID);
            obj.ang      = traci.vehicle.getAngle    (ID);
            obj.velo     = traci.vehicle.getSpeed    (ID);
            %obj.sig     = traci.vehicle.getSignals  (ID);
            obj.lane     = traci.vehicle.getLaneIndex(ID);
            obj.Length   = traci.vehicle.getLength(ID);
            obj.CO2      = traci.vehicle.getCO2Emission(obj.ID);
            obj.CO       = traci.vehicle.getCOEmission(obj.ID);
            obj.Fuel     = traci.vehicle.getFuelConsumption(obj.ID);
            obj.HC       = traci.vehicle.getHCEmission(obj.ID);
            obj.Noise    = traci.vehicle.getNoiseEmission(obj.ID);
            obj.NOx      = traci.vehicle.getNOxEmission(obj.ID);
            obj.PMx      = traci.vehicle.getPMxEmission(obj.ID);
            obj.Distance = traci.vehicle.getDistance(obj.ID);
%             traci.vehicle.setColor(ID,[255,128,0,255]);

            DistXY        = pos - RefPosLeader;

            % calculate angle (rad) from angle (compass) of ego vehicle
            % in order to project vectors to ego vehicle coordinate system
            RotAng     = RefAngLeader;
            % calculate rotation matrix to bring world coordinates/vectors to 
            % ego vehicle coordinate system
            RotMat     = [ cos(RotAng), sin(RotAng);...
                          -sin(RotAng), cos(RotAng) ];
            % distance vector in ego coordinate system             
            obj.dist = (RotMat*DistXY')';

            % absolute vector of velocity in ego coordinate system
            obj.ang  = -(obj.ang-90)*pi/180;
            
        end
        
        function obj = searchLeader(obj) 

            L = sqrt(obj.dist(1)^2+obj.dist(2)^2);
            if L <= 300
                obj = obj.JoinReq;
                obj.findLeader = 0;
                traci.vehicle.setColor(obj.ID,[255,0,0,255]);
            else
                obj.sig = 0;
                obj.findLeader = 1;
                traci.vehicle.setColor(obj.ID,[255,128,0,255]);
            end
            
        end
        
        function obj = JoinReq(obj)
            obj.sig = 1;
        end

        function obj = LeaveReq(obj)
            obj.sig = 2;
        end
        
        function obj = SetSpeed(obj,v,ID)
            if ~strcmp(obj.ID,ID)
                error('NOT THE SAME ID');
            end
            traci.vehicle.slowDown  (ID,v,1.5);
%             traci.vehicle.setSpeed  (ID,v);
            traci.vehicle.setSpeedMode( obj.ID, 31);
            traci.vehicle.setMaxSpeed ( obj.ID, 35 );
            traci.vehicle.setSpeedFactor ( obj.ID, 2 );
            %traci.vehicle.setSpeed  (ID,v);
%             traci.vehicle.changeLane( ID, 0,20);
%             traci.vehicle.setLaneChangeMode(ID,0);
        end
        
        function obj = UpdateInfo(obj,RefPosLeader,RefAngLeader)

            pos          = traci.vehicle.getPosition (obj.ID);
            obj.ang      = traci.vehicle.getAngle    (obj.ID);
            obj.velo     = traci.vehicle.getSpeed    (obj.ID);
%             obj.sig  = traci.vehicle.getSignals  (obj.ID);
            obj.lane     = traci.vehicle.getLaneIndex(obj.ID);
            obj.Distance = traci.vehicle.getDistance(obj.ID);
%             traci.vehicle.setColor(ID,[255,128,0,255]);

            DistXY   = pos - RefPosLeader;

            RotAng   = RefAngLeader;

            RotMat   = [ cos(RotAng), sin(RotAng);...
                        -sin(RotAng), cos(RotAng) ];           
            obj.dist = (RotMat*DistXY')';

            obj.ang  = -(obj.ang-90)*pi/180;
            
            obj.CO2   = traci.vehicle.getCO2Emission(obj.ID);
            obj.CO    = traci.vehicle.getCOEmission(obj.ID);
            obj.Fuel  = traci.vehicle.getFuelConsumption(obj.ID);
            obj.HC    = traci.vehicle.getHCEmission(obj.ID);
            obj.Noise = traci.vehicle.getNoiseEmission(obj.ID);
            obj.NOx   = traci.vehicle.getNOxEmission(obj.ID);
            obj.PMx   = traci.vehicle.getPMxEmission(obj.ID);
            if obj.findLeader == 1
                obj = obj.searchLeader;
            end
            
%             if obj.InPlatoon == 1
%                 traci.vehicle.setColor(obj.ID,[0,0,255,255]);
%             end
        end
        
        function obj = setParameter(obj)
            
            traci.vehicle.setTau      ( obj.ID, 0  );
            traci.vehicle.setSpeedMode( obj.ID, 31    );
           % traci.vehicle.setAccel    ( obj.ID, 3 );
            % traci.vehicle.setAccel    ( obj.ID, 1000 );
          %  traci.vehicle.setDecel    ( obj.ID, 7 );
          %  traci.vehicle.setMaxSpeed ( obj.ID, 30 );
       %     traci.vehicle.setEmergencyDecel( obj.ID, 10);
%             traci.vehicle.slowDown    ( obj.ID, v_new(dummy),0.1);
%             traci.vehicle.changeLane  ( obj.ID, 0,10);
        end
    end
end

