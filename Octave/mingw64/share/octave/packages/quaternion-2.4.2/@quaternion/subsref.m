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
## Subscripted reference for quaternions.  Used by Octave for "q.w".
##
## @strong{Subscripts}
## @table @var
## @item q.w
## Return scalar part @var{w} of quaternion @var{q} as a built-in type.
##
## @item q.x, q.y, q.z
## Return component @var{x}, @var{y} or @var{z} of the vector part of 
## quaternion @var{q} as a built-in type.
##
## @item q.s
## Return scalar part of quaternion @var{q}.  The vector part of @var{q}
## is set to zero.
##
## @item q.v
## Return vector part of quaternion @var{q}.  The scalar part of @var{q}
## is set to zero.
##
## @item q(@dots{})
## Extract certain elements of quaternion array @var{q}, e.g. @code{q(3, 2:end)}.
## @end table

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.6

function ret = subsref (q, s)

  if (numel (s) == 0)
    ret = q;
    return;
  endif

  switch (s(1).type)
    case "."                                # q.w
      switch (tolower (s(1).subs))
        case {"w", "e"}                     # scalar part, returned as built-in type
          ret = builtin ("subsref", q.w, s(2:end));
        case {"x", "i"}
          ret = builtin ("subsref", q.x, s(2:end));
        case {"y", "j"}
          ret = builtin ("subsref", q.y, s(2:end));
        case {"z", "k"}
          ret = builtin ("subsref", q.z, s(2:end));
        case "s"                            # scalar part, vector part set to zero
          sz = size (q.w);
          q.x = q.y = q.z = zeros (sz, class (q.w));
          ret = subsref (q, s(2:end));
        case "v"                            # vector part, scalar part set to zero
          sz = size (q.w);
          q.w = zeros (sz, class (q.w));
          ret = subsref (q, s(2:end));
        otherwise
          error ("quaternion: invalid subscript name '%s'", s(1).subs);
      endswitch

    case "()"                               # q(...)
      w = builtin ("subsref", q.w, s(1));
      x = builtin ("subsref", q.x, s(1));
      y = builtin ("subsref", q.y, s(1));
      z = builtin ("subsref", q.z, s(1));
      tmp = quaternion (w, x, y, z);
      ret = subsref (tmp, s(2:end));
      
    otherwise
      error ("quaternion: invalid subscript type '%s'", s(1).type);
  endswitch

endfunction


%!test
%! ## Test indexed reference with scalar
%! q = quaternion ([1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]);
%! q2 = q(2);
%! assert (q2.w, 2);
%! assert (q2.x, 5);
%! assert (q2.y, 8);
%! assert (q2.z, 11);

%!test
%! ## Test indexed reference with range
%! q = quaternion ([1, 2, 3, 4, 5], [6, 7, 8, 9, 10], [11, 12, 13, 14, 15], [16, 17, 18, 19, 20]);
%! q2 = q(2:4);
%! assert (q2.w, [2, 3, 4]);
%! assert (q2.x, [7, 8, 9]);
%! assert (q2.y, [12, 13, 14]);
%! assert (q2.z, [17, 18, 19]);

%!test
%! ## Test component extraction - q.w, q.x, q.y, q.z
%! q = quaternion (1, 2, 3, 4);
%! assert (q.w, 1);
%! assert (q.x, 2);
%! assert (q.y, 3);
%! assert (q.z, 4);

%!test
%! ## Test scalar part extraction - q.s
%! q = quaternion (1, 2, 3, 4);
%! qs = q.s;
%! assert (qs.w, 1);
%! assert (qs.x, 0);
%! assert (qs.y, 0);
%! assert (qs.z, 0);

%!test
%! ## Test vector part extraction - q.v
%! q = quaternion (1, 2, 3, 4);
%! qv = q.v;
%! assert (qv.w, 0);
%! assert (qv.x, 2);
%! assert (qv.y, 3);
%! assert (qv.z, 4);

%!test
%! ## Test matrix indexed reference
%! w = reshape(1:9, 3, 3);
%! x = reshape(10:18, 3, 3);
%! y = reshape(19:27, 3, 3);
%! z = reshape(28:36, 3, 3);
%! q = quaternion (w, x, y, z);
%! q2 = q(2, 2);
%! assert (q2.w, 5);
%! assert (q2.x, 14);
%! assert (q2.y, 23);
%! assert (q2.z, 32);

%!test
%! ## Test matrix range reference
%! w = reshape(1:9, 3, 3);
%! x = reshape(10:18, 3, 3);
%! y = reshape(19:27, 3, 3);
%! z = reshape(28:36, 3, 3);
%! q = quaternion (w, x, y, z);
%! q2 = q(1:2, 2:3);
%! assert (q2.w, [4, 7; 5, 8]);
%! assert (q2.x, [13, 16; 14, 17]);

%!test
%! ## Test alternative component names (e, i, j, k)
%! q = quaternion (1, 2, 3, 4);
%! assert (q.e, 1);  # e for scalar
%! assert (q.i, 2);  # i for x
%! assert (q.j, 3);  # j for y
%! assert (q.k, 4);  # k for z

