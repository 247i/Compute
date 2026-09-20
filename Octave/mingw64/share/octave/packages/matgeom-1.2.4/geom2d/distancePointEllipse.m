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

function [dist, proj] = distancePointEllipse(point, elli)
%DISTANCEPOINTELLIPSE Distance from a point to an ellipse.
%
%   DIST = distancePointEllipse(POINT, ELLI)
%   Computes the Euclidean distance between the point POINT and the ellipse
%   ELLI.
%   POINT may also be a N-by-2 array of point coordinates. In that case the
%   result is a N-by-1 array of distances.
%
%   [DIST, PROJ] = distancePointEllipse(POINT, ELLI)
%   Also return the coordinates of the projection of the point onto the
%   ellipse. PROJ has same dimensions as the array POINT.
%
%   Example
%     % create an ellipse
%     elli = [50 50 40 30 20];
%     % generate points along a regular grid
%     [x, y] = meshgrid(1:100, 1:100);
%     pts = [x(:) y(:)];
%     % compute distance map
%     distMap = reshape(distancePointEllipse(pts, elli), size(x));
%     figure; imshow(distMap, []); colormap parula;
%
%
%   References:
%     https://blog.chatfield.io/simple-method-for-distance-to-ellipse/
%
%   See also 
%     ellipses2d, projPointOnEllipse, distancePoints
%

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2022-07-17, using Matlab 9.12.0.1884302 (R2022a)
% Copyright 2022-2023 INRAE - BIA Research Unit - BIBS Platform (Nantes)

proj = projPointOnEllipse(point, elli);

dist = distancePoints(point, proj, 'diag');
