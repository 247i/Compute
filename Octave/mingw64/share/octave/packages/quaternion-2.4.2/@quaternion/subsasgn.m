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
## Subscripted assignment for quaternions.
## Used by Octave for "q.key = value".
##
## @strong{Subscripts}
## @table @var
## @item q.w
## Assign real-valued array @var{val} to scalar part @var{w} of quaternion @var{q}.
##
## @item q.x, q.y, q.z
## Assign real-valued array @var{val} to component @var{x}, @var{y} or @var{z}
## of the vector part of quaternion @var{q}.
##
## @item q.s
## Assign scalar part of quaternion @var{val} to scalar part of quaternion @var{q}.
## The vector part of @var{q} is left untouched.
##
## @item q.v
## Assign vector part of quaternion @var{val} to vector part of quaternion @var{q}.
## The scalar part of @var{q} is left untouched.
##
## @item q(@dots{})
## Assign @var{val} to certain elements of quaternion array @var{q}, e.g. @code{q(3, 2:end) = val}.
## @end table

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.3

function q = subsasgn (q, idx, val)

  switch (idx(1).type)
    case "()"                                                    # q(...) = val
      ## Always use component-wise assignment
      val = quaternion (val);
      w = builtin ("subsasgn", q.w, idx, val.w);
      x = builtin ("subsasgn", q.x, idx, val.x);
      y = builtin ("subsasgn", q.y, idx, val.y);
      z = builtin ("subsasgn", q.z, idx, val.z);
      q = quaternion (w, x, y, z);

    case "."                                                     # q.w = val
      if (isa (val, "quaternion"))
        ref_size = size (subsref (q.w, idx(2:end)));
        val_size = size (val.w);
        if (! isequal (ref_size, val_size))
          error ("quaternion: subsasgn: invalid argument size (%s), require dimensions (%s)", ...
                 regexprep (num2str (val_size, "%d "), " ", "x"), ...
                 regexprep (num2str (ref_size, "%d "), " ", "x"));
        endif
        switch (tolower (idx(1).subs))
          case "s"
            q.w = builtin ("subsasgn", q.w, idx(2:end), val.w);
          case "v"
            q.x = builtin ("subsasgn", q.x, idx(2:end), val.x);
            q.y = builtin ("subsasgn", q.y, idx(2:end), val.y);
            q.z = builtin ("subsasgn", q.z, idx(2:end), val.z);
          otherwise
            error ("quaternion: subsasgn: invalid subscript name '%s'", idx(1).subs);
        endswitch
      elseif (isnumeric (val) && isreal (val))
        ref_size = size (subsref (q.w, idx(2:end)));
        val_size = size (val);
        if (! isequal (ref_size, val_size))
          error ("quaternion: subsasgn: invalid argument size (%s), require dimensions (%s)", ...
                 regexprep (num2str (val_size, "%d "), " ", "x"), ...
                 regexprep (num2str (ref_size, "%d "), " ", "x"));
        endif
        switch (tolower (idx(1).subs))
          case {"w", "e"}
            q.w = builtin ("subsasgn", q.w, idx(2:end), val);
          case {"x", "i"}
            q.x = builtin ("subsasgn", q.x, idx(2:end), val);
          case {"y", "j"}
            q.y = builtin ("subsasgn", q.y, idx(2:end), val);
          case {"z", "k"}
            q.z = builtin ("subsasgn", q.z, idx(2:end), val);
          otherwise
            error ("quaternion: subsasgn: invalid subscript name '%s'", idx(1).subs);
        endswitch
      else
        error ("quaternion: subsasgn: invalid argument type, require real-valued array");
      endif

    otherwise
      error ("quaternion: subsasgn: invalid subscript type '%s'", idx(1).type);
  endswitch

endfunction


%!test
%! ## Test indexed assignment with scalar
%! q = quaternion ([1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]);
%! q(2) = quaternion (0, 1, 2, 3);
%! assert (q.w, [1, 0, 3]);
%! assert (q.x, [4, 1, 6]);
%! assert (q.y, [7, 2, 9]);
%! assert (q.z, [10, 3, 12]);

%!test
%! ## Test indexed assignment with range
%! q = quaternion (ones(1, 5), 2*ones(1, 5), 3*ones(1, 5), 4*ones(1, 5));
%! q(2:4) = quaternion ([10, 20, 30], [11, 21, 31], [12, 22, 32], [13, 23, 33]);
%! assert (q.w, [1, 10, 20, 30, 1]);
%! assert (q.x, [2, 11, 21, 31, 2]);

%!test
%! ## Test component assignment - q.w
%! q = quaternion (1, 2, 3, 4);
%! q.w = 10;
%! assert (q.w, 10);
%! assert (q.x, 2);
%! assert (q.y, 3);
%! assert (q.z, 4);

%!test
%! ## Test component assignment - q.x, q.y, q.z
%! q = quaternion (1, 2, 3, 4);
%! q.x = 20;
%! q.y = 30;
%! q.z = 40;
%! assert (q.w, 1);
%! assert (q.x, 20);
%! assert (q.y, 30);
%! assert (q.z, 40);

%!test
%! ## Test scalar part assignment - q.s
%! q = quaternion (1, 2, 3, 4);
%! q.s = quaternion (10);
%! assert (q.w, 10);
%! assert (q.x, 2);
%! assert (q.y, 3);
%! assert (q.z, 4);

%!test
%! ## Test vector part assignment - q.v
%! q = quaternion (1, 2, 3, 4);
%! q.v = quaternion (0, 20, 30, 40);
%! assert (q.w, 1);
%! assert (q.x, 20);
%! assert (q.y, 30);
%! assert (q.z, 40);

%!test
%! ## Test matrix indexed assignment
%! w = ones(3, 3);
%! x = 2*ones(3, 3);
%! y = 3*ones(3, 3);
%! z = 4*ones(3, 3);
%! q = quaternion (w, x, y, z);
%! q(2, 2) = quaternion (10, 20, 30, 40);
%! assert (q.w(2, 2), 10);
%! assert (q.x(2, 2), 20);
%! assert (q.y(2, 2), 30);
%! assert (q.z(2, 2), 40);

%!test
%! ## Test assignment with mixed quaternion and zeros
%! q = quaternion (1, 2, 3, 4);
%! c = [q; zeros(2, 1)];
%! c(2) = quaternion (5, 6, 7, 8);
%! assert (c.w, [1; 5; 0]);
%! assert (c.x, [2; 6; 0]);

