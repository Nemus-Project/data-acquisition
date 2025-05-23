function saveCSV(dq, data, Nacc, PosVib, PosImp, PosHam, PosAccs)
% Saves the "data" timetable into a CSV file with the proper header for BK Connect import.
% ----- INPUTS -----
%   dq             % DataAcquisition object associated with the acquisition card
%   data           % Timetable of the measurement
%   Nacc           % Number of accelerometers in use
%   PosVib         % position of the vibrometer on the sample (index of the associated sample point). If there is no vibrometer, PosVib = 0
%   PosImp         % position of the impedance head on the sample (index of the associated sample point). If there is no impedance head, PosImp = 0
%   PosHam         % position of the hammer on the sample (index of the associated sample point). If there is no hammer, PosHam = 0
%   PosAccs        % vector containing the position of each accelerometer (index of the associated sample points)
if nargin<7
    error('Not enough input arguments');
elseif nargin>7
    error('Too many input arguments');
end

if ~isa(dq, 'daq.interfaces.DataAcquisition')
    error('1st input must be a daq.interfaces.DataAcquisition object.');
end
validateattributes(data, {'timetable'}, {});
validateattributes(Nacc, {'double'}, {'scalar', 'integer', 'positive'});
validateattributes(PosVib, {'double'}, {'scalar', 'integer', 'positive'});
validateattributes(PosImp, {'double'}, {'scalar', 'integer', 'positive'});
validateattributes(PosHam, {'double'}, {'scalar', 'integer', 'positive'});
validateattributes(PosAccs, {'double'}, {'integer', 'positive', 'numel', Nacc});



%% Retrieve output file's name
test = 1;
while test
    OutputFile = input("\nEnter the filename of the output file:\n-----> ", "s");
    if length(OutputFile) < 5
        fprintf("The file must be a csv file.\n");
    elseif OutputFile(end-3:end) ~= '.csv'
        OutputFile(end-3:end)
        fprintf("The file must be a csv file.\n");
    else
        test = 0;
    end
end

lenghtData = height(data);
Nsignals = width(data);
deltat = 1/51200;

% Get current date and time
currentDateTime = datestr(now, "dd/mm/yyyy HH:MM:SS");

% Channels' names
chNames = "Name";
for i = 1:Nsignals
    name = dq.Channels(i).Name;
    chNames = chNames + "," + name;
end
chNames = chNames + "\n";

% Channels' units
chUnits = "Unit";
for j = 1:Nacc
    chUnits = chUnits + ",m/s^2";
end
if PosVib
    chUnits = chUnits + ",m/s";
end
if PosImp
    chUnits = chUnits + ",N";
end
if PosHam
    chUnits = chUnits + ",N";
end
chUnits = chUnits + "\n";

% Channels' Output DOF (degree of freedom)
outDOF = "OutputDOF";
for k=PosAccs
    outDOF = outDOF + ",New DOF."+ k + "Z+";
end
if PosVib
    outDOF = outDOF + ",New DOF."+ PosVib + "Z+";
end
if PosImp
    outDOF = outDOF + ",New DOF."+ PosImp + "Z+";
end
if PosHam
    outDOF = outDOF + ",New DOF."+ PosHam + "Z+";
end
outDOF = outDOF + "\n";

% Channels' input DOF (degree of freedom) (if needed)
if PosHam
    inDOF = "InputDOF";
    for l=1:Nsignals
        inDOF = inDOF + ",New DOF."+ PosHam + "Z+";
    end
    inDOF = inDOF + "\n";
elseif  PosImp
    inDOF = "InputDOF";
    for l=1:Nsignals
        inDOF = inDOF + ",New DOF."+ PosImp + "Z+";
    end
    inDOF = inDOF + "\n";
end


%% Write header lines
file = fopen(OutputFile, "w");
fprintf(file, "CSVFormatType,Time\n");
fprintf(file, "SinglePrecision,FALSE\n");
fprintf(file, "DataLength,%d\n",lenghtData);
fprintf(file, "First,0\n");
fprintf(file, "Delta,%1.20f\n",deltat);
fprintf(file, "AxisUnit,s\n");
fprintf(file, "AxisValueExists,1\n");
fprintf(file, "Signals,%d\n", Nsignals);
fprintf(file, "Date,%s\n", currentDateTime);
fprintf(file, "\n");
fprintf(file, chNames);
fprintf(file, "FunctionType,StreamedTimeHistory\n");
fprintf(file, chUnits);
fprintf(file, outDOF);
% input DOF written if needed
if PosHam||PosImp
    fprintf(file, inDOF);
end

% Close the file
fclose(file);

%% Write data into the CSV file
tabledata = timetable2table(data);
tabledata.Time = seconds(tabledata.Time);
writetable(tabledata, OutputFile, 'WriteVariableNames', false, 'WriteMode', 'append');
fprintf("\nFile saved.\n");
end