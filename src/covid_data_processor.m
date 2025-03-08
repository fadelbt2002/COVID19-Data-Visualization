%% COVID-19 Data Visualization and Analysis
% This script provides comprehensive visualization and analysis of COVID-19 data
% from multiple sources, including global confirmed cases, death statistics,
% and US state-level data.
%
% Features:
%   - Global COVID-19 case visualization using geobubble maps
%   - Country-specific growth analysis and comparison
%   - US state-level analysis with ranking and trend visualization
%   - Interactive 3D globe visualizations of cases and deaths
%
% Data sources:
%   - Johns Hopkins CSSE COVID-19 Data Repository (time series data)
%   - New York Times COVID-19 Data (US state-level data)
%
% Required files:
%   - time_series_covid19_confirmed_global.csv
%   - time_series_covid19_confirmed_US.csv
%   - time_series_covid19_deaths_global.csv
%   - us-states.csv
%   - CovidDataFor3DPlots.csv
%
% Dependencies:
%   - MATLAB R2022b or later
%   - Mapping Toolbox
%
% Author: Your Name
% Date: March 2025
% Version: 1.0

%% Initialize Environment
clc;          % Clear command window
clear;        % Clear workspace variables
close all;    % Close all figures

%% Global Constants and Configuration
DATA_PATH = './data/';  % Path to data files
CONFIRMED_GLOBAL_FILE = 'time_series_covid19_confirmed_global.csv';
CONFIRMED_US_FILE = 'time_series_covid19_confirmed_US.csv';
DEATHS_GLOBAL_FILE = 'time_series_covid19_deaths_global.csv';
US_STATES_FILE = 'us-states.csv';
COVID_3D_FILE = 'CovidDataFor3DPlots.csv';

% Visualization settings
FIGURE_WIDTH = 1200;
FIGURE_HEIGHT = 800;
DEFAULT_FONT = 'Times New Roman';
DEFAULT_FONT_SIZE = 12;
MAP_CENTER_GLOBAL = [21.6385, 36.1666];
MAP_ZOOM_GLOBAL = 0.3606;
MAP_CENTER_US = [44.9669, -113.6201];
MAP_ZOOM_US = 1.7678;

%% SECTION 1: Global Confirmed Cases Visualization
fprintf('Processing global confirmed cases data...\n');

% Load and prepare data
opts = configureImportOptions(CONFIRMED_GLOBAL_FILE);
confirmedData = readtable(fullfile(DATA_PATH, CONFIRMED_GLOBAL_FILE), opts);

% Clean country names for consistency
confirmedData = cleanCountryNames(confirmedData);

% Aggregate data by country
vars = confirmedData.Properties.VariableNames;
confirmedByCountry = aggregateByCountry(confirmedData, vars);

% Exclude China for better visualization
countriesExChina = confirmedByCountry(confirmedByCountry.("Country/Region") ~= "Mainland China", :);
vars = countriesExChina.Properties.VariableNames;

% Create visualization
fig1 = figure('Name', 'Global COVID-19 Cases', 'Position', [100, 100, FIGURE_WIDTH, FIGURE_HEIGHT]);
t = tiledlayout("flow");

% Plot early pandemic and latest data for comparison
visualizeGlobalCasesMap(countriesExChina, vars, [4, length(vars)], t, "satellite");

% Set main title
title(t, [" Confirmed COVID-19 Cases Worldwide"; ...
    "Countries with <100 cases highlighted in Magenta"]);

fprintf('Global confirmed cases visualization complete.\n');

%% SECTION 2: Country-specific COVID-19 Growth Analysis
fprintf('Setting up country comparison analysis...\n');

% Create figure for country analysis
fig2 = figure('Name', 'Country Comparison', 'Position', [100, 100, FIGURE_WIDTH, FIGURE_HEIGHT]);

% Get first country from user
firstCountry = input('Enter name of the first country (Except China): ', 's');
countryData = prepareCountryData(countriesExChina, firstCountry);

% Create time vector for x-axis
[caseDates, timeVector] = createTimeVector(countryData);

% Convert data to numeric format for plotting
countryDataFixed = convertToNumeric(countryData);

