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
## @deftypefn  {Function File} {@var{qret} =} repmat (@var{q}, @var{m})
## @deftypefnx {Function File} {@var{qret} =} repmat (@var{q}, @var{m}, @var{n})
## @deftypefnx {Function File} {@var{qret} =} repmat (@var{q}, [@var{m} @var{n}])
## @deftypefnx {Function File} {@var{qret} =} repmat (@var{q}, [@var{m} @var{n} @var{p} @dots{}])
## Form a block quaternion matrix @var{qret} of size @var{m} by @var{n},
## with a copy of quaternion matrix @var{q} as each element.
## If @var{n} is not specified, form an @var{m} by @var{m} block matrix.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: July 2014
## Version: 0.1

function q = repmat (a, varargin)

  if (! isa (a, "quaternion"))
    print_usage ();
  endif
  
  w = builtin ("repmat", a.w, varargin{:});
  x = builtin ("repmat", a.x, varargin{:});
  y = builtin ("repmat", a.y, varargin{:});
  z = builtin ("repmat", a.z, varargin{:});

  q = quaternion (w, x, y, z);

endfunction


%!test
%! ## Test repmat with single scalar argument
%! q = quaternion (1, 2, 3, 4);
%! result = repmat (q, 2);
%! expected = quaternion (repmat(1, 2), repmat(2, 2), repmat(3, 2), repmat(4, 2));
%! assert (result == expected);

%!test
%! ## Test repmat with two arguments
%! q = quaternion (1, 2, 3, 4);
%! result = repmat (q, 2, 3);
%! expected = quaternion (repmat(1, 2, 3), repmat(2, 2, 3), repmat(3, 2, 3), repmat(4, 2, 3));
%! assert (result == expected);

%!test
%! ## Test repmat with vector
%! w = [1, 2];
%! x = [3, 4];
%! y = [5, 6];
%! z = [7, 8];
%! q = quaternion (w, x, y, z);
%! result = repmat (q, 2, 1);
%! expected = quaternion (repmat(w, 2, 1), repmat(x, 2, 1), repmat(y, 2, 1), repmat(z, 2, 1));
%! assert (result == expected);
