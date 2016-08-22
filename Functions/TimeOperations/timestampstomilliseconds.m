function [ timestamps ] = timestampstomilliseconds( timestamps )
%TIMESTAMPSTOTIME Summary of this function goes here
%   Detailed explanation goes here
    TIMESTAMP_MILLISECONDS = 24*60*60*1000;
    for i = 1:size(timestamps, 1)
        timestamps(i) = timestamps(i) * TIMESTAMP_MILLISECONDS;
    end
end

