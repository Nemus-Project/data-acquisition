function [Nacc, PosVib, PosImp, PosHam, PosAccs] = setup(dq, sensitivities)
% Sets up the National Instruments acquisition card and returns some usefuls parameters.
% ----- INPUTS -----
%   dq             % DataAcquisition object associated with the acquisition card
%   sensitivities  % vector containing the sensitivities (floats) associated with each accelerometer
% ----- OUTPUTS -----
%   Nacc           % Number of accelerometers in use
%   PosVib         % position of the vibrometer on the sample (index of the associated sample point). If there is no vibrometer, PosVib = 0
%   PosImp         % position of the impedance head on the sample (index of the associated sample point). If there is no impedance head, PosImp = 0
%   PosHam         % position of the hammer on the sample (index of the associated sample point). If there is no hammer, PosHam = 0
%   PosAccs        % vector containing the position of each accelerometer (index of the associated sample points)
% ----- Program's principle -----
% 1) Clears all channels
% 2) Enables the accelerometers chosen by the user
% 3) Associate each accelerometer to a sample point's index
% 4) If wanted, enables vibrometer/impedance head/hammer and associates them with a sample point's index
if nargin<2
    error('Not enough input arguments');
elseif nargin>2
    error('Too many input arguments');
end

if ~isa(dq, 'daq.interfaces.DataAcquisition')
    error('1st input must be a daq.interfaces.DataAcquisition object.');
end
validateattributes(sensitivities, {'double'},{'positive'});

fprintf("\n---------- SET UP PROCEDURE ----------\n");

%% Disable all channels
if length(dq.Channels) ~= 0
    removechannel(dq, 1:length(dq.Channels));
end

%% Retrieve accelerometers and associated position
Accs = input("\nEnter the ID number of the accelerometers used:\n(example: [12 13 14 20 22])\n-----> ");
Nacc = length(Accs);
pos = input("\nDo you want to enter the positions on the sample manually?\n(Otherwise accelerometer's positions will be\ntheir order in the previous list) (y/n):\n-----> ", "s");
if pos == "y"
    test = 1;
    while test
        inputPos = input("\nEnter the accelerometer's corresponding position:\n(example: [1 2 5 3 4])\n-----> ");
        if length(inputPos) == Nacc
            test = 0;
        else
            fprintf("The number of positions must be the number of accelerometers in use.\n")
        end
    end
    [PosAccs, idx] = sort(inputPos);
    Accs = Accs(idx); % The accelerometers are ordered by position order
else
    PosAccs = 1:Nacc;
end

%% Set up accelerometer channels
for i = 1:Nacc
    n = Accs(i);
    Mod = floor((n-1)/4)+1;
    ai = rem(n-1,4);
    % enables the channels of the accelerometers
    ch = addinput(dq,"Mod"+Mod,"ai"+ai,"Accelerometer");
    ch.Sensitivity = sensitivities(i);
    % The names of the accelerometers are "AccI (idN)" with I their
    % position on the sample and N their ID number
    ch.Name = "Acc"+PosAccs(i) + " (id"+n+")";
    ch.ExcitationCurrent = .002;
end

%% Set up vibrometer channel
Vib = input("\nIs the vibrometer used? (y/n):\n-----> ", "s");
if Vib == "y"
    PosVib = input("\nEnter the index of the vibrometer's position on the sample:\n-----> ");
    ch = addinput(dq,"Mod7","ai1","IEPE");
    ch.ExcitationCurrent = .002;
    ch.Name = "Vibrometer"+PosVib;
else
    PosVib = 0;
end

%% Set up impedance head channel
Imp = input("\nIs the impedance head used? (y/n):\n-----> ", "s");
if Imp == "y"
    PosImp = input("\nEnter the index of the impedance head's position on the sample:\n-----> ");
    ch = addinput(dq,"Mod7","ai2","IEPE");
    ch.ExcitationCurrent = .002;
    ch.Name = "ImpHead"+PosImp;
else
    PosImp = 0;
end

%% Set up hammer channel
Ham = input("\nIs the hammer used? (y/n):\n-----> ", "s");
if Ham == "y"
    PosHam = input("\nEnter the index of the hammer's position on the sample:\n-----> ");
    ch = addinput(dq,"Mod7","ai3","IEPE");
    ch.ExcitationCurrent = .002;
    ch.Name = "Hammer"+PosHam;
else
    PosHam = 0;
end

% Displays channels
channels = dq.Channels
end