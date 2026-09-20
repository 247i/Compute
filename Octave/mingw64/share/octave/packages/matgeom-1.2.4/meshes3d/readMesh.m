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

function varargout = readMesh(filePath, varargin)
%READMESH Read a 3D mesh by inferring format from file name.
%
%   Usage:
%   [V, F] = readMesh(FILENAME)
%   Read the data stored in file FILENAME and return the vertex and face
%   arrays as NV-by-3 array and NF-by-N array respectively, where NV is the
%   number of vertices and NF is the number of faces.
%
%   MESH = readMesh(FILENAME)
%   Read the data stored in file FILENAME and return the mesh into a struct
%   with fields 'vertices' and 'faces'.
%   The struct also comprises two fields "name" and "fileName":
%   * "name" corresponds to the base name of the file (without path and
%       extension)
%   * "filePath" corresponds to the full (relative) path name of the file. 
%
%   Example
%     mesh = readMesh('apple.ply');
%     figure; drawMesh(mesh);
%     view([180 -70]); axis equal;
%
%   See also 
%     meshes3d, writeMesh, readMesh_off, readMesh_ply, readMesh_stl
%

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2020-11-20, using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020-2023 INRAE - BIA Research Unit - BIBS Platform (Nantes)

parser = inputParser;
addParameter(parser, 'trimMesh', true, @islogical);
parse(parser, varargin{:});

[~, baseName, ext] = fileparts(filePath);
switch lower(ext)
    case '.off'
        mesh = readMesh_off(filePath);
    case '.ply'
        mesh = readMesh_ply(filePath);
    case '.stl'
        mesh = readMesh_stl(filePath);
    case '.obj'
        mesh = readMesh_obj(filePath);
    otherwise
        error('readMesh.m function does not support %s files.', upper(ext(2:end)));
end

% format output arguments
varargout = formatMeshOutput(nargout, mesh.vertices, mesh.faces);

% in case of mesh returned as a struct, also include the file name as field
if isstruct(varargout{1})
    varargout{1}.name = baseName;
    varargout{1}.filePath = filePath;
end
