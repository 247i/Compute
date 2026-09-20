## Copyright (C) 2010-2016   Lukas F. Reichlin
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{nvec} =} size (@var{q})
## @deftypefnx {Function File} {@var{n} =} size (@var{q}, @var{dim})
## @deftypefnx {Function File} {[@var{nx}, @var{ny}, @dots{}] =} size (@var{q})
## Return size of quaternion arrays.
##
## @strong{Inputs}
## @table @var
## @item q
## Quaternion object.
## @item dim
## If given a second argument, @command{size} will return the size of the
## corresponding dimension.
## @end table
##
## @strong{Outputs}
## @table @var
## @item nvec
## Row vector.  The first element is the number of rows and the second
## element the number of columns.  If @var{q} is an n-dimensional array
## of quaternions, the n-th element of @var{nvec} corresponds to the
## size of the n-th dimension of @var{q}.
## @item n
## Scalar value.  The size of the dimension @var{dim}.
## @item nx
## Number of rows.
## @item ny
## Number of columns.
## @item @dots{}
## Sizes of the 3rd to n-th dimensions.
## @end table
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.2

function varargout = size (a, b)

  switch (nargout)
    case {0, 1}
      switch (nargin)
        case 1                          # nvec = size (q)
          varargout{1} = builtin ("size", a.w);
        case 2                          # n = size (q, dim)
          varargout{1} = builtin ("size", a.w, b);
        otherwise
          print_usage ();
      endswitch

    otherwise
      if (nargin == 1)                  # [nx, ny, ...] = size (q)
        varargout = num2cell (builtin ("size", a.w));
      else
        print_usage ();
      endif
  endswitch

endfunction


%!test
%! ## Scalar quaternion
%! q = quaternion (2, 3, 4, 5);
%! assert (size (q), [1, 1]);
%! assert (size (q, 1), 1);
%! assert (size (q, 2), 1);
%! [r, c] = size (q);
%! assert (r, 1);
%! assert (c, 1);

%!test
%! ## Row vector quaternion
%! q = quaternion ([1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]);
%! assert (size (q), [1, 3]);
%! assert (size (q, 1), 1);
%! assert (size (q, 2), 3);
%! [r, c] = size (q);
%! assert (r, 1);
%! assert (c, 3);

%!test
%! ## Column vector quaternion
%! q = quaternion ([1; 2; 3], [4; 5; 6], [7; 8; 9], [10; 11; 12]);
%! assert (size (q), [3, 1]);
%! assert (size (q, 1), 3);
%! assert (size (q, 2), 1);
%! [r, c] = size (q);
%! assert (r, 3);
%! assert (c, 1);

%!test
%! ## Matrix quaternion
%! w = [1, 2, 3; 4, 5, 6];
%! x = [7, 8, 9; 10, 11, 12];
%! y = [13, 14, 15; 16, 17, 18];
%! z = [19, 20, 21; 22, 23, 24];
%! q = quaternion (w, x, y, z);
%! assert (size (q), [2, 3]);
%! assert (size (q, 1), 2);
%! assert (size (q, 2), 3);
%! [r, c] = size (q);
%! assert (r, 2);
%! assert (c, 3);

%!test
%! ## 3D array quaternion
%! w = ones (2, 3, 4);
%! x = 2 * ones (2, 3, 4);
%! y = 3 * ones (2, 3, 4);
%! z = 4 * ones (2, 3, 4);
%! q = quaternion (w, x, y, z);
%! assert (size (q), [2, 3, 4]);
%! assert (size (q, 1), 2);
%! assert (size (q, 2), 3);
%! assert (size (q, 3), 4);
%! [r, c, d] = size (q);
%! assert (r, 2);
%! assert (c, 3);
%! assert (d, 4);

