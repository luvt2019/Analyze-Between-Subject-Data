function [CI] = matrixSummary(dataMat,format,header,adjust)
% dataMat: The matrix of data that we've collected from participants. It has
%          size nrow x ncolumns (matrices tend to be organized with
%          subjects as the rows and conditions/task as the columns)
% format: 2 x ncolumn string array; determines the format of the data printed
%         in the table using the %w.df format as in fprintf. The entry in
%         the first row is w, the width of the total number (determines how
%         many digits there are in the number, including the decimal
%         point). The entry in the second row is d, the number of digits to
%         go after the decimal point.
% header: A cell array; the first entry is the main header, this could be 
%         an overall title for the table or a label for the columns.
%         Entries 2 through nCols+1 are column headers. The last entry is 
%         the main row header; the rows are simply numbered.
% adjust: Can be "true" or "false". It determines whether to do ttest on
%         adjusted data matrix or raw data matrix. The adjusted data
%         set has the row (subject) means removed so that the error reflects
%         just the Subject x Condition interaction not the main effects of
%         Subjects.
% Example:
% Consider the follow data matrix, the results of 6 students on three tests
%   Data = [87 94 97; 77 74 90; 84 86 100; 61 73 80; 73 64 85; 91 100 94];
% Then the call: matrixSummary(Data, repmat([6;1], 1, 3), ...
%               {'Tests' 'Midterm 1' 'Midterm 2' 'Final' 'Students'}, ...
%               true);
% Would produce the following table
%          Tests
% Students Midterm 1 Midterm 2  Final 
%        1      87.0      94.0   97.0 
%        2      77.0      74.0   90.0 
%        3      84.0      86.0  100.0 
%        4      61.0      73.0   80.0 
%        5      73.0      64.0   85.0 
%        6      91.0     100.0   94.0 
% 
%     Mean      78.8      81.8   91.0 
%       SD       3.2       5.7    4.6 
%   UpperB      82.1      87.8   95.8 
%   LowerB      75.5      75.9   86.2 
%        T    61.280    35.400 48.428 
%        p     0.000     0.000  0.000 
% 
% Because the argument adjust was set to true for this run, the standard
%  deviation, tests, and confidence intervals were computed excluding the
%  overall differences between subjects, that is, in a manner that emphases
%  the differences between conditions. Seeting this argument false produces
%     Mean      78.8      81.8   91.0 
%       SD      10.9      13.8    7.5 
%   UpperB      90.3      96.3   98.9 
%   LowerB      67.4      67.3   83.1 
%        T    17.674    14.521 29.576 
%        p     0.000     0.000  0.000 

[nRows, nCols] = size(dataMat);
if length(header) ~= nCols + 2
    error(['The header cell array should contain %d strings: an overall header,' ...
        '\none for each of the %d columns in dataMat, and a header for the rows'], ...
        nCols+2, nCols);
end
nRowHdrCols = length(header{end});
if nRowHdrCols < 6
    nRowHdrCols = 6; % Ensure if there is room for the lowerB/upperB strings
end
rowHdrColsFmtStr = sprintf('%%%ds ', nRowHdrCols);
rowHdrColsFmtNum = sprintf('%%%dd ', nRowHdrCols);

% Print headers
fprintf(rowHdrColsFmtStr, ' ');
fprintf('%s\n',header{1});
fprintf(rowHdrColsFmtStr, header{end});
rowHdrLengths = NaN(1, nCols);
for ic = 1:nCols
    fmt = sprintf('%%%ds ', format(1, ic));
    fprintf(fmt, header{ic+1});
    rowHdrLengths(ic) = length(header{ic+1});
end
fprintf('\n')

% Print data
fs = cell(1,nCols);
for ic = 1:nCols
    if format(1,ic) < rowHdrLengths(ic)
        % Ensure columns are wide enough for the column headers
        format(1,ic) = rowHdrLengths(ic); 
    end
    fs{ic} = sprintf('%%%d.%df ', format(1,ic), format(2,ic));
end

for ir = 1:nRows % print row header before print rows of data
    fprintf(rowHdrColsFmtNum, ir);
    for ic = 1:nCols;
        fprintf(fs{ic},dataMat(ir,ic));
    end
    fprintf('\n');
end

fprintf('\n');
fprintf(rowHdrColsFmtStr, 'Mean');
means = mean(dataMat);
for ic = 1:length(dataMat(1,:));
    fprintf(fs{ic},means(ic));
end
fprintf('\n');

% T-test
P = NaN(1, nCols);
CI = NaN(nCols, 2);
if adjust == true
   adjustedMat = dataMat - repmat(mean(dataMat,2) - mean(dataMat(:)), 1, ...
       size(dataMat,2));
   CIadj = 1/sqrt((nCols-1)/nCols); % The adjusted CIs are biased small Morey(2008)
   for ic = 1:nCols
       [~,P(ic), CI(ic,:), STATS(ic)] = ttest(adjustedMat(:,ic)); %#ok<*AGROW>
       CI(ic, 1) = means(ic) - CIadj*(means(ic) - CI(ic,1));
       CI(ic, 2) = CIadj*(CI(ic,2) - means(ic)) + means(ic);
   end
else
   for ic = 1:nCols
       [~,P(ic), CI(ic,:), STATS(ic)] = ttest(dataMat(:,ic));
   end
end

fprintf(rowHdrColsFmtStr, 'SD');
for ic = 1:nCols;
    fprintf(fs{ic},STATS(ic).sd);
end
fprintf('\n');

fprintf(rowHdrColsFmtStr, 'UpperB');
for ic = 1:nCols;
    fprintf(fs{ic},CI(ic,2));
end
fprintf('\n');

fprintf(rowHdrColsFmtStr, 'LowerB');
for ic = 1:nCols;
    fprintf(fs{ic},CI(ic,1));
end
fprintf('\n');

% Print P and T statistics
for ic = 1:nCols
    fs{ic} = sprintf('%%%d.3f ',format(1,ic));
end

fprintf(rowHdrColsFmtStr, 'T');
for ic = 1:nCols;
    fprintf(fs{ic},STATS(ic).tstat);
end
fprintf('\n');

fprintf(rowHdrColsFmtStr, 'p');
for ic = 1:nCols;
    fprintf(fs{ic},P(ic));
end
fprintf('\n');

end