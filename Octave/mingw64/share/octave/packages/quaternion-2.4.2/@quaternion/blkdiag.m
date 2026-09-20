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
## @deftypefn {Function File} {@var{q} =} blkdiag (@var{q1}, @var{q2}, @dots{})
## Block-diagonal concatenation of quaternions.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2011
## Version: 0.1

function q = blkdiag (varargin)

  ## Convert all inputs to quaternions
  tmp_cell = cellfun (@quaternion, varargin, "UniformOutput", false);

  ## Extract components from each quaternion in the cell array
  w_cell = cellfun (@(q) q.w, tmp_cell, "UniformOutput", false);
  x_cell = cellfun (@(q) q.x, tmp_cell, "UniformOutput", false);
  y_cell = cellfun (@(q) q.y, tmp_cell, "UniformOutput", false);
  z_cell = cellfun (@(q) q.z, tmp_cell, "UniformOutput", false);

  ## Explicitly call builtin to avoid recursion
  w = builtin ("blkdiag", w_cell{:});
  x = builtin ("blkdiag", x_cell{:});
  y = builtin ("blkdiag", y_cell{:});
  z = builtin ("blkdiag", z_cell{:});

  q = quaternion (w, x, y, z);

endfunction


%!shared C, D
%! Aw = [2, 6; 10, 14];
%! Ax = [3, 7; 11, 15];
%! Ay = [4, 8; 12, 16];
%! Az = [5, 9; 13, 17];
%! A = quaternion (Aw, Ax, Ay, Az);
%!
%! Bw = [2, 6, 10; 14, 18, 22];
%! Bx = [3, 7, 11; 15, 19, 23];
%! By = [4, 8, 12; 16, 20, 24];
%! Bz = [5, 9, 13; 17, 21, 25];
%! B = quaternion (Bw, Bx, By, Bz);
%!
%! C = blkdiag (A, B);
%!
%! Dw = blkdiag (Aw, Bw);
%! Dx = blkdiag (Ax, Bx);
%! Dy = blkdiag (Ay, By);
%! Dz = blkdiag (Az, Bz);
%! D = quaternion (Dw, Dx, Dy, Dz);
%!assert (C == D);
