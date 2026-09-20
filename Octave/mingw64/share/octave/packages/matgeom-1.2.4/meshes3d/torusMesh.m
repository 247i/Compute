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

function varargout = torusMesh(torus, varargin)
%TORUSMESH Create a 3D mesh representing a torus.
%
%   [V, F] = torusMesh(TORUS)
%   Converts the torus in TORUS into a face-vertex quadrangular mesh.
%   TORUS is given by [XC YC ZY R1 R2 THETA PHI]
%   where (XC YZ ZC) is the center of the torus, R1 is the main radius, R2
%   is the radius of the torus section, and (THETA PHI) is the angle of the
%   torus normal vector (both in degrees).
%
%   [V, F] = torusMesh(TORUS, 'nTheta', NT, 'nPhi', NP)
%   Creates a mesh using NP circles, each circle being discretized with NT
%   vertices. Default are 60 for both parameters.
%
%   [V, F] = torusMesh()
%   Creates a mesh representing a default torus.
%
%   Example
%     [v, f] = torusMesh([50 50 50  30 10  30 45]);
%     figure; drawMesh(v, f, 'linestyle', 'none');
%     view(3); axis equal; 
%     lighting gouraud; light;
%
%
%   See also 
%     meshes3d, drawTorus, revolutionSurface, cylinderMesh, sphereMesh
%     drawMesh

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2012-10-25, using Matlab 7.9.0.529 (R2009b)
% Copyright 2012-2023 INRA - Cepia Software Platform

%% Extract data for torus

% check input number
if nargin == 0
    torus = [0 0 0  30 10  0 0];
elseif ischar(torus)
    varargin = [{torus} varargin];
    torus = [0 0 0  30 10  0 0];
end

if isnumeric(torus) && size(torus, 2) ~= 7
    error('First argument must be a numeric row vector with 7 elements');
end

center = torus(1:3);
r1 = torus(4);
r2 = torus(5);

if size(torus, 2) >= 7
    normal = torus(6:7);
end


%% Extract data for discretisation

% number 
nTheta = 60;
nPhi = 60;
while length(varargin) > 1
    argName = varargin{1};
    switch lower(argName)
        case 'ntheta'
            nTheta = varargin{2};
        case 'nphi'
            nPhi = varargin{2};
        otherwise
            error('Unknown optional argument: %s', argName);
    end
    
    varargin(1:2) = [];
end


%% Discretize torus

% create base circle (duplicate last vertex to manage mesh periodicity)
circle = circleToPolygon([r1 0 r2], nTheta);
circle = circle([1:end 1], :);
% create rotation angle list (duplicate last one to manage mesh periodicity)
phiList = linspace(0, 2*pi, nPhi + 1);
[x, y, z] = revolutionSurface(circle, phiList);

% transform torus
trans = localToGlobal3d([center normal]);
[x, y, z] = transformPoint3d(x, y, z, trans);

% convert to FV mesh
[vertices, faces] = surfToMesh(x, y, z, 'xPeriodic', true, 'yPeriodic', true);

% format output
varargout = formatMeshOutput(nargout, vertices, faces);
