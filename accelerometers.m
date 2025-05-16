%% ---------------------------  Introduction ---------------------------
% 
% author: Philémon SCHABANEL for the NEMUS project
% date: 14/05/2025
% 
% The aim of his program is to do acoustics measurements (to be sent to BK Connect) 
% using accelerometers and avhammer/impedance head/vibrometer, all connected 
% to a National Instruments acquisition card. The program is made to be
% launched once and then do all the measurements without having to close it
% The program sets up the acuisition card by choosing which channels to use
% and giving them proper names for the following BK Connect analysis. Then
% the program can do several things depending on the user input: showing
% the actual setup of the acquisition card, changing it, start a
% measurement, show it and then save it if it is OK.
%
% ---------- HOW TO USE THE PROGRAM ----------
% 
% 1) Start the program and go to the command window. The program will be
% entirely managed using the command window.
%
% 2) SET UP PROCEDURE: The program will start by setting up the card. 
% For that it will ask the user to enter the list of the accelerometer used 
% (input example: [1 2 3 10 15 23 25]). The user must give the ID of the 
% accelerometer, not its modX/aiY nor the index of its position on the sample
% (the ID should be written on the accelerometer's cable as well as on its box).
%
% WARNING: The program will assume that the order of the accelerometer in
% the input is the same as the order of the accelerometers on the sample
% (ie the first accelerometer given is on position 1m the second
% accelerometer given is on position 2, ect...)
%
% - Then the program will ask, for the vibrometer, the impedance head and
% the hammer if they are used (yes/no question) and if yes what is their 
% position's index on the sample.
% 
% 3) MAIN MENU: After the setup, the program will go to a main menu. There 
% the user can : - start a setup procedure (in case the channels used change)
% - see the actual setup
% - start a measurement
% - close the program
%
% 4) MEASUREMENT: The program will ask to press enter to begin the
% measurement. The measurement will last until the user presses enter
% again. Then the hammer's signal (if used) will be displayed in order to
% check if there were double-hits. If the hammer isn't used, Acc1's signal
% will be displayed.
%
% 5) SAVING: After a measurement, the program will ask the user if he/she
% wants to save the measurement. If yes, the program will ask the user the
% name of the output file (MUST BE A CSV FILE!) and will create it, with
% the proper header so that the csv file can be imported directly into BK
% Connect.

%% --------------------------- Initialization --------------------------

% clearing memory, closing figures, clearing command window
clear all
close all
clc

% Starting the acquisition card
dq = daq("ni");
dq.Rate = 51200; % sample rate

%% Global variables

% Hammer's sensitivity (V/N)
SensHam = 0.0225;

% Impedance head's sensitivity (V/N)
SensImp = 0.0224;

% Vibrometer's sensitivity (V/(m/s))
SensVib = 1;

% sensitivity of each accelerometer (V/g)
sensitivities = [.00505 % Acc1
    .00517 % Acc2
    .00508 % Acc3
    .00521 % Acc4
    .00494 % Acc5
    .00493 % Acc6
    .00507 % Acc7
    .00566 % Acc8
    .00504 % Acc9
    .00505 % Acc10
    .005 % Acc11 % WARNING: not the actual sensitivity
    .00496 % Acc12
    .00527 % Acc13
    .00542 % Acc14
    .00496 % Acc15
    .00504 % Acc16
    .00491 % Acc17
    .00525 % Acc18
    .00529 % Acc19
    .00471 % Acc20
    .00474 % Acc21
    .00500 % Acc22
    .00504 % Acc23
    .00490 % Acc24
    .00510 % Acc25
    .005 % Acc26 % WARNING: not the actual sensitivity
    .005 % Acc27 % WARNING: not the actual sensitivity
    .005 % Acc28 % WARNING: not the actual sensitivity
    ];
%% ------------------------------- MAIN --------------------------------

fprintf("Welcome to NI Acquisition!\nThe program will begin by setting up the acquisition card.\n");
[Nacc, PosVib, PosImp, PosHam, PosAccs] = setup(dq, sensitivities);
while true
    fprintf("\n---------- MAIN MENU ----------\n");
    ans = input("\nWhat do you want to do?\nv: View the channel settings\ns: Set up the channels\nm: Do a measurement\nc: Close\n\n----->  ", "s");
    if ans == "s"
        [Nacc, PosVib, PosImp, PosHam, PosAccs] = setup(dq, sensitivities);
    elseif ans == "v"
        channels = dq.Channels
    elseif ans == "m"
        measure(dq, Nacc, PosVib, PosImp, PosHam, PosAccs, SensVib, SensImp, SensHam);
    else
        fprintf("\nProgram closed.\n\n");
        return
    end
end

%% ----------------------------- FUNCTIONS -----------------------------

%% Sets up the acquisition card

