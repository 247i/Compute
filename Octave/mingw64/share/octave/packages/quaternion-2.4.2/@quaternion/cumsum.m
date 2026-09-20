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
## @deftypefn {Function File} {@var{q} =} cumsum (@var{q})
## @deftypefnx {Function File} {@var{q} =} cumsum (@var{q}, @var{dim})
## @deftypefnx {Function File} {@var{q} =} cumsum (@dots{}, @var{'native'})
## @deftypefnx {Function File} {@var{q} =} cumsum (@dots{}, @var{'double'})
## @deftypefnx {Function File} {@var{q} =} cumsum (@dots{}, @var{'extra'})
## Cumulative sum of elements along dimension @var{dim}.  If @var{dim} is omitted,
## it defaults to the first non-singleton dimension.
## See @code{help cumsum} for more information.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function q = cumsum (q, varargin)

  if (! isa (q, "quaternion"))
    print_usage ();
  endif

  q.w = builtin ("cumsum", q.w, varargin{:});
  q.x = builtin ("cumsum", q.x, varargin{:});
  q.y = builtin ("cumsum", q.y, varargin{:});
  q.z = builtin ("cumsum", q.z, varargin{:});

endfunction


%!test
%! ## Test cumsum along default dimension (columns)
%! w = [1, 2; 3, 4];
%! x = [5, 6; 7, 8];
%! y = [9, 10; 11, 12];
%! z = [13, 14; 15, 16];
%! q = quaternion (w, x, y, z);
%! result = cumsum (q);
%! expected_w = cumsum (w);
%! expected_x = cumsum (x);
%! expected_y = cumsum (y);
%! expected_z = cumsum (z);
%! expected = quaternion (expected_w, expected_x, expected_y, expected_z);
%! assert (result == expected);

%!test
%! ## Test cumsum along dimension 2 (rows)
%! w = [1, 2, 3; 4, 5, 6];
%! x = [7, 8, 9; 10, 11, 12];
%! y = [13, 14, 15; 16, 17, 18];
%! z = [19, 20, 21; 22, 23, 24];
%! q = quaternion (w, x, y, z);
%! result = cumsum (q, 2);
%! expected = quaternion (cumsum(w, 2), cumsum(x, 2), cumsum(y, 2), cumsum(z, 2));
%! assert (result == expected);