% Plot first country data
subplot(1, 2, 1);
plotCountryData(timeVector, countryDataFixed, firstCountry);

% Get second country and plot comparison
subplot(1, 2, 2);
secondCountry = input('Enter name of the second country (Except China): ', 's');
[countryDataFixed, countryDataSecond] = prepareCountryComparison(countriesExChina, firstCountry, secondCountry, timeVector);

fprintf('Country comparison analysis complete.\n');

%% SECTION 3: US States COVID-19 Analysis
fprintf('Processing US states data...\n');

% Load and prepare US data
opts = configureImportOptions(CONFIRMED_US_FILE);
usConfirmedData = readtable(fullfile(DATA_PATH, CONFIRMED_US_FILE), opts);

% Clean and aggregate US data by state
usConfirmedData = cleanUSData(usConfirmedData);
varsUS = usConfirmedData.Properties.VariableNames;
stateData = aggregateByState(usConfirmedData, varsUS);

% Create visualization of US state data
fig3 = figure('Name', 'US States COVID-19 Cases', 'Position', [100, 100, FIGURE_WIDTH, FIGURE_HEIGHT]);
t = tiledlayout("flow");

% Plot early pandemic and latest data for US states
visualizeUSStatesMap(stateData, varsUS, [4, length(varsUS)], t);

% Set main title
title(t, [" Confirmed COVID-19 Cases in the United States"; ...
    "States with <100 cases highlighted in Magenta"]);

% Process US state ranking data
fprintf('Generating US states ranking...\n');
opts = configureImportOptions(US_STATES_FILE);
usStatesData = readtable(fullfile(DATA_PATH, US_STATES_FILE), opts);

% Aggregate data by state and date
stateRankingData = processStateRankingData(usStatesData);

% Plot top 20 states by case count
createStateRankingVisualization(stateRankingData, 20, usStatesData);

% Plot growth curves for top states
createStateGrowthVisualization(stateRankingData, usStatesData);

fprintf('US states analysis complete.\n');

%% SECTION 4: Global Death Cases Visualization
fprintf('Processing global death cases data...\n');

% Load and prepare death data
opts = configureImportOptions(DEATHS_GLOBAL_FILE);
deathData = readtable(fullfile(DATA_PATH, DEATHS_GLOBAL_FILE), opts);

% Clean country names for consistency
deathData = cleanCountryNames(deathData);

% Aggregate data by country
varsDeath = deathData.Properties.VariableNames;
deathByCountry = aggregateByCountry(deathData, varsDeath);

% Exclude China for better visualization
deathExChina = deathByCountry(deathByCountry.("Country/Region") ~= "Mainland China", :);
varsDeath = deathExChina.Properties.VariableNames;

% Create visualization
fig4 = figure('Name', 'Global COVID-19 Deaths', 'Position', [100, 100, FIGURE_WIDTH, FIGURE_HEIGHT]);
t = tiledlayout("flow");

% Plot early pandemic and latest data for comparison
visualizeGlobalCasesMap(deathExChina, varsDeath, [4, length(varsDeath)], t, "colorterrain");

% Set main title
title(t, [" Confirmed COVID-19 Death Cases Worldwide"; ...
    "Countries with <100 deaths highlighted in Magenta"]);

fprintf('Global death cases visualization complete.\n');

%% SECTION 5: 3D Globe Visualization - Death Cases
fprintf('Creating 3D globe visualization for death cases...\n');

% Load preprocessed data for 3D visualization
data3D = readtable(fullfile(DATA_PATH, COVID_3D_FILE));

% Extract coordinates and death data
lat = transpose(data3D.lat);
lon = transpose(data3D.long);
deaths = transpose(data3D.total_deaths);

% Create enhanced 3D globe for death visualization
create3DGlobeVisualization(lat, lon, deaths, 'Deaths', 'red');

fprintf('3D death visualization complete.\n');

%% SECTION 6: 3D Globe Visualization - Confirmed Cases
fprintf('Creating 3D globe visualization for confirmed cases...\n');

% Use same coordinates but with case data
cases = transpose(data3D.total_cases);

% Create enhanced 3D globe for case visualization
create3DGlobeVisualization(lat, lon, cases, 'Cases', 'yellow');

fprintf('3D case visualization complete.\n');

