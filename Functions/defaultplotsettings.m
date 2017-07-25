function [ settings ] = defaultplotsettings
%DEFAULTPLOTSETTINGS instantiates empty struct with default settings
%   Detailed explanation goes here
    settings = struct();
    settings.channels = [];
    settings.startSecond = 0;
    settings.voltageRange = 150;
    settings.timeRange = 5;
    settings.plotAllChannels = 1;
    settings.eventColor = 'red';
    settings.grid = true;
end

