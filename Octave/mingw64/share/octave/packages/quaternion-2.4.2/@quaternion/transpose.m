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
## Transpose of a quaternion.  Used by Octave for "q.'".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1

function a = transpose (a)

  if (nargin != 1)
    print_usage ();
  endif

  a.w = builtin ("transpose", a.w);
  a.x = builtin ("transpose", a.x);
  a.y = builtin ("transpose", a.y);
  a.z = builtin ("transpose", a.z);

endfunction


%!test
%! ## Test transpose of row vector
%! q = quaternion ([1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]);
%! result = transpose (q);
%! expected_w = [1; 2; 3];
%! expected_x = [4; 5; 6];
%! expected_y = [7; 8; 9];
%! expected_z = [10; 11; 12];
%! expected = quaternion (expected_w, expected_x, expected_y, expected_z);
%! assert (result == expected);

%!test
%! ## Test transpose of matrix
%! w = [1, 2, 3; 4, 5, 6];
%! x = [7, 8, 9; 10, 11, 12];
%! y = [13, 14, 15; 16, 17, 18];
%! z = [19, 20, 21; 22, 23, 24];
%! q = quaternion (w, x, y, z);
%! result = q.';
%! expected = quaternion (w.', x.', y.', z.');
%! assert (result == expected);
