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

function varargout = drawSphericalTriangle(varargin)
%DRAWSPHERICALTRIANGLE Draw a triangle on a sphere.
%
%   drawSphericalTriangle(SPHERE, PT1, PT2, PT3);
%   Draws the spherical triangle defined by the three input 3D points and
%   the reference sphere. 
%   Points are given as 3D points, and are projected onto the sphere. The
%   order of the points is not relevant. 
%
%   drawSphericalTriangle(SPHERE, PT1, PT2, PT3, OPTIONS);
%   Allows to specify plot options for spherical edges, in the form of
%   parameter name-value pairs.
%
%   Example
%     % Draw a sphere and a spherical triangle on it
%     s = [0 0 0 2];
%     pts = [1 0 0;0 -1 0;0 0 1];
%     drawSphere(s); hold on;
%     drawSphericalTriangle(s, pts(1,:), pts(2,:), pts(3,:), 'linewidth', 2);
%     view(3); axis equal;
%
%   See also 
%   drawSphere, fillSphericalTriangle, drawSphericalPolygon,
%   drawSphericalEdge
%

% ------
% Author: David Legland 
% E-mail: david.legland@inrae.fr
% Created: 2005-02-22
% Copyright 2005-2023 INRA - TPV URPOI - BIA IMASTE

% extract handle of axis to draw on
[hAx, varargin] = parseAxisHandle(varargin{:});

sphere = varargin{1};
p1 = varargin{2};
p2 = varargin{3};
p3 = varargin{4};
varargin(1:4) = [];

% extract data of the sphere
ori = sphere(:, 1:3);

% extract direction vectors for each point
v1  = normalizeVector3d(p1 - ori);
v2  = normalizeVector3d(p2 - ori);
v3  = normalizeVector3d(p3 - ori);

% keep hold state of current axis
holdState = ishold(hAx);
hold(hAx, 'on');

% draw each spherical edge
h1 = drawSphericalEdge(hAx, sphere, [v1 v2], varargin{:});
h2 = drawSphericalEdge(hAx, sphere, [v2 v3], varargin{:});
h3 = drawSphericalEdge(hAx, sphere, [v3 v1], varargin{:});

% return to previous hold state if needed
if ~holdState
    hold(hAx, 'off');
end

if nargout > 0
    varargout = {h1, h2, h3};
end
