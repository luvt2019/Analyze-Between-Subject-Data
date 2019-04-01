function [output] = getContrasts(dataMat, contrastMat)
% dataMat: Data organized into matrix form of size nRows by nCols (typically, 
%   rows are subjects and columns are conditions or tasks in the experiment
% contrastMat: Matrix of contrasts to apply to data matrix; 
%   nRows = the number of contrasts user wants to apply
%   nCols = the same as nCols in dataMat. The entries in each column are
%           contrast coefficent to be applied to each condition for the
%           contrast defined by this row.
%   N.B. Although not enforced, contrast coefficient should sum to zero
%
% output: The resulting matrix after the contrast are applied
%   nRows = number of subjects
%   nCols = number of contrasts
% The resulting contrast matrix can now be usefully summarized using
%   the matrixSummary function.
%
% Example: Continuing the example begin in the help for matrixSummary()
% Consider the follow data matrix, the results of 6 students on three
%  tests, two mid-terms (Columns 1 and 2) and a Final (Column 3)
%   Data = [ 82 89 92; 82 79 95; 78 80 94; 69 81 88; 79 70 91;  83 92 86 ];
% Our goal might be to compute two contrasts (there are, after all, two
%  degrees of freedom in these data, one comparing the mid-terms, and one
%  comparing the final to the average of the mid-terms. This call does that
%   cntrstRes = getContrasts(Data, [-1 1 0; -.5 -.5 1]);
% These contrasts can be nicely summarized using this call
%   matrixSummary(cntrstRes, repmat([6;1], 1, 2), ...
%       {'Contrasts' 'MT1 vs MT2' 'MTavg vs Final' 'Students'}, false);
% Note that the contrasts already eliminate the main effects of Students,
% so it makes sense for the adjust argument to be false. This call produces
%
%          Contrasts
% Students MT1 vs MT2 MTavg vs Final 
%        1        7.0            6.5 
%        2       -3.0           14.5 
%        3        2.0           15.0 
%        4       12.0           13.0 
%        5       -9.0           16.5 
%        6        9.0           -1.5 
% 
%     Mean        3.0           10.7 
%       SD        7.9            6.9 
%   UpperB       11.3           17.9 
%   LowerB       -5.3            3.4 
%        T      0.927          3.784 
%        p      0.396          0.013 

nRowsData = length(dataMat(:,1));
nRowsContrast = length(contrastMat(:,1));
output = NaN(nRowsData,nRowsContrast);

for k = 1:nRowsData
    for p = 1:nRowsContrast
        output(k,p) = sum(dataMat(k,:) .* contrastMat(p,:));
    end
end

end