%% Helper Functions

function opts = configureImportOptions(filename)
    % Configures import options for CSV files
    opts = detectImportOptions(filename, "TextType", "string");
    opts.VariableNamesLine = 1;
    opts.DataLines = [2, inf];
    opts.PreserveVariableNames = true;
end

function data = cleanCountryNames(data)
    % Standardizes country names across different datasets
    data.("Country/Region")(data.("Country/Region") == "China") = "Mainland China";
    data.("Country/Region")(data.("Country/Region") == "Czechia") = "Czech Republic";
    data.("Country/Region")(data.("Country/Region") == "Iran (Islamic Republic of)") = "Iran";
    data.("Country/Region")(data.("Country/Region") == "Republic of Korea") = "Korea, South";
    data.("Country/Region")(data.("Country/Region") == "Republic of Moldova") = "Moldova";
    data.("Country/Region")(data.("Country/Region") == "Russian Federation") = "Russia";
    data.("Country/Region")(data.("Country/Region") == "Taipei and environs") = "Taiwan";
    data.("Country/Region")(data.("Country/Region") == "Taiwan*") = "Taiwan";
    data.("Country/Region")(data.("Country/Region") == "United Kingdom") = "UK";
    data.("Country/Region")(data.("Country/Region") == "Viet Nam") = "Vietnam";
    data.("Country/Region")(data.("Province/State") == "St Martin") = "St Martin";
    data.("Country/Region")(data.("Province/State") == "Saint Barthelemy") = "Saint Barthelemy";
end

function aggregatedData = aggregateByCountry(data, vars)
    % Aggregates data by country, summing cases and averaging coordinates
    aggregatedData = groupsummary(data, "Country/Region", {'sum', 'mean'}, vars(3:end));
    
    % Clean up variable names
    newVars = aggregatedData.Properties.VariableNames;
    newVars = regexprep(newVars, "^(sum_)(?=L(a|o))", "remove_");
    newVars = regexprep(newVars, "^(mean_)(?=[0-9])", "remove_");
    newVars = erase(newVars, {'sum_', 'mean_'});
    aggregatedData.Properties.VariableNames = newVars;
    
    % Remove unnecessary columns
    aggregatedData = removevars(aggregatedData, [{'GroupCount'}, newVars(contains(newVars, "remove_"))]);
end

function visualizeGlobalCasesMap(data, vars, indices, layout, basemap)
    % Creates geobubble visualizations for specified indices
    for idx = indices
        % Create categories based on case count
        data.Category = categorical(repmat("<100", height(data), 1));
        data.Category(table2array(data(:, idx)) >= 100) = ">=100";
        
        % Create data subset for visualization
        nexttile
        tableSubset = data(:, [1:3, idx, end]);
        tableSubset(tableSubset.(4) == 0, :) = [];
        
        % Create geobubble visualization
        gb = geobubble(tableSubset, "Lat", "Long", "SizeVariable", vars(idx), ...
                       "ColorVariable", "Category", "Basemap", basemap);
        gb.BubbleColorList = [1, 0, 1; 1, 0, 0];  % Magenta for <100, Red for >=100
        gb.LegendVisible = "off";
        gb.Title = "As of " + vars(idx);
        gb.SizeLimits = [0, max(data.(vars{length(vars)}))];
        gb.MapCenter = [21.6385, 36.1666];
        gb.ZoomLevel = 0.3606;
    end
end

function countryData = prepareCountryData(data, countryName)
    % Extracts and prepares data for a specific country
    countryData = data(data.("Country/Region") == countryName, :);
    
    % Remove non-data columns
    countryData(:, 1) = [];
    countryData(:, 1) = [];
    countryData(:, 1) = [];
    countryData(:, end) = [];
    
    return;
end

function [dateTitles, timeVector] = createTimeVector(data)
    % Creates a datetime vector from column names
    dateTitles = data.Properties.VariableNames;
    timeVector = datetime.empty;
    
    for i = 1:length(dateTitles)
        timeVector(i) = datetime(datevec(dateTitles(i)));
    end
end

function numericData = convertToNumeric(data)
    % Converts table data to numeric format for plotting
    data = varfun(@double, data);
    numericData = single(data.Variables);
