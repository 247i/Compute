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
## @deftypefn {Function File} {@var{q} =} tril (@var{q})
## @deftypefnx {Function File} {@var{q} =} tril (@var{q}, @var{k})
## @deftypefnx {Function File} {@var{q} =} tril (@var{q}, @var{k}, @var{'pack'})
## Return a new quaternion matrix formed by extracting the lower
## triangular part of the quaternion @var{q}, and setting all
## other elements to zero.  The second argument @var{k} is optional,
## and specifies how many diagonals above or below the main diagonal
## should also be included.  Default value for @var{k} is zero.
## If the option "pack" is given as third argument, the extracted
## elements are not inserted into a matrix, but rather stacked
## column-wise one above other.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function q = tril (q, varargin)

  if (! isa (q, "quaternion"))
    print_usage ();
  endif

  q.w = builtin ("tril", q.w, varargin{:});
  q.x = builtin ("tril", q.x, varargin{:});
  q.y = builtin ("tril", q.y, varargin{:});
  q.z = builtin ("tril", q.z, varargin{:});

endfunction


%!test
%! ## Test tril with no offset (main diagonal)
%! w = [1, 2, 3; 4, 5, 6; 7, 8, 9];
%! x = [10, 11, 12; 13, 14, 15; 16, 17, 18];
%! y = [19, 20, 21; 22, 23, 24; 25, 26, 27];
%! z = [28, 29, 30; 31, 32, 33; 34, 35, 36];
%! q = quaternion (w, x, y, z);
%! result = tril (q);
%! expected = quaternion (tril(w), tril(x), tril(y), tril(z));
%! assert (result == expected);

%!test
%! ## Test tril with positive offset
%! w = [1, 2, 3; 4, 5, 6; 7, 8, 9];
%! x = [10, 11, 12; 13, 14, 15; 16, 17, 18];
%! y = [19, 20, 21; 22, 23, 24; 25, 26, 27];
%! z = [28, 29, 30; 31, 32, 33; 34, 35, 36];
%! q = quaternion (w, x, y, z);
%! result = tril (q, 1);
%! expected = quaternion (tril(w, 1), tril(x, 1), tril(y, 1), tril(z, 1));
%! assert (result == expected);
