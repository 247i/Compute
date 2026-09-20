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

function a = isPolygon3d(pol, varargin)
%ISPOLYGON3D Check if input is a 3d polygon.
%
%   B = isPolygon3d(POL) where POL should be a 3d polygon.
%
%   Example:
%     % 2d polygon
%     pol = [6	7	6	6	5	4	3	2	2	1	2	2	6	6 ...
%            NaN  3	3	4	5	5	3	3	NaN	4	5	5	4;
%            4	4	5	6	6	7	6	6	4	2	2	2	1	4 ...
%    	     NaN  4	5	5	4	4	3	4	NaN	3	2	3	3]';
%     % 3d random transformation
%     phi=-360+720*rand;
%     theta=-360+720*rand;
%     psi=-360+720*rand;
%     % 3d polygon
%     pol3d = transformPolygon3d(pol, eulerAnglesToRotation3d(phi, theta, psi));
%     disp('Valid 3d polygon')
%     disp(['Is 3d polygon?: ' num2str(isPolygon3d(pol3d))])
%     disp('2d polygon, not 3d')
%     disp(['Is 3d polygon?: ' num2str(isPolygon3d(pol))])
%     pol3d2 = pol3d; pol3d2(12) = pol3d2(12)+1e-12;
%     disp('Not all points in same plane')
%     disp(['Is 3d polygon?: ' num2str(isPolygon3d(pol3d2))])
%     disp('Not real, contains complex elements')
%     pol3d3 = pol3d; pol3d3(12) = pol3d3(12)+4i;
%     disp(['Is 3d polygon?: ' num2str(isPolygon3d(pol3d3))])
%
%   See also 
%   polygons3d

% ------
% Author: oqilipo
% E-mail: N/A
% Created: 2023-10-15, using MATLAB 9.13.0.2080170 (R2022b) Update 1
% Copyright 2023

narginchk(1,2)

parser = inputParser;
addOptional(parser,'tolerance',1e-12, ...
    @(x) validateattributes(x,{'numeric'},{'scalar','>',0,'<',1}))
parse(parser, varargin{:});
TOL = parser.Results.tolerance;

polRep = parsePolygon(pol,'repetition');

% Dimensions of the 3d polygon should be [Nx3].
if size(polRep,2)~=3
    a=false;
    return
end

% All points must be located in the same plane.
polPlane = fitPlane(polRep);
if any(abs(distancePointPlane(polRep, polPlane)) > TOL)
    a=false;
    return
end

b = ~any(isinf(polRep(:)));
c = isreal(polRep);

a = b & c;

end