end

function plotCountryData(timeVector, countryData, countryName)
    % Plots time series data for a specific country
    plot(timeVector, countryData, "LineWidth", 2.5);
    ylabel("Number of Cases", "FontSize", 12, FontSmoothing="on", ...
           LineStyle="-", FontName='Times New Roman');
    xlabel("Date since 2020", "FontSize", 12, FontSmoothing="on", ...
           FontName='Times New Roman');
    title(countryName, "FontSize", 15, FontSmoothing="on", ...
          FontName='Times New Roman');
    grid on;
    datetick('x', 'mmm-yy', 'keepticks');
end

function [dataFirst, dataSecond] = prepareCountryComparison(data, firstCountry, secondCountry, timeVector)
    % Prepares data for comparing two countries
    countryDataFirst = prepareCountryData(data, firstCountry);
    dataFirst = convertToNumeric(countryDataFirst);
    
    countryDataSecond = prepareCountryData(data, secondCountry);
    dataSecond = convertToNumeric(countryDataSecond);
    
    % Plot comparison
    plot(timeVector, dataFirst, "LineWidth", 2.5);
    hold on;
    plot(timeVector, dataSecond, "LineWidth", 2.5);
    
    % Add labels and formatting
    ylabel("Number of Cases", "FontSize", 12, FontSmoothing="on", ...
           LineStyle="-", FontName='Times New Roman');
    xlabel("Date since 2020", "FontSize", 12, FontSmoothing="on", ...
           FontName='Times New Roman');
    axis tight;
    grid on;
    datetick('x', 'mmm-yy', 'keepticks');
    legend(firstCountry, secondCountry);
    title(sprintf('%s vs %s', firstCountry, secondCountry), "FontSize", 15, ...
          FontSmoothing="on", FontName='Times New Roman');
end

function cleanedData = cleanUSData(data)
    % Cleans US-specific data by removing unnecessary columns
    cleanedData = data;
    cleanedData(:, 1) = [];
    cleanedData(:, 1) = [];
    cleanedData(:, 1) = [];
    cleanedData(:, 1) = [];
    cleanedData(:, 1) = [];
    cleanedData(:, 1) = [];
    cleanedData(:, 2) = [];
    cleanedData(:, 4) = [];
end

function aggregatedData = aggregateByState(data, vars)
    % Aggregates data by US state
    aggregatedData = groupsummary(data, "Province_State", {'sum', 'mean'}, vars(2:end));
    
    % Clean up variable names
    newVars = aggregatedData.Properties.VariableNames;
    newVars = regexprep(newVars, "^(sum_)(?=L(a|o))", "remove_");
    newVars = regexprep(newVars, "^(mean_)(?=[0-9])", "remove_");
    newVars = erase(newVars, {'sum_', 'mean_'});
    aggregatedData.Properties.VariableNames = newVars;
    
    % Remove unnecessary columns
    aggregatedData = removevars(aggregatedData, [{'GroupCount'}, newVars(contains(newVars, "remove_"))]);
end

function visualizeUSStatesMap(data, vars, indices, layout)
    % Creates geobubble visualizations for US states
    for idx = indices
        % Create categories based on case count
        data.Category = categorical(repmat("<100", height(data), 1));
        data.Category(table2array(data(:, idx)) >= 100) = ">=100";
        
        % Create data subset for visualization
        nexttile;
        tableSubset = data(:, [1:4, idx, end]);
        tableSubset(tableSubset.(5) == 0, :) = [];
        
        % Create geobubble visualization
        gb = geobubble(tableSubset, "Lat", "Long_", "SizeVariable", vars(idx), ...
                       "ColorVariable", "Category", "Basemap", "landcover");
        gb.BubbleColorList = [1, 0, 1; 1, 0, 0];  % Magenta for <100, Red for >=100
        gb.LegendVisible = "off";
        gb.Title = "As of " + vars(idx);
        gb.SizeLimits = [0, max(data.(vars{length(vars)}))];
        gb.MapCenter = [44.9669, -113.6201];
        gb.ZoomLevel = 1.7678;
    end
end