function [Nacc, PosVib, PosImp, PosHam, PosAccs] = setup(dq, sensitivities)
    fprintf("\n---------- SET UP PROCEDURE ----------\n");
    if length(dq.Channels) ~= 0
        % disables all channels
        removechannel(dq, 1:length(dq.Channels));
    end

    Accs = input("\nEnter the ID number of the accelerometers used (example: [12 13 14 20 22]): ");
    Nacc = length(Accs);
    pos = input("\nDo you want to enter the positions on the sample manually?\n(Otherwise accelerometer's positions will be their order in the previous list) (y/n): ", "s");
    if pos == "y"
        inputPos = input("\nEnter the accelerometer's corresponding position (example: [1 2 5 3 4]): ");
        [PosAccs, idx] = sort(inputPos);
        Accs = Accs(idx); % The accelerometers are ordered by position order
    else
        PosAccs = 1:Nacc;
    end
    
    % Accelerometer channels
    for i = 1:Nacc
        n = Accs(i);
        Mod = floor((n-1)/4)+1;
        ai = rem(n-1,4);
        % enables the channels of the accelerometers
        ch = addinput(dq,"Mod"+Mod,"ai"+ai,"Accelerometer");
        ch.Sensitivity = sensitivities(i);
        % The names of the accelerometers are "AccI (n°N)" with I their
        % position on the sample and N their ID number
        ch.Name = "Acc"+PosAccs(i) + "(n°"+n+")";
        ch.ExcitationCurrent = .002;
    end

    % Vibrometer channel
    Vib = input("\nIs the vibrometer used? (y/n): ", "s");
    if Vib == "y"
        PosVib = input("\nEnter the index of the vibrometer's position on the sample: ");
        ch = addinput(dq,"Mod7","ai1","IEPE");
        ch.ExcitationCurrent = .002;
        ch.Name = "Vibrometer"+PosVib;
    else
        PosVib = 0;
    end

    % Impedance head channel
    Imp = input("\nIs the impedance head used? (y/n): ", "s");
    if Imp == "y"
        PosImp = input("\nEnter the index of the impedance head's position on the sample: ");
        ch = addinput(dq,"Mod7","ai2","IEPE");
        ch.ExcitationCurrent = .002;
        ch.Name = "ImpHead"+PosImp;
    else
        PosImp = 0;
    end

    % Hammer channel
    Ham = input("\nIs the hammer used? (y/n): ", "s");
    if Ham == "y"
        PosHam = input("\nEnter the index of the hammer's position on the sample: ");
        ch = addinput(dq,"Mod7","ai3","IEPE");
        ch.ExcitationCurrent = .002;
        ch.Name = "Hammer"+PosHam;
    else
        PosHam = 0;
    end

    % Displays channels
    channels = dq.Channels
end

%% Displays data after the measure

function DisplaySig(data, label)
    close all
    signal = data.(label);
    if contains(label, "Acc")
        axlabel = "m/s^2";
    else
        axlabel = "N";
    end
    plot(data.Time, signal);
    title(label);
    xlabel("Time (s)");
    ylabel(axlabel);
    fprintf("\nSignal "+label+" displayed.\n");
end

%% Creates the CSV file with the correct header

function saveCSV(dq, data, Nacc, PosVib, PosImp, PosHam, PosAccs)
    OutputFile = input("\nEnter the filename of the output file: ", "s");

    lenghtData = height(data);
    Nsignals = width(data);
    deltat = 1/51200;
    
    % Open file for writing
    file = fopen(OutputFile, "w");
    
    % Get current date and time
    currentDateTime = datestr(now, "dd/mm/yyyy HH:MM:SS");

    chNames = "Name";
    for i = 1:Nsignals
        name = dq.Channels(i).Name;
        chNames = chNames + "," + name;
    end
    chNames = chNames + "\n";

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

    
    % Write header lines
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
    if PosHam||PosImp
        fprintf(file, inDOF);
    end
    fprintf(file, "\n");
    
    % Close the file
    fclose(file);
    
    tabledata = timetable2table(data);
    tabledata.Time = seconds(tabledata.Time);
    writetable(tabledata, OutputFile, 'WriteVariableNames', false, 'WriteMode', 'append');

end

%% Realises one measure

function data = measure(dq, Nacc, PosVib, PosImp, PosHam, SensVib, SensImp, SensHam)
    fprintf("\n---------- MEASUREMENT ----------\n")
    input("\nPress Enter to begin measurement.");
    start(dq,"Continuous");
    input("\nMeasurement started.\nPress Enter to stop the measurement.");
    stop(dq);
    fprintf("\nMeasurement stopped.\n")
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
        DisplaySig(data,HamName);
    else
        DisplaySig(data,data.Properties.VariableNames{1,1}); % Acc1
    end
    sav = input("Do you want to save the measure? (y/n): ", "s");
    if sav ~= "n"
        saveCSV(dq, data, Nacc, PosVib, PosImp, PosHam)
    end
end