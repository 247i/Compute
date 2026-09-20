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

function curv = polylineCurvature(poly, M)
%POLYLINECURVATURE Estimate curvature on polyline vertices using polynomial fit.
%
%   CURV = polygonCurvature(POLY, M)
%   Estimate the curvature for each vertex of a polygon, using polynomial
%   fit from the M vertices located around current vertex. M is usually an
%   odd value, resulting in a symmetric neighborhood.
%
%   Polynomial fitting is of degree 2.
%   
%
%   Example
%     % compute curvature on a curve obtained from skeleton image
%     img = imread('circles.png');
%     img = imfill(img, 'holes');
%     imgf = imfilter(double(img), fspecial('gaussian', 7, 2));
%     figure(1), imshow(imgf);
%     % compute skeleton, and simplify to get a smooth polyline
%     skel = imSkeleton(imgf > 0.5);
%     path = imMaxGeodesicPath(skel);
%     poly = smoothPolyline(path, 15);
%     hold on; drawPolyline(poly, 'm');
%     % compute curvature
%     curv = polylineCurvature(poly, 11);
%     figure; plot(curv);
%     minima = bwlabel(imextendedmin(curv, .05));
%     centroids = imCentroid(minima);
%     inds = round(centroids(:,2));
%     figure(1); hold on; drawPoint(poly2(inds, :), 'g*')
%
%   See also 
%     polygons2d, polygonCurvature, padPolyline

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2022-04-01, using Matlab 9.3.0.713579 (R2017b)
% Copyright 2022-2023 INRA - Cepia Software Platform

% number of vertices of polyline
n = size(poly, 1);

% allocate memory for result
curv = zeros(n, 1);

% number of vertices before and after current vertex
m1 = floor((M - 1) / 2);
m2 = ceil((M - 1) / 2);

% parametrisation basis
% As we recenter the points, the constant factor is omitted
ti = (-m1:m2)';
X = [ti ti.^2];
    
% Iteration on vertex indices
for i = m1+1:n-m2
    % coordinate of current vertex, for recentring neighbor vertices
    x0 = poly(i,1);
    y0 = poly(i,2);
    
    % indices of neighbors
    inds = i-m1:i+m2;
    inds = mod(inds-1, n) + 1;
    
    % Least square estimation using mrdivide
    xc = X \ (poly(inds,1) - x0);
    yc = X \ (poly(inds,2) - y0);
    
    % compute curvature
    curv(i) = 2 * (xc(1)*yc(2) - xc(2)*yc(1) ) / power(xc(1)^2 + yc(1)^2, 3/2);
end

% duplicate curvature at extremities
curv(1:m1) = curv(m1+1);
curv(n-m2+1:n) = curv(n-m2);
