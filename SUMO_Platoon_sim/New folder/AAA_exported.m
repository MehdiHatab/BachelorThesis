classdef AAA_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        LeaveButton         matlab.ui.control.Button
        LeaveButton_2       matlab.ui.control.Button
        LeaveButton_3       matlab.ui.control.Button
        IDEditField_2Label  matlab.ui.control.Label
        IDEditField_2       matlab.ui.control.EditField
        IDEditField_3Label  matlab.ui.control.Label
        IDEditField_3       matlab.ui.control.EditField
        JoinButton          matlab.ui.control.Button
        JoinButton_2        matlab.ui.control.Button
        JoinButton_3        matlab.ui.control.Button
        LeaveButton_4       matlab.ui.control.Button
        JoinButton_4        matlab.ui.control.Button
        JoinButton_5        matlab.ui.control.Button
        LeaveButton_5       matlab.ui.control.Button
        IDEditField_4Label  matlab.ui.control.Label
        IDEditField_4       matlab.ui.control.EditField
        IDEditField_5Label  matlab.ui.control.Label
        IDEditField_5       matlab.ui.control.EditField
        JoinButton_6        matlab.ui.control.Button
        LeaveButton_6       matlab.ui.control.Button
        IDEditField_6Label  matlab.ui.control.Label
        IDEditField_6       matlab.ui.control.EditField
        IDEditField_7Label  matlab.ui.control.Label
        IDEditField_7       matlab.ui.control.EditField
    end

    methods (Access = private)

        % Button pushed function: JoinButton
        function JoinButtonPushed(app, event)
            for l = 1:0.5:30
                traci.vehicle.setSignals('x',13);
            end
        end

        % Callback function
        function SwitchValueChanged(app, event)
            global s;
            s = 5;
            value = app.Switch.Value;
            qwe = str2double(value);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 590 476];
            app.UIFigure.Name = '123';

            % Create LeaveButton
            app.LeaveButton = uibutton(app.UIFigure, 'push');
            app.LeaveButton.Position = [132 382 100 22];
            app.LeaveButton.Text = 'Leave';

            % Create LeaveButton_2
            app.LeaveButton_2 = uibutton(app.UIFigure, 'push');
            app.LeaveButton_2.Position = [132 340 100 22];
            app.LeaveButton_2.Text = 'Leave';

            % Create LeaveButton_3
            app.LeaveButton_3 = uibutton(app.UIFigure, 'push');
            app.LeaveButton_3.Position = [132 298 100 22];
            app.LeaveButton_3.Text = 'Leave';

            % Create IDEditField_2Label
            app.IDEditField_2Label = uilabel(app.UIFigure);
            app.IDEditField_2Label.HorizontalAlignment = 'right';
            app.IDEditField_2Label.Position = [298 340 25 22];
            app.IDEditField_2Label.Text = 'ID';

            % Create IDEditField_2
            app.IDEditField_2 = uieditfield(app.UIFigure, 'text');
            app.IDEditField_2.Position = [338 340 234 22];

            % Create IDEditField_3Label
            app.IDEditField_3Label = uilabel(app.UIFigure);
            app.IDEditField_3Label.HorizontalAlignment = 'right';
            app.IDEditField_3Label.Position = [298 298 25 22];
            app.IDEditField_3Label.Text = 'ID';

            % Create IDEditField_3
            app.IDEditField_3 = uieditfield(app.UIFigure, 'text');
            app.IDEditField_3.Position = [338 298 234 22];

            % Create JoinButton
            app.JoinButton = uibutton(app.UIFigure, 'push');
            app.JoinButton.ButtonPushedFcn = createCallbackFcn(app, @JoinButtonPushed, true);
            app.JoinButton.Position = [10 382 100 22];
            app.JoinButton.Text = 'Join';

            % Create JoinButton_2
            app.JoinButton_2 = uibutton(app.UIFigure, 'push');
            app.JoinButton_2.Position = [10 340 100 22];
            app.JoinButton_2.Text = 'Join';

            % Create JoinButton_3
            app.JoinButton_3 = uibutton(app.UIFigure, 'push');
            app.JoinButton_3.Position = [10 298 100 22];
            app.JoinButton_3.Text = 'Join';

            % Create LeaveButton_4
            app.LeaveButton_4 = uibutton(app.UIFigure, 'push');
            app.LeaveButton_4.Position = [131 256 100 22];
            app.LeaveButton_4.Text = 'Leave';

            % Create JoinButton_4
            app.JoinButton_4 = uibutton(app.UIFigure, 'push');
            app.JoinButton_4.Position = [9 256 100 22];
            app.JoinButton_4.Text = 'Join';

            % Create JoinButton_5
            app.JoinButton_5 = uibutton(app.UIFigure, 'push');
            app.JoinButton_5.Position = [10 214 100 22];
            app.JoinButton_5.Text = 'Join';

            % Create LeaveButton_5
            app.LeaveButton_5 = uibutton(app.UIFigure, 'push');
            app.LeaveButton_5.Position = [132 214 100 22];
            app.LeaveButton_5.Text = 'Leave';

            % Create IDEditField_4Label
            app.IDEditField_4Label = uilabel(app.UIFigure);
            app.IDEditField_4Label.HorizontalAlignment = 'right';
            app.IDEditField_4Label.Position = [299 256 25 22];
            app.IDEditField_4Label.Text = 'ID';

            % Create IDEditField_4
            app.IDEditField_4 = uieditfield(app.UIFigure, 'text');
            app.IDEditField_4.Position = [339 256 233 22];

            % Create IDEditField_5Label
            app.IDEditField_5Label = uilabel(app.UIFigure);
            app.IDEditField_5Label.HorizontalAlignment = 'right';
            app.IDEditField_5Label.Position = [298 214 25 22];
            app.IDEditField_5Label.Text = 'ID';

            % Create IDEditField_5
            app.IDEditField_5 = uieditfield(app.UIFigure, 'text');
            app.IDEditField_5.Position = [338 214 234 22];

            % Create JoinButton_6
            app.JoinButton_6 = uibutton(app.UIFigure, 'push');
            app.JoinButton_6.Position = [10 172 100 22];
            app.JoinButton_6.Text = 'Join';

            % Create LeaveButton_6
            app.LeaveButton_6 = uibutton(app.UIFigure, 'push');
            app.LeaveButton_6.Position = [132 172 100 22];
            app.LeaveButton_6.Text = 'Leave';

            % Create IDEditField_6Label
            app.IDEditField_6Label = uilabel(app.UIFigure);
            app.IDEditField_6Label.HorizontalAlignment = 'right';
            app.IDEditField_6Label.Position = [298 172 25 22];
            app.IDEditField_6Label.Text = 'ID';

            % Create IDEditField_6
            app.IDEditField_6 = uieditfield(app.UIFigure, 'text');
            app.IDEditField_6.Position = [338 172 234 22];

            % Create IDEditField_7Label
            app.IDEditField_7Label = uilabel(app.UIFigure);
            app.IDEditField_7Label.HorizontalAlignment = 'right';
            app.IDEditField_7Label.Position = [299 382 25 22];
            app.IDEditField_7Label.Text = 'ID';

            % Create IDEditField_7
            app.IDEditField_7 = uieditfield(app.UIFigure, 'text');
            app.IDEditField_7.Position = [339 382 233 22];
        end
    end

    methods (Access = public)

        % Construct app
        function app = AAA_exported

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end