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

function coeffs = ellipseCartesianCoefficients(elli)
%ELLIPSECARTESIANCOEFFICIENTS Cartesian coefficients of an ellipse.
%
%   COEFFS = ellipseCartesianCoefficients(ELLI)
%   Computes the cartesian coefficients of the ellipse ELLI, given by:
%     COEFFS = [A B C D E F] 
%   such that the points on the ellipse follow:
%     A*X^2 + B*X*Y + C*Y^2 + D*X + E*Y + F = 0
%
%   Example
%     elli = [30 20 40 20 30];
%     coeffs = ellipseCartesianCoefficients(elli)
%     elli2 = createEllipse(coeffs)
%     elli2 =
%        30.0000   20.0000   40.0000   20.0000   30.0000
%
%   See also 
%     ellipses2d, createEllipse, equivalentEllipse
%

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2022-09-05, using Matlab 9.12.0.1884302 (R2022a)
% Copyright 2022-2023 INRAE - BIA Research Unit - BIBS Platform (Nantes)

% retrieve ellipse center and squared radiusses
xc = elli(1);
yc = elli(2);
a2 = elli(3)^2;
b2 = elli(4)^2;

% pre-compute trigonometric functions (angle is in degrees)
cot = cos(elli(5) * pi / 180);
sit = sin(elli(5) * pi / 180);

% identification of each parameter
A = a2 * sit * sit + b2 * cot * cot;
B = 2 * (b2 - a2) * sit * cot;
C = a2 * cot * cot + b2 * sit * sit;
D = - 2 * A * xc - B * yc;
E = - B * xc - 2 * C * yc;
F = A * xc * xc + B * xc * yc + C * yc * yc - a2 * b2;

% concatenate into a single row vector
coeffs = [A B C D E F];
