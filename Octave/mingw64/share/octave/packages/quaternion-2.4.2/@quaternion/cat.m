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
## @deftypefn {Function File} {@var{q} =} cat (@var{dim}, @var{q1}, @var{q2}, @dots{})
## Concatenation of quaternions along dimension @var{dim}.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.1

function q = cat (dim, varargin)

  ## Convert all inputs to quaternions
  tmp_cell = cellfun (@quaternion, varargin, "UniformOutput", false);

  ## Extract components from each quaternion in the cell array
  w_cell = cellfun (@(q) q.w, tmp_cell, "UniformOutput", false);
  x_cell = cellfun (@(q) q.x, tmp_cell, "UniformOutput", false);
  y_cell = cellfun (@(q) q.y, tmp_cell, "UniformOutput", false);
  z_cell = cellfun (@(q) q.z, tmp_cell, "UniformOutput", false);

  ## Explicitly call builtin to avoid recursion
  w = builtin ("cat", dim, w_cell{:});
  x = builtin ("cat", dim, x_cell{:});
  y = builtin ("cat", dim, y_cell{:});
  z = builtin ("cat", dim, z_cell{:});

  q = quaternion (w, x, y, z);

endfunction


%!shared A, B, C1, C2, D1, D2
%! Aw = [2, 6; 10, 14];
%! Ax = [3, 7; 11, 15];
%! Ay = [4, 8; 12, 16];
%! Az = [5, 9; 13, 17];
%! A = quaternion (Aw, Ax, Ay, Az);
%!
%! Bw = [18, 22; 26, 30];
%! Bx = [19, 23; 27, 31];
%! By = [20, 24; 28, 32];
%! Bz = [21, 25; 29, 33];
%! B = quaternion (Bw, Bx, By, Bz);
%!
%! C1 = cat (1, A, B);
%! C2 = cat (2, A, B);
%!
%! D1w = cat (1, Aw, Bw);
%! D1x = cat (1, Ax, Bx);
%! D1y = cat (1, Ay, By);
%! D1z = cat (1, Az, Bz);
%! D1 = quaternion (D1w, D1x, D1y, D1z);
%!
%! D2w = cat (2, Aw, Bw);
%! D2x = cat (2, Ax, Bx);
%! D2y = cat (2, Ay, By);
%! D2z = cat (2, Az, Bz);
%! D2 = quaternion (D2w, D2x, D2y, D2z);
%!assert (C1 == D1);
%!assert (C2 == D2);

