function displaySignal(data, label)
% Displays a signal from a measurement.
% ----- INPUTS -----
%   data           % Timetable of the measurement
%   label          % Name of the signal to be displayedù
if nargin<2
    error('Not enough input arguments');
elseif nargin>2
    error('Too many input arguments');
end

validateattributes(data, {'timetable'};)
validateattributes(label, {'string'});
if ~ismember(label, data.Properties.VariableNames)
    error('Variable "%s" is not in the input timetable.', label);
end

close all
%% Load data
signal = data.(label);

%% Choose the proper unit
if contains(label, "Acc")
    axlabel = "m/s^2";
elseif contains(labels, "Vibrometer")
    axlabel = "m/s";
else
    axlabel = "N";
end

%% Display signal
plot(data.Time, signal);
title(label);
xlabel("Time (s)");
ylabel(axlabel);
fprintf("\nSignal "+label+" displayed.\n");
end