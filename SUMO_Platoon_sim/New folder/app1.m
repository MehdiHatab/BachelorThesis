
classdef app1 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure       matlab.ui.Figure
        JoinButton     matlab.ui.control.Button
        LeaveButton    matlab.ui.control.Button
        AcceptButton   matlab.ui.control.Button
        DeclineButton  matlab.ui.control.Button
    end
    methods (Access = public)

        % Button pushed function: JoinButton
        function JoinButtonPushed(app, event)
            Join_Req = 1;
        end

        % Button pushed function: LeaveButton
        function LeaveButtonPushed(app, event)
            Leave_Req = 1;
        end

        % Button pushed function: AcceptButton
        function A = AcceptButtonPushed(app, event)
            A = 1
            Join_Req = 0;
        end

        % Button pushed function: DeclineButton
        function DeclineButtonPushed(app, event)
            Decline_Req = 1;
        end
    end

    % App initialization and construction
    methods (Access = public)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';

            % Create JoinButton
            app.JoinButton = uibutton(app.UIFigure, 'push');
            app.JoinButton.ButtonPushedFcn = createCallbackFcn(app, @JoinButtonPushed, true);
            app.JoinButton.Position = [191 389 100 22];
            app.JoinButton.Text = 'Join';

            % Create LeaveButton
            app.LeaveButton = uibutton(app.UIFigure, 'push');
            app.LeaveButton.Position = [191 317 100 22];
            app.LeaveButton.Text = 'Leave';

            % Create AcceptButton
            app.AcceptButton = uibutton(app.UIFigure, 'push');
            app.AcceptButton.Position = [191 245 100 22];
            app.AcceptButton.Text = 'Accept';

            % Create DeclineButton
            app.DeclineButton = uibutton(app.UIFigure, 'push');
            app.DeclineButton.Position = [191 173 100 22];
            app.DeclineButton.Text = 'Decline';
        end
    end

    methods (Access = public)

        % Construct app
        function app = app1

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