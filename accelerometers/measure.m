function data = measure(dq, Nacc, PosVib, PosImp, PosHam, PosAccs, SensVib, SensImp, SensHam)
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
if PosHam
    HamName = data.Properties.VariableNames{1,end};
    data.(HamName) = data.(HamName) / SensHam;
    displaySignal(data,HamName);
else
    displaySignal(data,data.Properties.VariableNames{1,1}); % Acc1
end

%% Save data in a csv file
sav = input("Do you want to save the measure? (y/n): ", "s");
if sav ~= "n"
    saveCSV(dq, data, Nacc, PosVib, PosImp, PosHam, PosAccs);
end
end