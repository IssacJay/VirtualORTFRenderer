classdef VirtualMicrophone < audioPlugin & matlab.System                        
    properties
        %Microphone Array Properties
        X_Spacing = 0; 
        Y_Spacing = 17; 
        MicAngle = 110; 
        %Source Direction Properties
        Azimuth = 0;
        Elevation = 0; 
        Gain = 1;
    end
    properties (Access=private)
        bool = false;
        Resp = zeros(4,4);
        MicArray = MicrophoneArray(0, 0.17, 110); 
    end

    properties (Constant)
        PluginInterface = audioPluginInterface( ...         
            audioPluginParameter('Y_Spacing', 'DisplayName','Mic Y Spacing', ...
                'Mapping',{'int',0, 50}),...
            audioPluginParameter('X_Spacing', 'DisplayName', 'Mic X Spacing', ...
                'Mapping',{'int', 0, 50}),...
            audioPluginParameter('MicAngle',... 
                'Mapping',{'int', 0, 180}),...
            audioPluginParameter('Azimuth',...
                'Mapping',{'int',-180,180}),...
            audioPluginParameter('Elevation',...
                'Mapping',{'int',-90,90}),...
            audioPluginParameter('Gain',...
                'Mapping',{'lin',0,1}));
    end  
    methods (Access=protected)
        function out = stepImpl(plugin, in) 
            %plugin.MicArray = MicrophoneArray(plugin.X_Spacing,plugin.Y_Spacing,plugin.MicAngle);
            %plugin.Resp = step(plugin.MicArray, 2000, [plugin.Azimuth; plugin.Elevation]); 
            in(:,1) = (in(:,1) + in(:,2))/2; %Convert to Mono
            in(:,2) = in(:,1);
            l = in(:,1) * db2mag((mag2db(plugin.Resp(1,1)) + mag2db(plugin.Resp(2,1)))); 
            r = in(:,2) * db2mag((mag2db(plugin.Resp(3,1)) + mag2db(plugin.Resp(4,1)))); 
            out = [l, r];
        end
        function resetImpl(plugin)
        end
    end
    methods
        function set.X_Spacing(plugin, val)
            plugin.X_Spacing= val;
            %plugin.MicArray = MicrophoneArray(val,plugin.Y_Spacing,plugin.MicAngle);
        end
    end

end