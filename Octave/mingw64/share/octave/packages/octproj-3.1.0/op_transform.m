## Copyright (C) 2009-2020, José Luis García Pallero, <jgpallero@gmail.com>
##
## This file is part of OctPROJ.
##
## OctPROJ is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function file}{[@var{X2},@var{Y2}] =}op_transform(@var{X1},@var{Y1},@var{par1},@var{par2})
## @deftypefnx {Function file}{[@var{X2},@var{Y2},@var{Z2}] =}op_transform(@var{X1},@var{Y1},@var{Z1},@var{par1},@var{par2})
## @deftypefnx {Function file}{[@var{X2},@var{Y2},@var{Z2},@var{t2}] =}op_transform(@var{X1},@var{Y1},@var{Z1},@var{t1},@var{par1},@var{par2})
##
## @cindex Performs transformation between two coordinate systems.
##
## This function transforms X/Y/Z/t, lon/lat/h/t points between two coordinate
## systems 1 and 2 using the PROJ function proj_trans_generic().
##
## INPUT ARGUMENTS:
##
## @itemize @bullet
## @item
## @var{X1} is a column vector containing by default the first coordinates (X or
## geodetic longitude) in the source system.
## @item
## @var{Y1} is a column vector containing by default the second coordinates (Y
## or geodetic latitude) in the source system.
## @item
## @var{Z1} is a column vector containing by default the third coordinates (Z or
## height) in the source system.
## @item
## @var{t1} is a column vector containing by default the fourth coordinates
## (time) in the source system.
## @item
## @var{par1} is a text string containing the parameters for the source system,
## in PROJ '+' format, as EPSG code or as a WKT definition.
## @item
## @var{par2} is a text string containing the parameters for the destination
## system, in PROJ '+' format, as EPSG code or as WKT definition.
## @end itemize
##
## OUTPUT ARGUMENTS:
##
## @itemize @bullet
## @item
## @var{X2} is a column vector containing by default the first coordinates (X or
## geodetic longitude) in the destination system
## @item
## @var{Y2} is a column vector containing by default the second coordinates (Y
## or geodetic latitude) in the destination system.
## @item
## @var{Z2} is a column vector containing by default the third coordinates (Z or
## height) in the destination system.
## @item
## @var{t2} is a column vector containingby default the fourth coordinates
## (time) in the destination system.
## @end itemize
##
## @var{X1}, @var{Y1}, @var{Z1} or @var{t1} can be scalars, vectors or 2D
## matrices. @var{Z1} and/or @var{t1} can be zero-length matrices. @var{X2},
## @var{Y2}, @var{Z2}, and @var{t2} will be according to the input dimensions.
##
## Angular units are by default degrees and linear meters, although other can be
## specified in @var{par1} and/or @var{par2}, so @var{X1}, @var{Y1}, @var{Z1},
## and @var{t1} must be congruent with them. The same applies to the coordinate
## order at input and output.
##
## If a transformation error occurs the resultant coordinates for the affected
## points have all Inf value and a warning message is emitted (one for each
## erroneous point).
## @seealso{_op_fwd, _op_inv}
## @end deftypefn




function [X2,Y2,Z2,t2] = op_transform(X1,Y1,Z1,t1,par1,par2)

try
    functionName = 'op_transform';
    minArgNumber = 4;
    maxArgNumber = 6;

%*******************************************************************************
%NUMBER OF INPUT ARGUMENTS CHECKING
%*******************************************************************************

    %number of input arguments checking
    if (nargin<minArgNumber)||(nargin>maxArgNumber)
        error(['Incorrect number of input arguments (%d)\n\t         ',...
               'Correct number of input arguments = %d or %d'],...
              nargin,minArgNumber,maxArgNumber);
    end

%*******************************************************************************
%INPUT ARGUMENTS CHECKING
%*******************************************************************************

    %checking input arguments
    if nargin==minArgNumber
        par2 = t1;
        par1 = Z1;
        Z1 = [];
        t1 = [];
    elseif nargin==(minArgNumber+1)
        par2 = par1;
        par1 = t1;
        t1 = [];
    end
    [X1,Y1,Z1,t1,rowWork,colWork] = checkInputArguments(X1,Y1,Z1,t1,par1,par2);
catch
    %error message
    error('\n\tIn function %s:\n\t -%s ',functionName,lasterr);
end

