function [ROImask indMask ] = growROI(Tmap,ROIpeak,ROIsize,cutoff)

%growROI  Grow Region of Interest Mask
%  mask = growROI(Tmap, ROIpeak, ROIsize, cutoff) finds all voxels 
%  contiguous with a peak voxel and and returns a binary valued matrix in
%  roiMask. ROIpeak is the co-ordinates of the peak voxel in xyz space.
%  Tmap is a matrix of T-values for a contrast. ROIsize is the maximum
%  number of voxels included in the mask. cutoff is the critcal T-value for
%  inclusion in the mask.

%Summary
%  growROI finds all voxels adjacent to the peak voxel and includes the
%  voxel with the highest T-value in the mask. This process is repeated,
%  until the ROI is of specified size, or no voxels can be found that pass
%  the cutoff.

%  growROI initially adds all voxels adjacent to the peak voxel to a
%  binary valued matrix called adjacent. Only voxels that are directly
%  adjacent are interrogated (no diagonals). T-value for these voxels is
%  extracted from Tmap and the co-ordinate of the voxel with the highest
%  T-value is added to the binary valued ROImask matrix. 

%  On all subsequent iterations, all voxels adjacent to those currently in
%  the mask  matrix are added to the adjacent matrix. Voxels currently in
%  the mask matrix are removed from the adjacent matrix to ensure that only
%  voxels that are not currently in the ROImask are considered.

% This process is repeated until either ROImask contains the number of
% voxels specified by ROIsize, or no voxels can be found that pass the
% cutoff.

% USAGE: To create ROIs of specific size, regadless to T-value, set cutoff
% to zero. To create ROIs that only include voxels above a specific T-value
% set ROIsize to a large number e.g., 10000.

% Peak voxel co-ordinates
i=ROIpeak(1);
j=ROIpeak(2);
k=ROIpeak(3);

% dimensions of the brain image
[x y z] = size(Tmap);

% Initialise ROImask, add peak voxel to the mask
ROImask = zeros(size(Tmap));
ROImask(i,j,k) = 1;

%CHECK THAT COORDINATES EXIST WITHIN THE TMAP
%CHECK THAT ROISIZE IS NOT TOO LARGE OR TOO SMALL
%CHECK THAT TMAP CONTAINS T-VALUES GREATER THAN THE CUTTOFF

% Initalise indMask, add peak voxel to the mask
indMask = zeros(size(Tmap));
indMask(i,j,k) = 1;

% Initalise adjacent, add all voxels adjacent to the peak value
adjacent = zeros(size(Tmap));

% iterate until ROI reaches specified size
for curVox = 2:ROIsize
    
    %add all adjacent voxels adjacent to the new voxel to adjacent. Check
    %that each adjacent voxel exists within xyz space of the TMAP.
    if i<x
    adjacent(i+1,j,k) = 1;
    end
    if i>1
    adjacent(i-1,j,k) = 1;
    end
    if j<y
    adjacent(i,j+1,k) = 1;
    end
    if j>1
    adjacent(i,j-1,k) = 1;
    end
    if k<z
    adjacent(i,j,k+1) = 1;
    end
    if k>1
    adjacent(i,j,k-1) = 1;
    end

    
    %find all voxels that are adjacent to voxels in the mask, but not
    %included in the mask
    candidate = adjacent~=ROImask;
    
    %store Tvalues in temporary matrix
    tempT = Tmap;
    
    %set all non-candiate voxels T values to zero
    tempT(candidate==0) = 0;
    
    %find coordinate of highest Tvalue
    [value ind] = max(tempT(:));
    [i j k] = ind2sub(size(Tmap),ind);
    
    %stop loop if the Tvalue of the selected voxel is less than the cutoff
    if value <= cutoff
        break
    end
    
    %add new voxel to the mask, and adjacent
    ROImask(i,j,k) = 1;
    indMask(i,j,k) = curVox;
    adjacent(i,j,k) = 1;
    
    
end

fprintf('Done \n created ROI with %d voxels, lowest T-value = %d\n',curVox,value)



%%ADD code that provides ROI stats, histogram of voxel Tvalues
