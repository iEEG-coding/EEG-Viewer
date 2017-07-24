classdef EEGViewer < handle
    %EEGVIEWER Viewer for continuous EEG data, allows marking,
    %rejecting signal and exporting and importing such data
    %   Detailed explanation goes here
    %   
    %   Working from the iEEG_scripts developed by Mgr. Kamil Vl�?ek Ph.D.
    %   here https://github.com/kamilvlcek/iEEG_scripts
    %   Collaborators
    %       Lead developper - Mgr. Kamil Vlèek Ph.D.
    %       Others - Lukáš "hejtmy" Hejtmánek
    
    properties
        data; %double matrix as channels x sample
        timestamps; %timestamps of hte same length as samples in the data matrix
        channelNames;   %optional description for channels
        dataFrequency; %helper for calculating indexes of subsetted data
        
        settings; %struct with settings - more in defaultplotsettings
        
        state;  %keeps track of the current plot state
        
        EEGplot; % plot to display and modify
    end
    
    methods
        function obj = EEGViewer(data, timestamps)
            %parse the input
            obj.data = data;
            obj.timestamps = timestamps;
            % calculate frequency
            obj.dataFrequency = frequencyfromtimestamps(timestamps);
            
            obj.settings = defaultplotsettings;
            obj.state.second = 0;
            obj.state.rejectedChannels = [];
        end
        
        function plotchannels(obj, channels)
          %validation
          obj.plotSettings.channels = channels;
          obj.setup;
          obj.draw;
        end
        
        function plotall(obj)
          obj.setup;
          obj.draw;
        end
        
        %% functional part :)
        function setup(obj)
            if obj.settings.plotAllChannels == 1
                obj.state.bottomChannel = 1;
                %[upperChannel, ~, ~] = floor(obj.datasize()/2); % prone to error
                [~, obj.state.upperChannel, ~] = obj.datasize;
                obj.state.channels = obj.state.bottomChannel:obj.state.upperChannel;
                % NO IDEA WHAT THIS DOES
                obj.state.channels(2, 1) = 1; 
                obj.state.channels(2, 2:end) = obj.state.channels(1, 1:end - 1) + 1;
            else 
                obj.state.channels = obj.settings.channels;
            end
            
            if ~obj.isepoched % DELETED +1s and -1s because I didn't understand what they did. Maybe problem?
               obj.moveplottime(0); % sets up the plot at second 0
            end
        end
        
        function changevoltage(obj, mV)
            obj.settings.voltageRange = obj.settings.voltageRange + mV;
            if (obj.settings.voltageRange <= 10), obj.settings.voltageRange = 10; end
            if (obj.settings.voltageRange >= 1000), obj.settings.voltageRange = 1000; end
        end
        
        function moveplottime(obj, time)
            
            %checks for the time
            obj.state.second = obj.state.second + time;
            
            lastPossibleSecond = numel(obj.timestamps)/obj.dataFrequency - obj.settings.timeRange; %could be made static
            if (obj.state.second < 0) obj.state.second = 0; end %if wa want to back before 0
            if (obj.state.second >= lastPossibleSecond) %if we want to move beyond length of data
                obj.state.second = lastPossibleSecond - 2/obj.dataFrequency; %two frames before as we add them later
            end 
                
            startFrame = obj.state.second * obj.dataFrequency + 1; % +1 adds to the frame because matlab starts with 1
            endFrame = startFrame + obj.dataFrequency * obj.settings.timeRange + 1;
            
            obj.state.plotData = obj.data(startFrame:endFrame, obj.state.channels(1, :))';
            obj.state.timeData = linspace(startFrame/obj.dataFrequency, endFrame/obj.dataFrequency, ...
                endFrame - startFrame + 1); %casova osa
        end
        
        function draw(obj)
            if isempty(obj.EEGplot) || ~isvalid(obj.EEGplot) % new plot
                obj.EEGplot = figure('Name', 'Channel Plot');             
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
            
            for channel = obj.state.channels
                channelRange = (channel(2):channel(1)) - obj.state.channels(2, 1) + 1;
                channelRange2 = setdiff(channelRange, obj.state.rejectedChannels - obj.state.channels(2, 1) + 1); %non rejected channels  - zde se pocitaji od 1 proto odecitam els
                plot(obj.state.timeData, bsxfun(@minus, shift(end, :), shift(channelRange2, :)) + obj.state.plotData(channelRange2,:), colors(iColor + 1));  
                hold on;
                iColor = 1 - iColor;
            end
            
            hold off;
            set(gca, 'ytick', shift(:, 1),'yticklabel', obj.state.upperChannel:-1:obj.state.bottomChannel); %znacky a popisky osy y
            grid on;
            
            ylim([min(min(shift)) - obj.settings.voltageRange, max(max(shift)) + obj.settings.voltageRange]); %rozsah osy y
            %ylabel(['Electrode ' num2str(obj.state.channels) '/' num2str(numel(obj.state.channels)) ]);
            text(obj.state.timeData(1), -shift(2, 1),[ 'resolution +/-' num2str(obj.settings.voltageRange) 'mV']);         
            xlim([obj.state.timeData(1) obj.state.timeData(end)]);
            
            % -------- KEY PRESS HANDLE  handle na obrazek a nastaveni grafu -----------------
            set(obj.EEGplot, 'KeyPressFcn', @obj.plotkeyactions); 
             
            % ----- NAMING CHANNELS ------
            return;
            % so far I have little idea of what this does - so I'm keeping
            % it as it is :)
            for j = 1:size(shift, 1)
                yshift = shift(end, 1) - shift(j, 1);
                
                text(obj.state.timeData(end), yshift,[ ' ' obj.CH.H.channels(1, obj.state.bottomChannel + j-1).neurologyLabel, ...
                    ',', obj.CH.H.channels(1, obj.state.bottomChannel + j - 1).ass_brainAtlas]);
                text(obj.state.timeData(1) - size(obj.data, 2)/obj.dataFrequency/10, yshift, ...
                    [ ' ' obj.CH.H.channels(1, obj.state.bottomChannel + j - 1).name]);
                
                if find(obj.state.rejectedChannels == obj.state.bottomChannel - 1 + j) %oznacim vyrazene kanaly
                    text(obj.state.timeData(1), yshift + 20, ' REJECTED');
                end
            end 
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
        
        function plotkeyactions(obj, ~, eventDat)
            switch eventDat.Key
                case 'rightarrow' 
                    obj.moveplottime(5);
                case 'leftarrow'
                    obj.moveplottime(-5);
                case 'home'          
                    obj.moveplottime(-Inf);
                case 'end' 
                    obj.moveplottime(Inf);
                case 'add'
                    obj.changevoltage(10);
                case 'subtract'  
                    obj.changevoltage(-10);
                otherwise
                    disp(['You just pressed: ' eventDat.Key]);                      
            end
            obj.draw;
        end
    end 
end
