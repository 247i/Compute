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
## @deftypefn {Function File} {@var{q} =} sum (@var{q})
## @deftypefnx {Function File} {@var{q} =} sum (@var{q}, @var{dim})
## @deftypefnx {Function File} {@var{q} =} sum (@dots{}, @var{'native'})
## @deftypefnx {Function File} {@var{q} =} sum (@dots{}, @var{'double'})
## @deftypefnx {Function File} {@var{q} =} sum (@dots{}, @var{'extra'})
## Sum of elements along dimension @var{dim}.  If @var{dim} is omitted,
## it defaults to the first non-singleton dimension.
## See @code{help sum} for more information.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function q = sum (q, varargin)

  if (! isa (q, "quaternion"))
    print_usage ();
  endif

  q.w = builtin ("sum", q.w, varargin{:});
  q.x = builtin ("sum", q.x, varargin{:});
  q.y = builtin ("sum", q.y, varargin{:});
  q.z = builtin ("sum", q.z, varargin{:});

endfunction


%!test
%! ## Test sum along default dimension (columns)
%! w = [1, 2; 3, 4];
%! x = [5, 6; 7, 8];
%! y = [9, 10; 11, 12];
%! z = [13, 14; 15, 16];
%! q = quaternion (w, x, y, z);
%! result = sum (q);
%! expected = quaternion (sum(w), sum(x), sum(y), sum(z));
%! assert (result == expected);

%!test
%! ## Test sum along dimension 2 (rows)
%! w = [1, 2, 3; 4, 5, 6];
%! x = [7, 8, 9; 10, 11, 12];
%! y = [13, 14, 15; 16, 17, 18];
%! z = [19, 20, 21; 22, 23, 24];
%! q = quaternion (w, x, y, z);
%! result = sum (q, 2);
%! expected = quaternion (sum(w, 2), sum(x, 2), sum(y, 2), sum(z, 2));
%! assert (result == expected);

%!test
%! ## Test sum of vector
%! q = quaternion ([1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16]);
%! result = sum (q);
%! expected = quaternion (sum([1,2,3,4]), sum([5,6,7,8]), sum([9,10,11,12]), sum([13,14,15,16]));
%! assert (result == expected);
