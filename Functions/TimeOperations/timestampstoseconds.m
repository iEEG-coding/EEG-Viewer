function [ timestamps ] = timestampstoseconds( timestamps )
%TIMESTAMPSTOTIME Summary of this function goes here
%   Detailed explanation goes here
    TIMESTAMP_SECONDS = 24*60*60;
    for i = 1:size(timestamps, 1)
        timestamps(i) = timestamps(i) * TIMESTAMP_SECONDS;
    end
end
