## Copyright (C) 2014 Andreas Emch and Eduardo Hahn Paredes
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

% -*- texinfo -*-
% @deftypefn {Function File} {[@var{in}, @var{distance}] =} isIntersectionInPolygon3D (@var{p1}, @var{p2}, @var{a}, @var{b}, @var{c})
% For a line, defined by two vector-points @code{(@var{p1}, @var{p2})},
% calculate the intersection-point with the plane, defined by three vector-points @code{(@var{a}, @var{b}), @var{c})},
% and determine if this intersection-point is inside or on the polygon defined by three vector-points @code{(@var{a}, @var{b}), @var{c})}
% The variables @var{p1}, @var{p2}, @var{a}, @var{b}, @var{c} are all points in the 3D-dimension.
% @seealso{inpolygon}
% @end deftypefn

% Author: Andreas Emch, Eduardo Hahn Paredes
% Created: January 2013

function [in distance point] = isIntersectionInPolygon3D (p1, p2, a, b, c)
    u = b-a;
    v = c-a;

    E = [a u v];
    n = cross(u',v');
    
    if (u == v)
        in = false;
        distance = NaN;
        point = NaN;
        return;
    endif
    
    x = n(1,1);
    y = n(1,2);
    z = n(1,3);
    d = -(a(1,1) * x + a(2,1) * y + a(3,1) * z);
    
    plane = 0;
    
    if (E(1,2) == 0 && E(1,3) == 0)
        plane = 1;
    elseif (E(2,2) == 0 && E(2,3) == 0)
        plane = 2;
    elseif (E(3,2) == 0 && E(3,3) == 0)
        plane = 3;
    else
        plane = 0;
    endif
    
    P = [p1 p2-p1];
    t = -(x * P(1,1) + y * P(2,1) + z * P(3,1) + d) / (x * P(1,2) + y * P(2,2) + z * P(3,2));

    dP = p1 + (t .* (p2-p1));
    xPoly = [a(1,1) b(1,1) c(1,1) a(1,1)];
    yPoly = [a(2,1) b(2,1) c(2,1) a(2,1)];
    zPoly = [a(3,1) b(3,1) c(3,1) a(3,1)];    

    [in1 on1] = inpolygon(dP(1,1), dP(2,1), xPoly, yPoly);
    [in2 on2] = inpolygon(dP(2,1), dP(3,1), yPoly, zPoly);
    [in3 on3] = inpolygon(dP(3,1), dP(1,1), zPoly, xPoly);
    
    if ((plane == 0 && (in1 == 1 || on1 == 1) && (in2 == 1 || on2 == 1) && (in3 == 1 || on3 == 1))
        ||(plane == 1 && (in2 == 1 || on2 == 1))
        ||(plane == 2 && (in3 == 1 || on3 == 1))
        ||(plane == 3 && (in1 == 1 || on1 == 1)))
        in = true;
        distance = t;
        point = dP;
    else
        in = false;
        distance = NaN;
        point = dP;
    endif
endfunction
