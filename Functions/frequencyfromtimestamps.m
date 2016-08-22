function [ frequency ] = frequencyfromtimestamps( timestamps )
%TABSFREQUENCY returns datas frequency from passed timestamp values
%   Checks for random consistency in the data

    % checks if the timestamps are timestamps or what

N_RANDOM = 10;
%selects 10 random points 
iTimestamps = randi(numel(timestamps)-1, N_RANDOM, 1);
% creates tested rate
timeDifference = round(timestampstomilliseconds(timestamps(iTimestamps(1) + 1) - timestamps(iTimestamps(1))));
frequency = 1000/timeDifference; %thousand because we have converted timestamps to miliseconds
for i = 1:numel(iTimestamps)
     timeDifference = round(timestampstomilliseconds(timestamps(iTimestamps(i) + 1) - timestamps(iTimestamps(i))));
     testedFrequency = 1000/timeDifference;
     if testedFrequency ~= frequency
         fprintf('Inconsistent results in tabsfrequency function. Getting %s and %s frequencies', num2str(frequency), num2str(testedFrequency));
         frequency = [];
         return
     end
end
