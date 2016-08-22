function[timestamp] = secondstotimestamp(time)
    SECONDS_TIMESTAMP = 1/(24*60*60);
    timestamp = time * SECONDS_TIMESTAMP;
end