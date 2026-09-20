## Copyright (C) 2000 Kai Habel <kai.habel@gmx.de>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{s} = std2 (@var{I})
## Returns the standard deviation for a 2D real type matrix.
##
## Uses @code{std (double (I(:)))} for integer type input and @code{std (I(:))}
## for floating type input (single/double)
##
## @seealso{mean2,std}
## @end deftypefn

function s = std2 (I)

  if !(nargin == 1)
    print_usage ();
  endif

  if (! isnumeric (I))
    error("std2: I must be a numeric vector or matrix");
  endif

  if (isfloat (I))
    s = std (I(:));
  else
    s = std (double (I(:)));
  endif

endfunction

%!test
%! a = std2 (uint16 (eye (10)));
%! b = std (eye (10)(:));
%! assert (a, b);
%! A = eye (10) - 0.1;
%! A2 = A .* A;
%! s = sum (A2(:));
%! res = sqrt (s / 99);
%! assert (std2 (eye (10)), res, eps);
%! assert (std2 (single (eye (10))), single(res), 2 * eps('single'));
%! assert (std2 (uint8 (eye (10))), res, eps);
%! assert (std2 (int8 (eye (10))), res, eps);
%! assert (std2 (uint8 (eye (10))), res, eps);
%! assert (std2 (uint16 (eye (10))), res, eps);
%! assert (std2 (int16 (eye (10))), res, eps);
%! assert (std2 (int32 (eye (10))), res, eps);
%! assert (std2 (uint32 (eye (10))), res, eps);
%! assert (std2 (int64 (eye (10))), res, eps);
%! assert (std2 (uint64 (eye (10))), res, eps);
%! assert (std2 (int64 (2^63 * eye (10))) / 2^63, res, eps);
%! assert (std2 (uint64 (2^64 * eye (10))) / 2^64, res, eps);
%! assert (class (std2 (eye (10))), 'double');
%! assert (class (std2 (single (eye (10)))), 'single');
%! assert (class (std2 (uint8 (eye (10)))), 'double');
%!
## Verify std2 accepts complex data types
%!assert (std2 ([2, 3+4i; 55, 66+77i]), 50.760056474883214, 10*eps)
%!
## Expected test failures due to int64 -> double conversion limitations.
%!error assert (std2 (int64 (2^64 * eye (10))) / 2^64, std2 (eye (10)))
%!error assert (std2 (uint64 (2^65 * eye (10))) / 2^65, std2 (eye (10)))

%!error <Invalid call> std2 ()
%!error <I must be a numeric> std2 ('aaa')
%!error <too many inputs> std2 (eye (10), eye (10))
