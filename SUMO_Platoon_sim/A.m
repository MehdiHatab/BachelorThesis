classdef A
   properties
      x
      y
      InPlatoon
      Color = color;
   end
   methods
      function obj = A(x)
            obj.InPlatoon = x;
            obj.x = x+3;
      end
      function obj = update(obj)
          obj.x = obj.x + 1;
      end
   end
end