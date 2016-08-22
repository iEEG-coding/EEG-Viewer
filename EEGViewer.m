classdef EEGViewer < handle
    %EEGVIEWER Viewer for continuous EEG data, allows marking,
    %rejecting signal and exporting and importing such data
    %   Detailed explanation goes here
    %   
    %   Working from the iEEG_scripts developed by Mgr. Kamil Vlèek Ph.D.
    %   here 
    %   Collaborators
    %       Lead developper - Mgr. Kamil Vlèek Ph.D.
    %       Others - Lukáš "hejtmy" Hejtmánek
    
    properties
        data; %double matrix as channels x data
        timestamps;
        channelNames;
        dataFrequency;
        
        settings;
        
        state;
        
        EEGplot;
        
        plotES; %[electrodes second range(y) timeRange allchannels?(bool)]
    end
    
    methods
        function obj = EEGViewer(data, timestamps)
            %parse the input
            obj.data = data;
            obj.timestamps = timestamps;
            % calculate frequency
            obj.dataFrequency = frequencyfromtimestamps(timestamps);
            
            obj.settings = defaultplotsettings;
            obj.state.second=  0;
            obj.state.rejectedChannels = [];
        end
        
        function plotelectrodes(obj, electrodes)
            %validation
            obj.plotSettings.electrodes = electrodes;
            obj.setup;
            obj.draw;
        end
        
        function plotepochs(obj)
            
        end
        
        
        %% functional part :)
        function setup(obj)
            if obj.settings.plotAllChannels == 1
                obj.state.bottomChannel = 1;
                %[upperChannel, ~, ~] = floor(obj.datasize()/2); % prone to error
                [~, obj.state.upperChannel, ~] = obj.datasize;
                obj.state.electrodes = obj.state.bottomChannel:obj.state.upperChannel;
                % NO IDEA WHAT THIS DOES
                obj.state.electrodes(2, 1) = 1; 
                obj.state.electrodes(2, 2:end) = obj.state.electrodes(1, 1:end - 1) + 1;
            else 
                obj.state.electrodes = obj.settings.electrodes;
            end
            
            if ~obj.isepoched % DELETED +1s and -1s because I didn't understand what they did. Maybe problem?
                startFrame = obj.state.second * obj.dataFrequency + 1; % +1 adds to the frame because matlab starts with 1
                endFrame = startFrame + obj.dataFrequency * obj.settings.timeRange + 1;
                obj.state.plotData = obj.data(startFrame:endFrame, obj.state.electrodes(1,:))'; % Changing dimensions
                obj.state.timeData = linspace(startFrame/obj.dataFrequency, endFrame/obj.dataFrequency, ...
                    endFrame - startFrame + 1); %casova osa   
            end
        end
        
        function draw(obj)
            if isempty(obj.EEGplot) % new plot
                obj.EEGplot = figure('Name', 'Electrode Plot');             
            else
                figure(obj.EEGplot);
            end
            % modified from https://uk.mathworks.com/matlabcentral/newsreader/view_thread/294163            
            minY = repmat(-obj.settings.voltageRange, [size(obj.state.plotData, 1), 1]);
            maxY = repmat(+obj.settings.voltageRange, [size(obj.state.plotData, 1), 1]);                        
            shift = cumsum([0; abs(maxY(1:end - 1)) + abs(minY(2:end))]);
            shift = repmat(shift, 1, size(obj.state.plotData, 2));
            colors = ['b', 'k'];
            iColor = 0;
            for electrode = obj.state.electrodes
                electrodeRange = (electrode(2):electrode(1)) - obj.state.electrodes(2, 1) + 1;
                electrodeRange2 = setdiff(electrodeRange, obj.state.rejectedChannels - obj.state.electrodes(2, 1) + 1); %non rejected channels  - zde se pocitaji od 1 proto odecitam els
                plot(obj.state.timeData, bsxfun(@minus, shift(end, :), shift(electrodeRange2, :)) + obj.state.plotData(electrodeRange2,:), colors(iColor + 1));  
                hold on;
                iColor = 1 - iColor;
            end
            hold off;
            set(gca, 'ytick', shift(:, 1),'yticklabel', obj.state.upperChannel:-1:obj.state.bottomChannel); %znacky a popisky osy y
            grid on;
            
            ylim([min(min(shift)) - obj.settings.voltageRange, max(max(shift)) + obj.settings.voltageRange]); %rozsah osy y
            %ylabel(['Electrode ' num2str(obj.state.electrodes) '/' num2str(numel(obj.state.electrodes)) ]);
            text(obj.state.timeData(1), -shift(2, 1),[ 'resolution +/-' num2str(obj.settings.voltageRange) 'mV']);         
            xlim([obj.state.timeData(1) obj.state.timeData(end)]);
        end
    end
    
    methods (Access = private)
        function[nSamples, nChannels, nEpochs] = datasize(obj)
            [nSamples, nChannels, nEpochs] = size(obj.data);
        end
        function bool = isepoched(obj)
            [~, ~, nEpochs] = datasize(obj);
            bool = nEpochs > 1;
        end
    end 
end

%[electrodes second range(y) timeRange allchannels?(bool)]
function [settings] = defaultplotsettings
    settings = struct();
    settings.electrodes = [];
    settings.voltageRange = 150;
    settings.timeRange = 5;
    settings.plotAllChannels = 1;
end
