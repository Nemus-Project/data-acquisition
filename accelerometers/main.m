%% --------------------------- Initialization --------------------------

% clearing memory, closing figures, clearing command window
clear all
close all
clc

%% Global variables

% Sample rate [Hz]
Fs = 10240; % 10240, 51200...

% Hammer's sensitivity [V/N]
SensHam = 0.0225;

% Impedance head's sensitivity [V/N]
SensImp = 0.0224;

% Vibrometer's sensitivity [V/(m/s)]
SensVib = 1;

% sensitivity of each accelerometer [V/g]
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

% Starting the acquisition card
dq = daq("ni");
dq.Rate = Fs; % sample rate

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
        measure(dq, Fs, Nacc, PosVib, PosImp, PosHam, PosAccs, SensVib, SensImp, SensHam);
    elseif ans == "c"
        fprintf("\nProgram closed.\n\n");
        return
    end
end