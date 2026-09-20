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

function varargout = trimMesh(varargin)
%TRIMMESH Reduce memory footprint of a polygonal mesh.
%
%   [V2, F2] = trimMesh(V, F)
%   Unreferenced vertices are removed.
%   Following functions are implemented only for numeric faces:
%       Duplicate vertices are removed.
%       Duplicate faces are removed.
%
%   Example
%     [V, F] = createIcosahedron;
%     F(13:20, :) = [];
%     [V2, F2] = trimMesh(V, F);
%     figure; drawMesh(V2, F2)
%     view(3); axis equal;
%     axis([-1 1 -1 1 0 2])
%
%   See also 
%     meshes3d, clipMeshVertices

% ------
% Author: David Legland, oqilipo
% E-mail: david.legland@inrae.fr
% Created: 2014-08-01, using Matlab 8.3.0.532 (R2014a)
% Copyright 2014-2023 INRA - Cepia Software Platform

% parse input data
[vertices, faces] = parseMeshData(varargin{:});

if isnumeric(faces)
    % Process meshes with faces given as Nf-by-3 or Nf-by-4 numeric arrays

    % Delete duplicate vertices
    [tempVertices, tempFaces] = removeDuplicateVertices(vertices, faces);
    % Delete unindexed/unreferenced vertices
    [tempVertices2, tempFaces2] = removeUnreferencedVertices(tempVertices, tempFaces);
    % Delete duplicate faces
    [~, uniqueFaceIdx, ~] = unique(tempFaces2, 'rows');
    duplicateFaceIdx = ~ismember(1:size(tempFaces2,1), uniqueFaceIdx);
    [vertices2, faces2] = removeMeshFaces(tempVertices2, tempFaces2, duplicateFaceIdx);

elseif iscell(faces)
    % Process meshes with faces given as cell array of row vectors

    nVertices = size(vertices, 1);
    nFaces = length(faces);

    % identify vertices referenced by at least one face
    vertexUsed = false(nVertices, 1);
    for iFace = 1:nFaces
        face = faces{iFace};
        vertexUsed(face) = true;
    end
    vertices2 = vertices(vertexUsed, :);

    % compute map from old index to new index
    inds = find(vertexUsed);
    newInds = zeros(nVertices, 1);
    for iIndex = 1:length(inds)
        newInds(inds(iIndex)) = iIndex;
    end
    
    % change labels of vertices referenced by faces
    faces2 = cell(1, nFaces);
    for iFace = 1:nFaces
        faces2{iFace} = newInds(faces{iFace})';
    end
    
else
    error('matGeom:trimMesh', ...
        'Unsupported representation for mesh faces');
end

% format output arguments
varargout = formatMeshOutput(nargout, vertices2, faces2);
