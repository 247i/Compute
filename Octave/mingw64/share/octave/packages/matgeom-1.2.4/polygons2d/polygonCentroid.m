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

function [centroid, area, Sx, Sy] = polygonCentroid(varargin)
%POLYGONCENTROID Computes the centroid (center of mass) of a polygon.
%
%   CENTROID = polygonCentroid(POLY)
%   CENTROID = polygonCentroid(PTX, PTY)
%   Computes center of mass of a polygon defined by POLY. POLY is a N-by-2
%   array of double containing coordinates of vertices.
%
%   [CENTROID, AREA] = polygonCentroid(POLY)
%   Also returns the (signed) area of the polygon. 
%
%   Example
%     % Draws the centroid of a paper hen
%     x = [0 10 20  0 -10 -20 -10 -10  0];
%     y = [0  0 10 10  20  10  10  0 -10];
%     poly = [x' y'];
%     centro = polygonCentroid(poly);
%     drawPolygon(poly);
%     hold on; axis equal;
%     drawPoint(centro, 'bo');
% 
%   References
%     Algorithm adapted from P. Bourke's web page.
%
%   See also 
%     polygons2d, polygonArea, polygonSecondAreaMoments, drawPolygon
%     polylineCentroid, centroid

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2004-05-05
% Copyright 2004-2023

% parse input arguments
if nargin == 1
    poly = varargin{1};
elseif nargin == 2
    poly(:,1) = varargin{1};
    poly(:,2) = varargin{2};
end
poly = parsePolygon(poly, 'repetition');

px = poly(:,1);
py = poly(:,2);

% vertex indices
N = length(px);
iNext = [2:N 1];

% compute cross products
common = px .* py(iNext) - px(iNext) .* py;
Sx = 1/6*sum((py + py(iNext)) .* common);
Sy = 1/6*sum((px + px(iNext)) .* common);

% area and centroid
area = sum(common) / 2;
centroid = [Sy Sx] / area;
