% TEST_SELECT_SWEEPS tests selecting and combining sweeps from 
% one or more files by using SELECT_SWEEPS function. 
% 
%
% Copyright (C) 2024,2025 Alois Schlögl, ISTA 
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
if ispc() 
	KDrive='K:';
else
	KDrive=fullfile(getenv('HOME'), 'K');
end

%%% Input data %%% 
FILENAME = fullfile(KDrive, 'Rebecca/for_alois/20240701_008.cfs');
SELECT_SWEEPS = [1:7:28];


select_sweeps([FILENAME,'.sweepsremoved.gdf'], FILENAME, SELECT_SWEEPS);
select_sweeps([FILENAME,'.sweepsremoved2.gdf'], {FILENAME, SELECT_SWEEPS;FILENAME, SELECT_SWEEPS+1; FILENAME, SELECT_SWEEPS+3; FILENAME, SELECT_SWEEPS+4});


