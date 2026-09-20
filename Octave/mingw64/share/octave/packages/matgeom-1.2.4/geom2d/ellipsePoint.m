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

function point = ellipsePoint(elli, pos)
%ELLIPSEPOINT Coordinates of a point on an ellipse from parametric equation.
%
%   POINT = ellipsePoint(ELLI, POS)
%   Computes the coordinates of the point with parameter value POS on the
%   ellipse. POS is contained within [0, 2*PI].
%
%   Example
%     elli = [50 50  40 20  30];
%     pts = ellipsePoint(elli, linspace(0, pi, 12));
%     figure; drawEllipse(elli, 'b'); hold on;
%     axis equal; axis([0 100 0 100]);
%     drawPoint(pts, 'bo');
%
%   See also 
%     ellipses2d, drawEllipse, projPointOnEllipse, ellipseToPolygon
%

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2022-09-09, using Matlab 9.12.0.1884302 (R2022a)
% Copyright 2022-2023 INRAE - BIA Research Unit - BIBS Platform (Nantes)

% make sure pos is column vector
pos = pos(:);

% pre-compute rotation angles (given in degrees)
theta = elli(:,5);
cot = cosd(theta);
sit = sind(theta);

% compute position of points used to draw current ellipse
a = elli(:,3);
b = elli(:,4);
xt = elli(:,1) + a * cos(pos) * cot - b * sin(pos) * sit;
yt = elli(:,2) + a * cos(pos) * sit + b * sin(pos) * cot;

% concatenate
point = [xt yt];
