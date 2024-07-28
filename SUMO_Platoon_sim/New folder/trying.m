function [outputArg1] = trying(inputArg1)

persistent loser;
if nargin == 1
    loser = inputArg1;
    return
elseif nargin == 0
    outputArg1 = loser;
end

end

