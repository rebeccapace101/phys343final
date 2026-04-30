%read data in from *.txt
% Get a list of all CSV files in the current directory.
fileList = dir('*.txt');

% Check if any CSV files were found.
if isempty(fileList)
    fprintf('No txt files found in the current directory.\n');
else
    % Create a containers.Map object to store the data.
    % The keys will be the filenames and the values will be the table data.
    allData = containers.Map;
    
    % Loop through each file in the list.
    for i = 1:length(fileList)
        % Get the name of the current file.
        fileName = fileList(i).name;
                
        try
            % Read the data from the CSV file into a table.
            currentData = readtable(fileName);
            
            % Store the read data in the map, using the filename as the key.
            allData(fileName) = currentData;
                        
        catch ME
            % Display an error message if the file cannot be read.
            fprintf('Error reading file %s: %s\n', fileName, ME.message);
        end
    end
    
    % Example of how to access the data from one of the files.
    % We get all the keys (filenames) and display the data from the first one.
    fileNames = keys(allData);
    if ~isempty(fileNames)
        firstFile = fileNames{1};
        fprintf('\nDisplaying the first 5 rows of the first processed file ("%s"):\n', firstFile);
        disp(head(allData(firstFile), 5));
    end
    
    fprintf('\nAll files have been processed.\n');
    fprintf('The data is now stored in the "allData" containers.Map object, labeled by filename.\n');
end
%use damped fit to find damping coeficiant for all trials

%find mean and standard deviation of each set of 5 in a pressure group

%plot trial at atm and 100mTorr

% plot presure vs damping coeficiant