function processedData = processStateRankingData(data)
    % Processes US state data for ranking and trend analysis
    % Group by date and state, summing cases and deaths
    statesData = groupsummary(data, {'date', 'state'}, "sum", {'cases', 'deaths'});
    statesData.Properties.VariableNames = erase(statesData.Properties.VariableNames, "sum_");
    
    % Get latest case count for each state
    latestData = groupsummary(statesData, "state", "max", "cases");
    latestData.Properties.VariableNames = erase(latestData.Properties.VariableNames, "max_");
    
    processedData = latestData;
end

function createStateRankingVisualization(data, topCount, originalData)
    % Creates horizontal bar chart of top states by case count
    [sorted, idx] = sort(data.cases, 'descend');
    labels = data.state(idx);
    
    % Select top states
    topValues = sorted(1:topCount);
    topLabels = labels(1:topCount);
    
    % Create visualization
    figure('Name', 'US States Ranking', 'Position', [100, 100, 1000, 800]);
    histogram('Categories', categorical(topLabels), "BinCounts", topValues, ...
              "DisplayOrder", "ascend", "Orientation", "horizontal");
    xlabel("Total Confirmed Cases");
    ylabel("State");
    grid on;
    title([compose("COVID-19 Confirmed Cases by US States - Top %d", topCount); ...
           "As of " + datestr(max(originalData.date))]);
end

function createStateGrowthVisualization(rankingData, originalData)
    % Creates time series plot of top states' growth curves
    [sorted, idx] = sort(rankingData.cases, 'descend');
    labels = rankingData.state(idx);
    topCount = 20;
    topLabels = labels(1:topCount);
    
    % Create visualization
    figure('Name', 'US States Case Growth', 'Position', [100, 100, 1200, 800]);
    
    % Plot each state's growth curve
    hold on;
    for i = 1:length(topLabels)
        stateFilter = originalData.state == topLabels(i);
        plot(originalData.date(stateFilter), originalData.cases(stateFilter), ...
             "LineWidth", 1.5);
    end
    hold off;
    
    % Add labels and formatting
    title(["COVID-19 Confirmed Cases"; compose("Top %d US States", topCount)]);
    legend(topLabels(1:end), "location", "northwest");
    xlabel("As of " + datestr(max(originalData.date)));
    ylabel("Confirmed Cases");
    grid on;
end

