function [ frequency ] = frequencyfromtimestamps( timestamps )
%frequencyfromtimestamps returns datas frequency from passed timestamp values
%   Checks for random consistency in the data
    % checks if the timestamps are timestamps or what
    N_RANDOM = 10;
    frequency = [];
    BETWEEN_FRAMES = 1000;
    %selects 10 random points 
    iTimestamps = randi(numel(timestamps) - 1, N_RANDOM, 1);
    % creates tested rate
    for i = 1:numel(iTimestamps)
        timeDifference = timestampstomilliseconds(timestamps(iTimestamps(i) + BETWEEN_FRAMES) - timestamps(iTimestamps(i)));
        testedFrequency = BETWEEN_FRAMES*1000/timeDifference; %thousand because we have converted timestamps to miliseconds
        if testedFrequency == Inf, continue; end
        computedFrequency = round(testedFrequency);
        if isempty(frequency), frequency = computedFrequency; end %only happens on the first iteration
        if computedFrequency ~= frequency
            fprintf('Inconsistent results in tabsfrequency function. Getting %s and %s frequencies', num2str(frequency), num2str(testedFrequency));
            frequency = [];
            return
        end
    end
end