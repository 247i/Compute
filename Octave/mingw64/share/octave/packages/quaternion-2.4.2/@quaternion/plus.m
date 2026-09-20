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
## Addition of two quaternions.  Used by Octave for "q1 + q2".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.2

function q = plus (a, b)

  if (nargin != 2)
    error ("quaternion: plus: this is a binary operator");
  endif

  a = quaternion (a);
  b = quaternion (b);

  w = a.w + b.w;
  x = a.x + b.x;
  y = a.y + b.y;
  z = a.z + b.z;

  q = quaternion (w, x, y, z);

endfunction


%!shared A, B, C, D
%! Aw = [2, 6; 10, 14];
%! Ax = [3, 7; 11, 15];
%! Ay = [4, 8; 12, 16];
%! Az = [5, 9; 13, 17];
%! A = quaternion (Aw, Ax, Ay, Az);
%!
%! Bw = [1, 2; 3, 4];
%! Bx = [5, 6; 7, 8];
%! By = [9, 10; 11, 12];
%! Bz = [13, 14; 15, 16];
%! B = quaternion (Bw, Bx, By, Bz);
%!
%! C = A + B;
%!
%! Dw = Aw + Bw;
%! Dx = Ax + Bx;
%! Dy = Ay + By;
%! Dz = Az + Bz;
%! D = quaternion (Dw, Dx, Dy, Dz);
%!assert (C == D);