function create3DGlobeVisualization(latitude, longitude, metricValues, metricName, markerColor)
    % Creates an enhanced 3D interactive globe visualization of COVID-19 data
    %
    % Parameters:
    %   latitude - Vector of country latitude coordinates
    %   longitude - Vector of country longitude coordinates
    %   metricValues - Vector of data values (cases or deaths)
    %   metricName - String describing the metric ('Cases' or 'Deaths')
    %   markerColor - Color of markers ('red', 'yellow', etc.)
    
    % Create UI figure with descriptive name
    uiFigure = uifigure('Name', sprintf('3D COVID-19 %s Visualization', metricName), ...
                        'Position', [100, 100, 1200, 900]);
    
    % Create a more descriptive label at the top of the figure since title() isn't supported
    headerLabel = uilabel(uiFigure, ...
                         'Text', sprintf('COVID-19 %s by Country - Interactive 3D Globe', metricName), ...
                         'Position', [400, 870, 400, 22], ...
                         'FontSize', 16, ...
                         'FontWeight', 'bold', ...
                         'HorizontalAlignment', 'center');
    
    % Create information panel for interactions
    infoPanel = uipanel(uiFigure, ...
                       'Title', 'Interaction Guide', ...
                       'Position', [20, 20, 300, 150]);
    
    % Add instructions to the panel
    uilabel(infoPanel, 'Text', '• Left-click + drag: Rotate globe', ...
           'Position', [10, 100, 280, 22]);
    uilabel(infoPanel, 'Text', '• Right-click + drag: Zoom in/out', ...
           'Position', [10, 75, 280, 22]);
    uilabel(infoPanel, 'Text', '• Double-click: Reset view', ...
           'Position', [10, 50, 280, 22]);
    uilabel(infoPanel, 'Text', '• Marker size indicates relative magnitude', ...
           'Position', [10, 25, 280, 22]);
    
    % Add a scale reference panel
    scalePanel = uipanel(uiFigure, ...
                        'Title', sprintf('%s Scale Reference', metricName), ...
                        'Position', [880, 20, 300, 230]);
    
    % Create scale information based on metric type
    if strcmp(metricName, 'Deaths')
        scaleInfo = {
            '• Large (red): >1,000,000 deaths', 
            '• Medium-large: 500,000-1,000,000 deaths',
            '• Medium: 100,000-500,000 deaths',
            '• Medium-small: 10,000-100,000 deaths',
            '• Small: 1,000-10,000 deaths',
            '• Very small: <1,000 deaths'
        };
    else % Cases
        scaleInfo = {
            '• Large (yellow): >100,000,000 cases', 
            '• Medium-large: 25,000,000-100,000,000 cases',
            '• Medium: 10,000,000-25,000,000 cases',
            '• Medium-small: 1,000,000-10,000,000 cases',
            '• Small: 300,000-1,000,000 cases',
            '• Very small: <300,000 cases'
        };
    end
    
    % Add scale information to the panel
    for i = 1:length(scaleInfo)
        uilabel(scalePanel, 'Text', scaleInfo{i}, ...
               'Position', [10, 180 - (i-1)*30, 280, 22]);
    end
    
    % Determine marker specs based on metric type
    if strcmp(metricName, 'Deaths')
        markerSpec = 'ro';  % Red circles for deaths
        basemapType = 'darkwater';  % Dark basemap for contrast with red
        altitude = 120000;  % Slightly higher altitude for deaths
    else
        markerSpec = 'yo';  % Yellow circles for cases
        basemapType = 'satellite';  % Satellite basemap for cases
        altitude = 100000;  % Standard altitude for cases
    end
    
    % Create the globe with enhanced appearance
    globe = geoglobe(uiFigure, 'Basemap', basemapType);
    
    % First pass to organize data by size for layered visualization
    sizeCategories = cell(1, 6);  % 6 size categories
    for i = 1:length(latitude)
        [markerSize, sizeCategory] = calculateMarkerSize(metricValues(i), metricName);
        sizeCategories{sizeCategory} = [sizeCategories{sizeCategory}; [latitude(i), longitude(i), metricValues(i)]];
    end
    
    % Plot each size category in layers (smallest first, then larger on top)
    hold(globe, 'on');
    
    % Plot each category (smallest to largest)
    for category = 1:6
        if ~isempty(sizeCategories{category})
            categoryData = sizeCategories{category};
            for j = 1:size(categoryData, 1)
                [markerSize, ~] = calculateMarkerSize(categoryData(j, 3), metricName);
                
                % Plot with slight variation in altitude for 3D effect
                randomAltitudeVariation = altitude * (0.95 + 0.1 * rand());
                
                % Create an "aura" effect with a slightly larger transparent marker underneath
                if markerSize > 10
                    geoplot3(globe, categoryData(j, 1), categoryData(j, 2), randomAltitudeVariation * 0.98, ...
                            markerSpec, 'MarkerSize', markerSize * 1.3, 'MarkerIndices', 1);
                end
                
                % Plot the actual data point
                geoplot3(globe, categoryData(j, 1), categoryData(j, 2), randomAltitudeVariation, ...
                        markerSpec, 'MarkerSize', markerSize, 'MarkerIndices', 1);
            end
        end
    end
    
    hold(globe, 'off');
    
    % Add a country selection dropdown for focusing the view
    topCountries = getTopCountries(latitude, longitude, metricValues, 20);
    countryDropdown = uidropdown(uiFigure, ...
                               'Items', ['Select a country to focus', topCountries], ...
                               'Position', [350, 20, 200, 22], ...
                               'Value', 'Select a country to focus');
    
    % Create a button to reset the view
    resetButton = uibutton(uiFigure, 'push', ...
                         'Text', 'Reset View', ...
                         'Position', [570, 20, 100, 22]);
    
    % Create additional label for current view info
    viewLabel = uilabel(uiFigure, ...
                      'Text', 'Global View', ...
                      'Position', [400, 50, 300, 22], ...
                      'FontSize', 12);
    
    % Set up callbacks
    countryDropdown.ValueChangedFcn = @(src, event) focusOnCountry(globe, latitude, longitude, metricValues, topCountries, src.Value, viewLabel);
    resetButton.ButtonPushedFcn = @(src, event) resetGlobeView(globe, viewLabel);
