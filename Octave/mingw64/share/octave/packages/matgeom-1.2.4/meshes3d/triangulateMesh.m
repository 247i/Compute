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

function varargout = triangulateMesh(varargin)
%TRIANGULATEMESH Convert a non-triangle mesh into a triangle mesh.
%
%   [V2, F2] = triangulateMesh(V, F)
%   Convert the mesh represented by vertices V and faces F into a triangle
%   mesh. V is N-by-3 numeric array containing vertex coordinates. F is an
%   array representing faces: either a N-by-4 or N-by-3 numeric array, or a
%   cell array for meshes with non homogeneous face vertex counts.
%   The result is a mesh with same vertices (V == F), and F2 represented as
%   a N-by-3 numeric array. If the input mesh is already a triangular mesh,
%   the result is the same as the input.
%
%   [V2, F2] = triangulateMesh(MESH)
%   Specifies the mesh as a structure with at least two fields 'vertices'
%   and 'faces'. 
%
%   MESH2 = triangulateMesh(...)
%   Returns the result as a mesh data structure with two fields 'vertices'
%   and 'faces'. 
%
%   Example
%     % create a basic shape
%     [v, f] = createCubeOctahedron;
%     % draw with plain faces
%     figure; hold on; axis equal; view(3);
%     drawMesh(v, f);
%     % draw as a triangulation
%     [v2, f2] = triangulateMesh(v, f);
%     figure; hold on; axis equal; view(3);
%     drawMesh(v2, f2, 'facecolor', 'r');
%
%   See also 
%     meshes3d, triangulateFaces, drawMesh
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2024-02-16,    using Matlab 23.2.0.2459199 (R2023b) Update 5
% Copyright 2024 INRAE.

[vertices, faces] = parseMeshData(varargin{:});

faces2 = triangulateFaces(faces);

varargout = formatMeshOutput(nargout, vertices, faces2);
