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
## @deftypefn {Function File} {@var{sq} =} sparse (@var{fq})
## Return a sparse quaternion representation @var{sq} from
## full quaternion @var{fq}.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function q = sparse (q)

  if (nargin != 1)
    print_usage ();
  endif
  
  q.w = builtin ("sparse", q.w);
  q.x = builtin ("sparse", q.x);
  q.y = builtin ("sparse", q.y);
  q.z = builtin ("sparse", q.z);

endfunction


%!test
%! ## Test sparse on full quaternion
%! w = [1, 0, 0; 0, 2, 0; 0, 0, 3];
%! x = [4, 0, 0; 0, 5, 0; 0, 0, 6];
%! y = [7, 0, 0; 0, 8, 0; 0, 0, 9];
%! z = [10, 0, 0; 0, 11, 0; 0, 0, 12];
%! q = quaternion (w, x, y, z);
%! result = sparse (q);
%! expected = quaternion (sparse(w), sparse(x), sparse(y), sparse(z));
%! assert (result == expected);
%! assert (! issparse (q.w));
%! assert (issparse (result.w));

%!test
%! ## Test sparse then full round-trip
%! w = [1, 2; 3, 4];
%! x = [5, 6; 7, 8];
%! y = [9, 10; 11, 12];
%! z = [13, 14; 15, 16];
%! q = quaternion (w, x, y, z);
%! result = full (sparse (q));
%! assert (result == q);
