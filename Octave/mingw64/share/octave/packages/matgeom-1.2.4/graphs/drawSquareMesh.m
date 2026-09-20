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

function varargout = drawSquareMesh(nodes, edges, faces, varargin) %#ok<INUSL>
%DRAWSQUAREMESH Draw a 3D square mesh given as a graph.
%
%   drawSquareMesh(NODES, EDGES, FACES)
%   Draw the mesh defined by NODES, EDGES and FACES. FACES must be a N-by-4
%   array of vertex indices.
%
%   See also 
%   boundaryGraph, drawGraph

% ------
% Author: David Legland 
% E-mail: david.legland@inrae.fr
% Created: 2004-06-28
% Copyright 2004-2023 INRA - TPV URPOI - BIA IMASTE

% input size check up
if size(faces, 2) ~= 4
    error('Requires a face array with 4 columns');
end

% number of faces
Nf = size(faces, 1);

% allocate memory for vertex coordinates
px = zeros(4, Nf);
py = zeros(4, Nf);
pz = zeros(4, Nf);

% initialize vertex coordinates of each face
for f = 1:Nf
    face = faces(f, 1:4);
    px(1:4, f) = nodes(face, 1);
    py(1:4, f) = nodes(face, 2);
    pz(1:4, f) = nodes(face, 3);
end

p = patch(px, py, pz, 'r');

if nargout > 0
    varargout = {p};
end
