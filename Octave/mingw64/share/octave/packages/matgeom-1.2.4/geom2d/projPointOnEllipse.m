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

function proj = projPointOnEllipse(point, elli)
%PROJPOINTONELLIPSE Project a point orthogonally onto an ellipse.
%
%   PROJ = projPointOnEllipse(PT, ELLI)
%   Computes the (orthogonal) projection of point PT onto the ellipse given
%   by ELLI.
%
%
%   Example
%     % create an ellipse and a point
%     elli = [50 50 40 20 30];
%     pt = [60 10];
%     % display reference figures
%     figure; hold on; drawEllipse(elli, 'b');
%     axis equal; axis([0 100 0 100]);
%     drawPoint(pt, 'bo');
%     % compute projected point
%     proj = projPointOnEllipse(pt, elli);
%     drawEdge([pt proj], 'b');
%     drawPoint(proj, 'k*');
%
%   See also 
%     ellipses2d, distancePointEllipse, projPointOnLine, ellipsePoint
%     drawEllipse
%

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2022-07-17, using Matlab 9.12.0.1884302 (R2022a)
% Copyright 2022-2023 INRAE - BIA Research Unit - BIBS Platform (Nantes)

% defaults
nMaxIters = 4;

% compute transform to centered axis-aligned ellipse
center = elli(1:2);
theta = deg2rad(elli(5));
transfo = createRotation(-theta) * createTranslation(-center);
pointT = transformPoint(point, transfo);

% retrieve ellipse semi axis lengths
a = elli(3);
b = elli(4);

% keep absolute values
px = abs(pointT(:,1));
py = abs(pointT(:,2));

% initial guess of solution
tx = 0.707;
ty = 0.707;

% iterate
for i = 1:nMaxIters
    x = a * tx;
    y = b * ty;

    ex = (a*a - b*b) * power(tx, 3) / a;
    ey = (b*b - a*a) * power(ty, 3) / b;

    rx = x - ex;
    ry = y - ey;

    qx = px - ex;
    qy = py - ey;

    r = hypot(ry, rx);
    q = hypot(qy, qx);

    tx = min(1, max(0, (qx .* r ./ q + ex) / a));
    ty = min(1, max(0, (qy .* r ./ q + ey) / b));
    t = hypot(ty, tx);
    tx = tx ./ t;
    ty = ty ./ t;

end

% computes coordinates of projection
projX = a * tx;
projY = b * ty;

% fix sign
projX(pointT(:,1) < 0) = -projX(pointT(:,1) < 0);
projY(pointT(:,2) < 0) = -projY(pointT(:,2) < 0);

% project pack to basis of original ellipse
proj = transformPoint([projX projY], inv(transfo));
