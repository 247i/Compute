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
% @deftypefn {Function File} {[@var{in}, @var{on}] =} inpolyeder (@var{x}, @var{y}, @var{z}, @var{xv}, @var{yv}, @var{zv}, @var{doPlot}, @var{doPlotHelpers})
% For a polyeder defined by vertex points @code{(@var{xv}, @var{yv}, @var{zv})},
% determine if the points @code{(@var{x}, @var{y}), @var{z})} are inside or
% outside the polyeder.
% The variables @var{x}, @var{y}, @var{z} must have the same dimension. The optional
% output @var{on} gives the points that are on the polyeder.
% @seealso{inpolygon}
% @end deftypefn

% Author: Andreas Emch, Eduardo Hahn Paredes
% Created: December 2012

function [in, on] = inpolyeder (x, y, z, xv, yv, zv, doPlot, doPlotHelpers)

    if (nargin < 6)
        print_usage ();
    endif

    if (!(isreal(x) && isreal(y) && isreal(z)
            && ismatrix(y) && ismatrix(y) && ismatrix(z)
            && size_equal(x, y, z)))
        error("inpolyeder: The first 3 vectors need to have the same size (test points)");
    elseif (! (isreal(xv) && isreal(yv) && isreal(zv)
            && isvector(xv) && isvector(yv) && isvector(zv)
            && size_equal(xv, yv, zv)))
        error("inpolyeder: The last 3 vectors need to have the same size (polyeder corners)");
    endif

    if (!isbool(doPlot))
        error("inpolyeder: doPlot has to be a boolean value");
    endif

    if (!isbool(doPlotHelpers))
        error("inpolyeder: doPlotHelpers has to be a boolean value");
    endif

    starttTime = cputime;

    X = [xv, yv, zv];
    K = convhulln(X);

    P = [x y z];

    on = zeros(size(x), "logical")';
    in = zeros(size(x), "logical")';

    if (doPlot == true)
        clf
        hold on
        t = trisurf(K, X(:,1), X(:,2), X(:,3));
        set(t,'facealpha',0.5)
        m=unique(K);
        plot3(X(m,1), X(m,2), X(m,3), 'ko', 'markerfacecolor', 'b');
    endif

    counter = 0;

    for p1 = P'
        counter++;

        left = 0;
        right = 0;

        do
            p2 = p1 + rand(3,1);
        until (p1 != p2)

        if (doPlotHelpers)
            point1 = p1 + (-20 .* (p2-p1));
            point2 = p1 + (20 .* (p2-p1));

            plot3([point1(1,1); point2(1,1)], [point1(2,1); point2(2,1)], [point1(3,1); point2(3,1)], 'k-');
        endif

        for poly = K'
            a = X(poly(1,1),:)';
            b = X(poly(2,1),:)';
            c = X(poly(3,1),:)';
            [pointIn pointDistance point] = isIntersectionInPolygon3D(p1, p2, a, b, c);
            if (pointIn)
                if (pointDistance > 0)
                    left += 1;
                elseif (pointDistance < 0)
                    right += 1;
                elseif (pointDistance == 0)
                    on(1,counter) = true;
                endif
            endif
            if (doPlotHelpers && !isnan(point))
                if (pointIn)
                    plot3(point(1,1), point(2,1), point(3,1), 'ko', 'markerfacecolor', 'y');
                else
                    plot3(point(1,1), point(2,1), point(3,1), 'k*', 'markerfacecolor', 'y');
                endif
            endif
        endfor
        if (mod(left,2) == 1 && mod(right,2) == 1)
            in(1,counter) = true;
        endif
    endfor

    if (doPlot == true)
        plot3(x(in'), y(in'), z(in'),'ko', 'markerfacecolor', 'g',
            x(~in'), y(~in'), z(~in'),'ko', 'markerfacecolor', 'r',
            x(on'), y(on'), z(on'),'ko', 'markerfacecolor', 'k')

        x_max = max(max(X(:,1)), max(P(:,1))) + 0.5;
        x_min = min(min(X(:,1)), min(P(:,1))) - 0.5;
        y_max = max(max(X(:,2)), max(P(:,2))) + 0.5;
        y_min = min(min(X(:,2)), min(P(:,2))) - 0.5;
        z_max = max(max(X(:,3)), max(P(:,3))) + 0.5;
        z_min = min(min(X(:,3)), min(P(:,3))) - 0.5;
        axis ([x_min x_max y_min y_max z_min z_max]);
        hold off
    endif
    printf('Total cpu time for checking %d points in a polyeder of %d polygons: %f seconds\n', size(x)(1,1), size(K)(1,1), cputime-starttTime);
endfunction
