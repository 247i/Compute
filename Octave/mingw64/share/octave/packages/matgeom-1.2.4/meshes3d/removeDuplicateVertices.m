## Copyright (C) 2024 David Legland
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## 
## The views and conclusions contained in the software and documentation are
## those of the authors and should not be interpreted as representing official
## policies, either expressed or implied, of the copyright holders.

function varargout = removeDuplicateVertices(v,varargin)
%REMOVEDUPLICATEVERTICES Remove duplicate vertices of a mesh.
%
%   [V2, F2] = removeDuplicateVertices(V, F) 
%   Remove duplicate vertices of a mesh defined by the vertices V and 
%   faces F.
%
%   [V2, F2] = removeDuplicateVertices(V, F, TOL)
%   Remove duplicate vertices with the tolerance TOL:
%       TOL = 0     -> Exact match
%       TOL = 1e-1  -> Match up to first decimal
%       TOL = 1     -> Integer match
%
%   [VIDX, FIDX] = removeDuplicateVertices(V, F, TOL, 'indexOutput', true)
%   Gives the indices instead of the final mesh. This means:
%       V2 = V(VIDX,:)
%       F2 = FIDX(F)
%       V = V2(FIDX,:)
%
%   Example
%     v = [6-1e-6,0,-5;4,2,-2*pi;0,2,-7;6,0,-5;3,1,-9;0,2,-7;...
%         6,0,-5+1e-6;4,2,-2*pi;3,1,-9;4,2,-2*pi;6,4,-6;3,1,-9;...
%         4,2,-2*pi;0,2,-7;6,4,-6;6,4,-6;0,2,-7;3,1,-9];
%     f = reshape(1:18,3,6)';
%     [v, f] = removeDuplicateVertices(v, f);
%   
%   See also 
%     trimMesh, removeDuplicateFaces, removeUnreferencedVertices
%
%   Source
%     patchslim.m by Francis Esmonde-White:
%       https://mathworks.com/matlabcentral/fileexchange/29986
%     remove_duplicate_vertices.m by Alec Jacobson:
%       https://github.com/alecjacobson/gptoolbox

% ------
% Author: oqilipo
% E-mail: N/A
% Created: 2023-05-14, using Matlab 9.13.0.2080170 (R2022b) Update 1
% Copyright 2023

%% Parse input
if isstruct(v)
    [v, f] = parseMeshData(v);
else
    f = varargin{1};
    varargin(1) = [];
end

parser = inputParser;
logParValidFunc = @(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addOptional(parser, 'tol', 0, @(x) validateattributes(x, {'numeric'}, {'scalar', '>=',0, '<=',1}));
addParameter(parser, 'indexOutput', false, logParValidFunc);
parse(parser, varargin{:});
tol = parser.Results.tol;
indexOutput = parser.Results.indexOutput;

%% Remove duplicate vertices
if tol == 0
    [~, vIdx, fIdx] = unique(v,'rows','stable');
else
    [~, vIdx, fIdx] = unique(round(v/(tol)),'rows','stable');
end

%% Parse output
if indexOutput
    % If indices are requested
    varargout = {vIdx, fIdx};
else
    % Output is the final mesh
    v2 = v(vIdx,:);
    f2 = fIdx(f);
    varargout = formatMeshOutput(nargout, v2, f2);
end

end
