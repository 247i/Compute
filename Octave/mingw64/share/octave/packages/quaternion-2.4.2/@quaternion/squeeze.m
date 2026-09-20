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
## @deftypefn {Function File} {@var{qret} =} squeeze (@var{q})
## Remove singleton dimensions from quaternion @var{q} and return the result.
## Note that for compatibility with @acronym{MATLAB}, all objects have a minimum
## of two dimensions and row vectors are left unchanged.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function ret = squeeze (q)

  if (nargin != 1)
    print_usage ();
  endif

  w = builtin ("squeeze", q.w);
  x = builtin ("squeeze", q.x);
  y = builtin ("squeeze", q.y);
  z = builtin ("squeeze", q.z);

  ret = quaternion (w, x, y, z);

endfunction


%!test
%! ## Test squeeze on 3D array with singleton dimension
%! w = ones (1, 3, 4);
%! x = 2 * ones (1, 3, 4);
%! y = 3 * ones (1, 3, 4);
%! z = 4 * ones (1, 3, 4);
%! q = quaternion (w, x, y, z);
%! result = squeeze (q);
%! expected = quaternion (squeeze(w), squeeze(x), squeeze(y), squeeze(z));
%! assert (size(result), size(expected));
%! assert (result == expected);

%!test
%! ## Test squeeze on 4D array
%! w = ones (2, 1, 3, 1);
%! x = 2 * ones (2, 1, 3, 1);
%! y = 3 * ones (2, 1, 3, 1);
%! z = 4 * ones (2, 1, 3, 1);
%! q = quaternion (w, x, y, z);
%! result = squeeze (q);
%! expected = quaternion (squeeze(w), squeeze(x), squeeze(y), squeeze(z));
%! assert (size(result), [2, 3]);
%! assert (result == expected);
