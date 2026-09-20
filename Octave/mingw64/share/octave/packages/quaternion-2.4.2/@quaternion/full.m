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
## @deftypefn {Function File} {@var{fq} =} full (@var{sq})
## Return a full storage quaternion representation @var{fq}
## from sparse or diagonal quaternion @var{sq}.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function q = full (q)

  if (nargin != 1)
    print_usage ();
  endif
  
  q.w = builtin ("full", q.w);
  q.x = builtin ("full", q.x);
  q.y = builtin ("full", q.y);
  q.z = builtin ("full", q.z);

endfunction


%!test
%! ## Test full on sparse quaternion
%! w = sparse ([1, 2; 3, 4]);
%! x = sparse ([5, 6; 7, 8]);
%! y = sparse ([9, 10; 11, 12]);
%! z = sparse ([13, 14; 15, 16]);
%! q = quaternion (w, x, y, z);
%! result = full (q);
%! expected = quaternion (full(w), full(x), full(y), full(z));
%! assert (result == expected);
%! assert (issparse (q.w));
%! assert (! issparse (result.w));

%!test
%! ## Test full on diagonal quaternion
%! w = diag ([1, 2, 3]);
%! x = diag ([4, 5, 6]);
%! y = diag ([7, 8, 9]);
%! z = diag ([10, 11, 12]);
%! q = quaternion (w, x, y, z);
%! result = full (q);
%! expected = quaternion (full(w), full(x), full(y), full(z));
%! assert (result == expected);
