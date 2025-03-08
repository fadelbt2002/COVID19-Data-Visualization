%% COVID-19 Data Visualization - Application Launcher
% This script initializes and launches the COVID-19 visualization application.
%
% The application provides interactive visualizations of COVID-19 data including:
%   - Global case and death maps
%   - Country comparison tools
%   - US state-level analysis
%   - 3D globe visualizations
%addpath(genpath('/Users/fadelbatal/Downloads/Final project - COVID-19 Data Visualization_ A Picture of the Pandemic'));
savepath;

% Usage:
%   Simply run this script in MATLAB to start the application
%
% Requirements:
%   - MATLAB R2022b or later
%   - Mapping Toolbox
%   - Required data files in the ./data directory
%
% Author: Your Name
% Date: March 2025
% Version: 1.0

% Initialize environment
clc;          % Clear command window
clear;        % Clear workspace variables
close all;    % Close all figures

% Display welcome message
fprintf('=======================================================\n');
fprintf('  COVID-19 Data Visualization and Analysis Application  \n');
fprintf('=======================================================\n');
fprintf('Initializing application...\n');

license('test', 'Mapping_Toolbox') % Should return 1
exist('geoshow', 'file') % Should return 2 if found


%%
% Check for required toolboxes
if ~exist('geoshow', 'file')
    error('Mapping Toolbox functions not found. Ensure it is installed correctly.');
end


% Check for required data files
requiredFiles = {
    'time_series_covid19_confirmed_global.csv',
    'time_series_covid19_confirmed_US.csv',
    'time_series_covid19_deaths_global.csv',
    'us-states.csv',
    'CovidDataFor3DPlots.csv'
};

dataPath = '/Users/fadelbatal/Downloads/Final project - COVID-19 Data Visualization_ A Picture of the Pandemic';
missingFiles = false;

fprintf('Checking for required data files...\n');
for i = 1:length(requiredFiles)
    if ~exist(fullfile(dataPath, requiredFiles{i}), 'file')
        fprintf('WARNING: Required file not found: %s\n', requiredFiles{i});
        missingFiles = true;
    end
end

if missingFiles
    fprintf('Some required data files are missing. Download them from:\n');
    fprintf('- Johns Hopkins CSSE: https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series\n');
    fprintf('- New York Times: https://github.com/nytimes/covid-19-data\n');
    warning('Application may not function correctly without all required data files.');
else
    fprintf('All required data files found.\n');
end

% Launch the application
try
    fprintf('Launching COVID-19 Data Visualization Application...\n');
    run covid_visualization_app.mlapp
    fprintf('Application launched successfully.\n');
catch ME
    fprintf('ERROR: Failed to launch the application:\n%s\n', ME.message);
    fprintf('Please ensure all files are in the correct locations and try again.\n');
end