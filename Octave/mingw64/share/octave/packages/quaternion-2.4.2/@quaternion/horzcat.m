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
## Horizontal concatenation of quaternions.  Used by Octave for "[q1, q2]".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1

function q = horzcat (varargin)

  ## Convert all inputs to quaternions
  tmp_cell = cellfun (@quaternion, varargin, "UniformOutput", false);

  ## Extract components from each quaternion in the cell array
  w_cell = cellfun (@(q) q.w, tmp_cell, "UniformOutput", false);
  x_cell = cellfun (@(q) q.x, tmp_cell, "UniformOutput", false);
  y_cell = cellfun (@(q) q.y, tmp_cell, "UniformOutput", false);
  z_cell = cellfun (@(q) q.z, tmp_cell, "UniformOutput", false);

  ## Explicitly call builtin to avoid recursion
  w = builtin ("horzcat", w_cell{:});
  x = builtin ("horzcat", x_cell{:});
  y = builtin ("horzcat", y_cell{:});
  z = builtin ("horzcat", z_cell{:});

  q = quaternion (w, x, y, z);

endfunction


%!test
%! a = quaternion (1, 2, 3, 4);
%! b = quaternion (5, 6, 7, 8);
%! result = [a, b];
%! assert (size (result), [1, 2]);
%! assert (result(1) == a);
%! assert (result(2) == b);
