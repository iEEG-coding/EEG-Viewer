function [ settings ] = defaultplotsettings
%DEFAULTPLOTSETTINGS instantiates empty struct with default settings
%   Detailed explanation goes here
    settings = struct();
    settings.electrodes = [];
    settings.startSecond = 0;
    settings.voltageRange = 150;
    settings.timeRange = 5;
    settings.plotAllChannels = 0;
end

