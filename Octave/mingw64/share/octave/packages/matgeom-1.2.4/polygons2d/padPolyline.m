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

function poly2 = padPolyline(poly, M, varargin)
%PADPOLYLINE Add vertices at each extremity of the polyline.
%
%   POLY2 = padPolyline(POLY, M)
%   where M is a scalar, adds M vertices at the beginning and at the end of
%   the polyline. The number of vertices of the result polyline POLY2 is
%   equal to NV + 2*M. 
%
%   POLY2 = padPolyline(POLY, [M1 M2])
%   Adds M1 vertices at the beginning of the polyline, and M2 at the end.
%   The number of vertices of the result polyline POLY2 is NV + M1 + M2. 
%
%   POLY2 = padPolyline(..., 'method', METHOD)
%   Specifies the padding method to use. METHOD can be one of {'symetric'}
%   (the default), or 'repeat'.
%
%   Example
%     poly = circleArcToPolyline([50 50 30 30 80], 40);
%     poly2 = padPolyline(poly, 10, 'method', 'symetric');
%     figure; hold on; axis equal;
%     drawPolyline(poly, 'color', 'b', 'linewidth', 2);
%     drawPolyline(poly2, 'color', 'm')
%     legend({'Initial', 'Padded'}, 'Location', 'SouthWest');
%
%   See also 
%     polygons2d, smoothPolyline, polylineCurvature
%

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2022-03-31, using Matlab 9.12.0.1884302 (R2022a)
% Copyright 2022-2023 INRAE - BIA Research Unit - BIBS Platform (Nantes)

%% Input argument management

% default strategy
method = 'symetric';

% padding before and after
if isscalar(M)
    m1 = M;
    m2 = M;
else
    m1 = M(1);
    m2 = M(2);
end

% other parameter name-value pairs
while length(varargin) > 1
    name = varargin{1};
    if strcmpi(name, 'method')
        method = varargin{2};
    else
        error('Unknown argument name: %s', name);
    end
    varargin(1:2) = [];
end


%% Main Processing

% vertex number
nv = size(poly,1);

% switch processing depending on method
if strcmp(method, 'repeat')
    poly2 = [...
        poly(ones(m1,1), :) ; ...
        poly ;
        poly(nv * ones(m2,1), :) ; ...
        ];

elseif strcmp(method, 'symetric')
    v1 = poly(1,:);
    vn = poly(end,:);

     poly2 = [...
        2 * v1 - poly(m1+1:-1:2, :) ; ...
        poly ;
        2 * vn - poly(nv-1:-1:nv-m2, :) ; ...
        ];

else
    error('Unknown method name: %s', method);
end
