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

function f = smoothMeshFunction(vertices, faces, f, varargin) %#ok<INUSL>
%SMOOTHMESHFUNCTION Apply smoothing on a functions defines on mesh vertices.
%
%   FS = smoothMeshFunction(VERTICES, FACES, F, NITERS)
%   Performs smoothing on the function F defined on vertices of the mesh.
%   The mesh is specified by VERTICES and FACES array. At each iteration,
%   the value for each vertex is obtained as the average of values obtained
%   from neighbor vertices.
%   NITERS is the number of times the iteration must be repeated. By
%   default it equals 3.
%
%   Example
%   smoothMeshFunction
%
%   See also 
%     meshes3d, meshCurvatures

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2021-09-22, using Matlab 9.10.0.1684407 (R2021a) Update 3
% Copyright 2021-2023 INRAE - BIA Research Unit - BIBS Platform (Nantes)

% determines number of iterations
nIters = 3;
if ~isempty(varargin)
    nIters = varargin{1};
end
    
% apply smoothing on scalar function
nv = max(faces(:));

% compute normalized averaging matrix
W = meshAdjacencyMatrix(faces) + speye(nv);
D = spdiags(full(sum(W,2).^(-1)), 0, nv, nv);
W = D * W;

% do averaging to smooth the field
for j = 1:size(f, 2)
    for k = 1:nIters
        f(:,j) = W * f(:,j);
    end
end