%*******************************************************************************
%COMPUTATION
%*******************************************************************************

try
    %calling oct function
    [X2,Y2,Z2,t2] = _op_transform(X1,Y1,Z1,t1,par1,par2);
    %convert output vectors in matrices of adequate size
    X2 = reshape(X2,rowWork,colWork);
    Y2 = reshape(Y2,rowWork,colWork);
    if nargin==maxArgNumber
        Z2 = reshape(Z2,rowWork,colWork);
    end
catch
    %error message
    error('\n\tIn function %s:\n\tIn function %s ',functionName,lasterr);
end




%*******************************************************************************
%AUXILIARY FUNCTION
%*******************************************************************************




function [a,b,c,d,rowWork,colWork] = checkInputArguments(a,b,c,d,par1,par2)

%a must be matrix type
if (~isnumeric(a))||isempty(a)
    error('The first input argument is not numeric');
end
%b must be matrix type
if (~isnumeric(b))||isempty(b)
    error('The second input argument is not numeric');
end
%c must be matrix type
if ~isnumeric(b)
    error('The third input argument is not numeric');
end
%d must be matrix type
if ~isnumeric(b)
    error('The fourth input argument is not numeric');
end
%params must be a text string
if ~ischar(par1)
    error('The fifth input argument is not a text string');
end
%params must be a text string
if ~ischar(par2)
    error('The sixth input argument is not a text string');
end
%equalize dimensions
[a,b,c,d] = op_aux_equalize_dimensions(0,a,b,c,d);
%dimensions
[rowWork,colWork] = size(a);
%convert a, b and c in column vectors
a = reshape(a,rowWork*colWork,1);
b = reshape(b,rowWork*colWork,1);
if ~isempty(c)
    c = reshape(c,rowWork*colWork,1);
end
if ~isempty(d)
    d = reshape(d,rowWork*colWork,1);
end




%*****FUNCTION TESTS*****




%!test
%!  [x,y,h,t]=op_transform(-6,43,1000,10,...
%!                         '+proj=latlong +ellps=GRS80',...
%!                         '+proj=utm +zone=30 +ellps=GRS80');
%!  [lon,lat,H,T]=op_transform(x,y,h,t,'+proj=utm +zone=30 +ellps=GRS80',...
%!                           '+proj=latlong +ellps=GRS80');
%!  assert(x,255466.98,1e-2)
%!  assert(y,4765182.93,1e-2)
%!  assert(h,1000.0,1e-15)
%!  assert(lon,-6,1e-8)
%!  assert(lat,43,1e-8)
%!  assert(H,1000.0,1e-15)
%!  assert(T,10.0,1e-15)
%!test
%!  [x,y,h]=op_transform(-6,43,1000,...
%!                       '+proj=latlong +ellps=GRS80',...
%!                       '+proj=utm +zone=30 +ellps=GRS80');
%!  [lon,lat,H]=op_transform(x,y,h,'+proj=utm +zone=30 +ellps=GRS80',...
%!                           '+proj=latlong +ellps=GRS80');
%!  assert(x,255466.98,1e-2)
%!  assert(y,4765182.93,1e-2)
%!  assert(h,1000.0,1e-15)
%!  assert(lon,-6,1e-8)
%!  assert(lat,43,1e-8)
%!  assert(H,1000.0,1e-15)
%!test
%!  [x,y]=op_transform(-6,43,'+proj=latlong +ellps=GRS80',...
%!                     '+proj=utm +zone=30 +ellps=GRS80');
%!  [lon,lat]=op_transform(x,y,'+proj=utm +zone=30 +ellps=GRS80',...
%!                         '+proj=latlong +ellps=GRS80');
%!  assert(x,255466.98,1e-2)
%!  assert(y,4765182.93,1e-2)
%!  assert(lon,-6,1e-8)
%!  assert(lat,43,1e-8)
%!error(op_transform)
%!error(op_transform(1,2,3,4,5,6))
%!error(op_transform('string',2,3,4,5))
%!error(op_transform(1,'string',3,4,5))
%!error(op_transform(1,2,'string',4,5))
%!error(op_transform(1,2,3,'string',5))
%!error(op_transform(1,2,3,4,'string'))
%!error(op_transform(1,[2 3 4],[3 3;4 4],'+proj=latlong +ellps=GRS80',...
%!                   '+proj=utm +zone=30 +ellps=GRS80'))




%*****END OF TESTS*****
