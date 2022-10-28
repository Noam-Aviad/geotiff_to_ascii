% Enter the wanted file names and directory for the converted file
% ***GeoTIFF file and its hdr file must be in the script's directory***
tiffFileName = "..." + ".tif";
headerFileName = "..." + ".hdr";
newFileDirectory = "...";
newFileName = "..." + ".asc";

convert(tiffFileName, headerFileName, newFileDirectory, newFileName)

function convert(tiffFileName, headerFileName, newFileDirectory, newFileName)
    % Reading elevation data from GeoTIFF:
    tiffElelvationMat = readgeoraster(tiffFileName); 
    % Getting data from the header file:
    headerID = fopen(headerFileName,'r');
    header = convertCharsToStrings(fscanf(headerID,'%c'));
    [nRows nCols] = size(tiffElelvationMat);
    cellSize = splitlines(extractAfter(header, 'ModelPixelScaleTag (1,3):'));
    cellSize =str2double(extractBefore(extractAfter(cellSize(2), '         '), ' '));
    lower_left_coordinates = extractBefore(extractAfter(header, 'Lower Left    ('), ')');
    xllCorner = str2double(extractBefore(lower_left_coordinates, ','));
    yllCorner = str2double(extractAfter(lower_left_coordinates, ','));
    % Creating the ASCII file:
    asciiFile = fopen(fullfile(newFileDirectory, newFileName'),'wt');
    % Formatting the header data:
    fileData = "ncols         " + num2str(nCols) + "\n" + "nrows         " + num2str(nRows);
    fileData = fileData + "\nxllcorner     " + xllCorner + "\nyllcorner     " + yllCorner;
    fileData = fileData + "\ncellsize      " + cellSize + "\nNODATA_value  -9999";
    % Formatting the elevation data
    for row = 1:nRows
        fileData = fileData + "\n" + extractBefore(extractAfter(mat2str(tiffElelvationMat(row, :)), '['), ']');
    end
    % Writing data to ASCII file and closing:
    fprintf(asciiFile, fileData);
    fclose(asciiFile);
    display("Done.")
end