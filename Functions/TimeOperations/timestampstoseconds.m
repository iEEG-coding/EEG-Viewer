function timestamps = timestampstoseconds( timestamps )
%TIMESTAMPSTOTIME Summary of this function goes here
%   Detailed explanation goes here
    TIMESTAMP_SECONDS = 24*60*60;
    timestamps = timestamps * TIMESTAMP_SECONDS;
end
