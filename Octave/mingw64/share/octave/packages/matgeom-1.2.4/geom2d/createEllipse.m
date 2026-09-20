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

function elli = createEllipse(type, varargin)
%CREATEELLIPSE Create an ellipse, from various input types.
%
%   ELLI = createEllipse('CartesianCoefficients', COEFFS)
%   ELLI = createEllipse(COEFFS)
%   Where COEFFS are the cartesian coefficients of the ellipse:
%     COEFFS = [A B C D E F] 
%   such that the points on the ellipse follow:
%     A*X^2 + B*X*Y + C*Y^2 + D*X + E*Y + F = 0
%   
%
%   Example
%     elli = [30 20 40 20 30];
%     coeffs = ellipseCartesianCoefficients(elli)
%     elli2 = createEllipse(coeffs)
%     elli2 =
%        30.0000   20.0000   40.0000   20.0000   30.0000
%
%
%   References
%   https://en.wikipedia.org/wiki/Ellipse#Standard_parametric_representation
%
%   See also 
%     ellipses2d, equivalentEllipse, fitEllipse,
%     ellipseCartesianCoefficients
%

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2022-09-05, using Matlab 9.12.0.1884302 (R2022a)
% Copyright 2022-2023 INRAE - BIA Research Unit - BIBS Platform (Nantes)

if nargin == 1 && isnumeric(type)
    varargin = {type};
    type = 'CartesianCoefficients';
end

if strcmpi(type, 'CartesianCoefficients')
    % retrieve coefficients
    coeffs = varargin{1};
    if ~isnumeric(coeffs) || any(size(coeffs) ~= [1 6])
        error('Conversion from cartesian coefficients expects a 1-by-6 numeric array');
    end

    % call coefficients with their usual names
    A = coeffs(1); B = coeffs(2); C = coeffs(3);
    D = coeffs(4); E = coeffs(5); F = coeffs(6);

    % retrieve center
    delta = B * B - 4 * A * C;
    xc = (2 * C * D - B * E) / delta;
    yc = (2 * A * E - B * D) / delta;

    % find orientation
    theta = 0.5 * atan(B / (A - C));

    % retrieve length of semi-axes
    common = 2 * (A * E^2 + C * D^2 - B * D * E + delta * F);
    root = sqrt((A - C)^2 + B^2);
    a1 = -sqrt(common * ((A + C) + root)) / delta;
    a2 = -sqrt(common * ((A + C) - root)) / delta;

    elli = [xc yc a1 a2 rad2deg(theta)];

else
    error('Unknown representation type: ' + type);
end

