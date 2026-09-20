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

function d = distancePointCircle3d(points, circle)
%DISTANCEPOINTCIRCLE3D Distance between 3D points and 3D circle.
%
%   D = distancePointCircle3d(POINTS, CIRCLE)
%   Returns the euclidean distance D between POINTS and CIRCLE
%
%   Example
%     figure('color','w'); hold on; axis equal tight; view(3)
%     circle = [10 20 30 50 90 45 60];
%     drawCircle3d(circle)
%     % Get some points on the circle
%     pts = circle3dPoint(circle, 10:10:280);
%     drawPoint3d(pts,'.r')
%     % Get the normal of the circle
%     circleNormal = normalizeVector3d(transformVector3d([0 0 1], ...
%         eulerAnglesToRotation3d(circle(6), circle(5), circle(7), 'ZYZ')));
%     drawArrow3d(circle(1:3), circleNormal*25)
%     % Move points along the circle normal by 10 units
%     pts2 = pts + 10 * circleNormal;
%     drawPoint3d(pts2,'.g')
%     drawEdge3d([pts, pts2])
%     uniquetol(distancePointCircle3d(pts2, circle))
%     % Decrease the circle radius by 5 units
%     uniquetol(distancePointCircle3d(pts, [circle(1:3) circle(4)-5 circle(5:7)]))
%   
%   See also 
%   circles3d, projPointOnCircle3d

% ------
% Author: oqilipo
% E-mail: N/A
% Created: 2023-07-25, using Matlab 9.13.0.2080170 (R2022b) Update 1
% Copyright 2023

% Project the points on the circle
pointsProj2Circle = projPointOnCircle3d(points, circle);

% Calculate the distance between the points and the projected points
d = distancePoints3d(points, pointsProj2Circle);
