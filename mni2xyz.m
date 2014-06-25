function [XYZcoOrds] = mni2xyz(vol,MNIcoOrds)

[m n] = size(MNIcoOrds);
if n > m
    MNIcoOrds = MNIcoOrds';
end

XYZcoOrds = round(inv(vol.mat)*[MNIcoOrds; 1]);
