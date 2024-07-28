classdef SUMO_Obj < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        SUMO_ObjUIFigure       matlab.ui.Figure
        NearVehiclesPanel      matlab.ui.container.Panel
        NearVehicle            matlab.ui.control.ListBox
        FollowerVehiclesPanel  matlab.ui.container.Panel
        FollowerVehicle        matlab.ui.control.ListBox
        joinReq                matlab.ui.control.Button
        leaveReq               matlab.ui.control.Button
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create SUMO_ObjUIFigure
            app.SUMO_ObjUIFigure = uifigure;
            app.SUMO_ObjUIFigure.IntegerHandle = 'on';
            app.SUMO_ObjUIFigure.Position = [8812 355 500 383];
            app.SUMO_ObjUIFigure.Name = 'SUMO_Obj';
            app.SUMO_ObjUIFigure.Resize = 'off';
            app.SUMO_ObjUIFigure.BusyAction = 'cancel';
            app.SUMO_ObjUIFigure.Interruptible = 'off';

            % Create NearVehiclesPanel
            app.NearVehiclesPanel = uipanel(app.SUMO_ObjUIFigure);
            app.NearVehiclesPanel.Title = 'Near Vehicles';
            app.NearVehiclesPanel.Position = [78 159 127 214];

            % Create NearVehicle
            app.NearVehicle = uilistbox(app.NearVehiclesPanel);
            app.NearVehicle.Items = {};
            app.NearVehicle.Position = [13 16 102 165];
            app.NearVehicle.Value = {};

            % Create FollowerVehiclesPanel
            app.FollowerVehiclesPanel = uipanel(app.SUMO_ObjUIFigure);
            app.FollowerVehiclesPanel.Title = 'Follower Vehicles';
            app.FollowerVehiclesPanel.Position = [315 159 124 214];

            % Create FollowerVehicle
            app.FollowerVehicle = uilistbox(app.FollowerVehiclesPanel);
            app.FollowerVehicle.Items = {};
            app.FollowerVehicle.Position = [15 16 93 165];
            app.FollowerVehicle.Value = {};

            % Create joinReq
            app.joinReq = uibutton(app.SUMO_ObjUIFigure, 'push');
            app.joinReq.Position = [82 29 100 22];
            app.joinReq.Text = 'Join';

            % Create leaveReq
            app.leaveReq = uibutton(app.SUMO_ObjUIFigure, 'push');
            app.leaveReq.Position = [335 29 100 22];
            app.leaveReq.Text = 'Leave';
        end
    end

    methods (Access = public)

        % Construct app
        function app = SUMO_Obj

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.SUMO_ObjUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.SUMO_ObjUIFigure)
        end
    end
end