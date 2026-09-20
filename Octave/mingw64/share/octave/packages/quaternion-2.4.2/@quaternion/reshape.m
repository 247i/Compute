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
## @deftypefn {Function File} {@var{q} =} reshape (@var{q}, @var{m}, @var{n}, @dots{})
## @deftypefnx {Function File} {@var{q} =} reshape (@var{q}, [@var{m} @var{n} @dots{}])
## @deftypefnx {Function File} {@var{q} =} reshape (@var{q}, @dots{}, [], @dots{})
## @deftypefnx {Function File} {@var{q} =} reshape (@var{q}, @var{size})
## Return a quaternion array with the specified dimensions (@var{m}, @var{n}, @dots{})
## whose elements are taken from the quaternion array @var{q}.  The elements of the
## quaternion are accessed in column-major order (like Fortran arrays are stored).
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function q = reshape (q, varargin)

  if (! isa (q, "quaternion"))
    print_usage ();
  endif

  q.w = builtin ("reshape", q.w, varargin{:});
  q.x = builtin ("reshape", q.x, varargin{:});
  q.y = builtin ("reshape", q.y, varargin{:});
  q.z = builtin ("reshape", q.z, varargin{:});

endfunction


%!test
%! ## Test reshape from 2x3 to 3x2
%! w = [1, 2, 3; 4, 5, 6];
%! x = [7, 8, 9; 10, 11, 12];
%! y = [13, 14, 15; 16, 17, 18];
%! z = [19, 20, 21; 22, 23, 24];
%! q = quaternion (w, x, y, z);
%! result = reshape (q, 3, 2);
%! expected = quaternion (reshape(w, 3, 2), reshape(x, 3, 2), reshape(y, 3, 2), reshape(z, 3, 2));
%! assert (result == expected);

%!test
%! ## Test reshape to row vector
%! w = [1, 2; 3, 4];
%! x = [5, 6; 7, 8];
%! y = [9, 10; 11, 12];
%! z = [13, 14; 15, 16];
%! q = quaternion (w, x, y, z);
%! result = reshape (q, 1, 4);
%! expected = quaternion (reshape(w, 1, 4), reshape(x, 1, 4), reshape(y, 1, 4), reshape(z, 1, 4));
%! assert (result == expected);
