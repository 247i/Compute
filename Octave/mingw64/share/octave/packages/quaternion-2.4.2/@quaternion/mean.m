## Copyright (C) 2013   Willem Atsma
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
## @deftypefn {Function File} {@var{q} =} mean (@var{q})
## @deftypefnx {Function File} {@var{q} =} mean (@var{q}, @var{dim})
## @deftypefnx {Function File} {@var{q} =} mean (@var{q}, @var{opt})
## @deftypefnx {Function File} {@var{q} =} mean (@var{q}, @var{dim}, @var{opt})
## Compute the mean of the elements of the quaternion array @var{q}.
##
## @example
## mean (q) = mean (q.w) + mean (q.x)*i + mean (q.y)*j + mean (q.z)*k
## @end example
##
## See @code{help mean} for more information and a description of the
## parameters @var{dim} and @var{opt}.
## @end deftypefn

## Author: Willem Atsma <willem.atsma@tanglebridge.com>
## Created: June 2013
## Version: 0.1

function q = mean (q, varargin)

  if (! isa (q, "quaternion"))
    print_usage ();
  endif

  w = builtin ("mean", q.w, varargin{:});
  x = builtin ("mean", q.x, varargin{:});
  y = builtin ("mean", q.y, varargin{:});
  z = builtin ("mean", q.z, varargin{:});

  q = quaternion (w, x, y, z);
   
endfunction


%!test
%! ## Test mean along default dimension (columns)
%! w = [1, 2; 3, 4];
%! x = [5, 6; 7, 8];
%! y = [9, 10; 11, 12];
%! z = [13, 14; 15, 16];
%! q = quaternion (w, x, y, z);
%! result = mean (q);
%! expected = quaternion (mean(w), mean(x), mean(y), mean(z));
%! assert (result == expected);

%!test
%! ## Test mean along dimension 2 (rows)
%! w = [1, 2, 3; 4, 5, 6];
%! x = [7, 8, 9; 10, 11, 12];
%! y = [13, 14, 15; 16, 17, 18];
%! z = [19, 20, 21; 22, 23, 24];
%! q = quaternion (w, x, y, z);
%! result = mean (q, 2);
%! expected = quaternion (mean(w, 2), mean(x, 2), mean(y, 2), mean(z, 2));
%! assert (result == expected);

%!test
%! ## Test mean of vector
%! q = quaternion ([1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16]);
%! result = mean (q);
%! expected = quaternion (mean([1,2,3,4]), mean([5,6,7,8]), mean([9,10,11,12]), mean([13,14,15,16]));
%! assert (result == expected);