end

function [size, category] = calculateMarkerSize(value, metricType)
    % Calculates appropriate marker size and category based on metric value
    % Returns both the size and the category (1-6, where 6 is largest)
    
    if strcmp(metricType, 'Deaths')
        % Size buckets for death counts
        if value >= 1000000
            size = 50;     % > 1M deaths
            category = 6;  % Largest category
        elseif value > 500000
            size = 35;     % 500K-1M deaths
            category = 5;
        elseif value >= 100000
            size = 20;     % 100K-500K deaths
            category = 4;
        elseif value >= 10000
            size = 12;     % 10K-100K deaths
            category = 3;
        elseif value >= 1000
            size = 8;      % 1K-10K deaths
            category = 2;
        else
            size = 4;      % < 1K deaths
            category = 1;  % Smallest category
        end
    else
        % Size buckets for case counts
        if value >= 100000000
            size = 50;     % > 100M cases
            category = 6;  % Largest category
        elseif value >= 25000000
            size = 35;     % 25M-100M cases
            category = 5;
        elseif value >= 10000000
            size = 20;     % 10M-25M cases
            category = 4;
        elseif value >= 1000000
            size = 12;     % 1M-10M cases
            category = 3;
        elseif value >= 300000
            size = 8;      % 300K-1M cases
            category = 2;
        else
            size = 4;      % < 300K cases
            category = 1;  % Smallest category
        end
    end
end

function topCountries = getTopCountries(latitude, longitude, values, numCountries)
    % Gets a list of the top countries by value for the dropdown
    % This is a placeholder - in a real implementation, you would need to have country names
    % For demonstration, using "Country X" where X is the index of sorted values
    
    % Sort values in descending order and get indices
    [sortedValues, indices] = sort(values, 'descend');
    
    % Get the top N indices
    topIndices = indices(1:min(numCountries, length(indices)));
    
    % Map country names (this is where you'd use actual country names if available)
    % For demo purposes using "Country X (Value)" format
    topCountries = cell(1, length(topIndices));
    for i = 1:length(topIndices)
        idx = topIndices(i);
        % Format: "Country X (Value)"
        topCountries{i} = sprintf('Country %d (%.1fM)', idx, values(idx)/1000000);
    end
end

function focusOnCountry(globe, latitude, longitude, values, countryList, selectedCountry, viewLabel)
    % Focuses the globe view on a selected country
    
    % If "Select a country" is chosen, do nothing
    if strcmp(selectedCountry, 'Select a country to focus')
        return;
    end
    
    % Find the index of the selected country in the list
    idx = find(strcmp(countryList, selectedCountry));
    
    if ~isempty(idx)
        % Get the original index from the sorted list
        % This is a simplified approach - in reality, you would match by actual country name
        
        % Extract country index from the selection string (format: "Country X (Value)")
        countryStr = selectedCountry;
        spaceIdx = strfind(countryStr, ' ');
        parenIdx = strfind(countryStr, '(');
        
        if ~isempty(spaceIdx) && ~isempty(parenIdx) && parenIdx(1) > spaceIdx(1)
            countryIdx = str2double(countryStr(spaceIdx(1)+1:parenIdx(1)-1));
            
            % Focus the view on this country's coordinates
            if ~isnan(countryIdx) && countryIdx > 0 && countryIdx <= length(latitude)
                geobasemap(globe, 'satellite');  % Switch to satellite for close-up
                geolimits(globe, [latitude(countryIdx)-10 latitude(countryIdx)+10], ...
                         [longitude(countryIdx)-15 longitude(countryIdx)+15]);
                
                % Update the view info label
                viewLabel.Text = sprintf('Viewing: %s (%.1fM)', selectedCountry, values(countryIdx)/1000000);
            end
        end
    end
end

function resetGlobeView(globe, viewLabel)
    % Resets the globe view to global perspective
    geolimits(globe, [-90 90], [-180 180]);  % Full earth view
    geobasemap(globe, 'darkwater');          % Reset to original basemap
    viewLabel.Text = 'Global View';          % Reset label
end