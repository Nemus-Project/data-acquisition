function data = measure(dq, Fs, Nacc, PosVib, PosImp, PosHam, PosAccs, SensVib, SensImp, SensHam)
% Realises a continuous measurement with the given parameters and saves it if wanted.
% ----- INPUT -----
%   dq             % DataAcquisition object associated with the acquisition card
%   Nacc           % Number of accelerometers in use
%   PosVib         % position of the vibrometer on the sample (index of the associated sample point). If there is no vibrometer, PosVib = 0
%   PosImp         % position of the impedance head on the sample (index of the associated sample point). If there is no impedance head, PosImp = 0
%   PosHam         % position of the hammer on the sample (index of the associated sample point). If there is no hammer, PosHam = 0
%   PosAccs        % vector containing the position of each accelerometer (index of the associated sample points)
%   SensVib        % Vibrometer's sensitivity
%   SensImp        % Impedance head's sensitivity
%   SensHam        % Hammer's sensitivity
if nargin<9
    error('Not enough input arguments');
elseif nargin>9
    error('Too many input arguments');
end

if ~isa(dq, 'daq.interfaces.DataAcquisition')
    error('1st input must be a daq.interfaces.DataAcquisition object.');
end
validateattributes(Nacc, {'double'}, {'scalar', 'integer', 'positive'});
validateattributes(PosVib, {'double'}, {'scalar', 'integer', 'nonnegative'});
validateattributes(PosImp, {'double'}, {'scalar', 'integer', 'nonnegative'});
validateattributes(PosHam, {'double'}, {'scalar', 'integer', 'nonnegative'});
validateattributes(PosAccs, {'double'}, {'integer', 'positive', 'numel', Nacc});
validateattributes(SensVib, {'double'}, {'scalar', 'positive'});
validateattributes(SensImp, {'double'}, {'scalar', 'positive'});
validateattributes(SensHam, {'double'}, {'scalar', 'positive'});

%% Measurement
fprintf("\n---------- MEASUREMENT ----------\n");
input("\nPress Enter to begin measurement.", 's');
start(dq,"Continuous");
input("\n***** START *****\nPress Enter to stop the measurement.", 's');
stop(dq);
fprintf("\n***** STOP *****\n");

%% Retrieve the data and convert it in the proper units
data = read(dq,"all");
if PosVib
    VibName = data.Properties.VariableNames{1,end-2};
    data.(VibName) = data.(VibName) / SensVib;
end
if PosImp
    ImpName = data.Properties.VariableNames{1,end-1};
    data.(ImpName) = data.(ImpName) / SensImp;
end
for i=1:Nacc
    Acc = data.Properties.VariableNames{1,i};
    data.(Acc) = data.(Acc) - mean(data.(Acc));
end
if PosHam
    HamName = data.Properties.VariableNames{1,end};
    data.(HamName) = data.(HamName) / SensHam;
    displaySignal(data,HamName);
else
    displaySignal(data,data.Properties.VariableNames{1,1}); % 1st accelerometer
end

%% Save data in a csv file
test = 1;
while test
    OutputFile = input("\nEnter the filename of the output file:\n(Leave blank to skip saving)\n-----> ", "s");
    if length(OutputFile) == 0
        test = 0;
    elseif length(OutputFile) < 5
        fprintf("The file must be a csv file.\n");
    elseif ~strcmp(OutputFile(end-3:end), '.csv')
        fprintf("The file must be a csv file.\n");
    else
        test = 0;
        saveCSV(OutputFile, dq, Fs, data, Nacc, PosVib, PosImp, PosHam, PosAccs);
    end
end



end