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

function varargout = drawSphericalEdge(varargin)
%DRAWSPHERICALEDGE Draw an edge on the surface of a sphere.
%
%   drawSphericalEdge(SPHERE, EDGE)
%   EDGE is given as a couple of 3D coordinates corresponding to edge
%   extremities. The shortest spherical edge joining the two extremities is
%   drawn on the current axes.
%
%   drawSphericalEdge(AX, ...)
%   Specifies the handle of the axis to use for drawing.
%
%
%   Example
%     figure; hold on; axis equal; drawSphere([0 0 0 1]); view(3);
%     p1 = [0 -1 0];  p2 = [0 0 1];
%     drawSphericalEdge([0 0 0 1], [p1 p2], 'LineWidth', 2)
%
%   See also 
%     drawSphericalPolygon, drawSphere, drawCircleArc3d
%

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2012-02-09, using Matlab 7.9.0.529 (R2009b)
% Copyright 2012-2023 INRA - Cepia Software Platform

% extract handle of axis to draw on
[hAx, varargin] = parseAxisHandle(varargin{:});

sphere = varargin{1};
edge = varargin{2};
varargin(1:2) = [];

% extract data of the sphere
origin = sphere(:, 1:3);

% allocate array of handles
nEdges = size(edge, 1);
he = gobjects(1, nEdges);

% save hold state
holdState = ishold(hAx);
hold(hAx, 'on');

% iterate over edges
for iEdge = 1:nEdges
    % extremities of current edge
    point1  = edge(iEdge, 1:3);
    point2  = edge(iEdge, 4:6);
    
    % compute plane containing current edge
    plane   = createPlane(origin, point1, point2);
    
    % intersection of the plane with unit sphere
    circle  = intersectPlaneSphere(plane, sphere);

    % find the position (in degrees) of the 2 vertices on the circle
    angle1  = circle3dPosition(point1, circle);
    angle2  = circle3dPosition(point2, circle);

    % ensure angles are in right direction
    if mod(angle2 - angle1 + 360, 360) > 180
        tmp     = angle1;
        angle1  = angle2;
        angle2  = tmp;
    end

    % compute angle extent of the circle arc
    angleExtent = mod(angle2 - angle1 + 360, 360);

    % create circle arc
    arc = [circle angle1 angleExtent];

    % draw the arc
    he(iEdge) = drawCircleArc3d(hAx, arc, varargin{:});
end

% restore hold state
if ~holdState
    hold(hAx, 'off');
end

if nargout > 0
    varargout = {he};
end
