function fix_fpulse_glitch_correct_current_clamp_channel_for_x20(filename)
% FIX_FPULSE_GLITCH_correct_current_clamp_channel_for_x20
% fixes a glitch in fpulse when current clamp channel 
% is off by a factor of x20 
% 
%  Usage:
%      fix_fpulse_glitch_correct_current_clamp_channel_for_x20(filename)
%
%  This will read the file indicated by filename, identify the 
%   current clamp channel based on its physical units being a voltage scale,
%   correct the scaling factors by a factor 1/20, and save the file in 
%   GDF format under the filename being extended by '.x20corrected.gdf'
% 
% Requirements:
%   mexSSAVE from biosig v2.6.3 or later (earlier versions are buggy).

%
% Copyright (C) 2025, Alois Schlögl, ISTA 
%
%    BioSig is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    BioSig is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with BioSig.  If not, see <http://www.gnu.org/licenses/>.


if exist('mexSLOAD','file')==3,
	;
elseif exist('OCTAVE_VERSION','builtin')
	pkg load biosig
else 
	%% addpath to biosig 	
end

% load data
[data,HDR]=mexSLOAD(filename,'r','UCAL:ON');

% identify voltage channel, i.e. current-clamp channel 
vchan=find(bitand(HDR.PhysDimCode,hex2dec('ffe0'))==4256);
if any(vchan~=2)
	error('an expected channel has been identified - please double check what went wrong here');
end

% correct scaling factors
HDR.PhysMin(vchan)=HDR.PhysMin(vchan)/20;
HDR.PhysMax(vchan)=HDR.PhysMax(vchan)/20;
HDR.Cal(vchan)=HDR.Cal(vchan)/20;
HDR.Off(vchan)=HDR.Off(vchan)/20;

% write output file 
HDR.FileName=[HDR.FileName,'.x20corrected.gdf'];
HDR.TYPE='GDF'; HDR.VERSION=3.0;
mexSSAVE(HDR,data);   

