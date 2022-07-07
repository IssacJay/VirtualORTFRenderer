classdef VirtualMicrophone < audioPlugin                            % <== (1) Inherit from audioPlugin.
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
    properties (Access = private)
        bool = false;
        Resp = zeros(4,4);
        MicArray = phased.ConformalArray();
    end
    properties (Constant)
        PluginInterface = audioPluginInterface( ...           % <== (3) Map tunable property to plugin parameter.
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
    methods
        function plugin = VirtualMicrophone()
        end
        function out = process(plugin, in)   
            if plugin.bool == false
                 plugin.MicArray = MicrophoneArray(plugin.X_Spacing,plugin.Y_Spacing,plugin.MicAngle, plugin.MicArray);
                 plugin.bool = true; 
            end
            plugin.Resp = plugin.MicArray(2000, [plugin.Azimuth; plugin.Elevation]); 
            in(:,1) = (in(:,1) + in(:,2))/2; %Convert to Mono
            in(:,2) = in(:,1);
            l = in(:,1) * db2mag((mag2db(plugin.Resp(1,1)) + mag2db(plugin.Resp(2,1)))); 
            r = in(:,2) * db2mag((mag2db(plugin.Resp(3,1)) + mag2db(plugin.Resp(4,1)))); 
            out = [l, r];
        end
        function set.X_Spacing(plugin, val)
            plugin.X_Spacing= val;
            %plugin.MicArray = MicrophoneArray(val,plugin.Y_Spacing,plugin.MicAngle, plugin.MicArray);
        end
    end

end