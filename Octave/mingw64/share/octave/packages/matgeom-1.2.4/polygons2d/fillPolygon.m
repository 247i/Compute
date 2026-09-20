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

function varargout = fillPolygon(varargin)
%FILLPOLYGON Fill a polygon specified by a list of points.
%
%   fillPolygon(POLY);
%   Fills the interior of the polygon specified by POLY. The boundary of
%   the polygon is not drawn, see 'drawPolygon' to do it.
%   POLY is a single [N*2] array.
%   If POLY contains NaN-couples, each portion between the [NaN;NaN] will
%   be filled separately.
%
%   fillPolygon(PX, PY);
%   Specifies coordinates of the polygon in separate arrays.
%
%   H = fillPolygon(...);
%   Also returns a handle to the created patch
%
%   Example
%     oRectangle = [0 0;10 0;10 10;0 10];
%     iRectangle = flipud(0.5*oRectangle+1);
%     pol = {oRectangle, iRectangle};
%     figure('color','w')
%     fillPolygon(pol,'g')
%     drawPolygon(pol,'r')
%
%
%   See also 
%     polygons2d, drawCurve, drawPolygon

% ------
% Author: David Legland, oqilipo
% E-mail: david.legland@inrae.fr
% Created: 2005-04-07
% Copyright 2005-2023 INRA - TPV URPOI - BIA IMASTE

% Check input
if isempty(varargin)
    error('Not enough input arguments.');
end

% Check if the polygon is given in two separate arrays.
if numel(varargin) > 1
    if isnumeric(varargin{2})
        varargin{2} = [varargin{1}, varargin{2}];
        varargin(1)=[];
    end
end

% Convert into a polyShape
polyShape = parsePolygon(varargin{1}, 'polyshape');
varargin(1)=[];

% Set default color format if no color is given.
if isempty(varargin)
    varargin = {'FaceColor', 'b'};
end

if ~mod(numel(varargin), 2) == 0
    % Assume only the color was given.
    varargin = ['FaceColor', varargin];
end

% Fill the polygon with desired style.
h = plot(polyShape, varargin{:}, 'LineStyle', 'none');

% Output
if nargout > 0
    varargout{1} = h;
end
