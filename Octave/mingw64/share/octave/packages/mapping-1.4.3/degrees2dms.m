## Copyright (C) 2014-2022 Carnë Draug <carandraug@octave.org>
## Copyright (C) 2024-2025 The Octave Project Developers
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} degrees2dms (@var{deg})
## Convert decimal degrees into degrees, minutes, and seconds components.
##
## degrees2dms separates the fractional part of angles and converts them into
## minutes and seconds.  The degree values are converted into decimal degrees.
##
## Input can be a real-valued scalar or column vector.  Row vectors are
## accepted as well but will be transposed before processing.
##
## The output comprises a nx3 matrix of double.  Each output row corresponds to one
## angle of the input vector: the first and second columns are the degree and
## minute components, respectively (both integers), and the third to the
## seconds (which may have a fractional part).  The minutes and seconds always
## have magnitudes less than 60.  The signs of output components not after a
## nonzero output component match the sign of the input, and any other output
## components have positive sign.
##
## @example
## @group
## degrees2dms (10 + 30/60 + 56.25/3600)
## @result{}  [ 10   30   56.25 ]
## @end group
## @end example
##
## The sign of the first nonzero output component matches the sign of
## the input, and the other output components are not less than zero.
##
## @example
## @group
## angles = [  10.5
##            -10.5
##             -0.5
##              0.5 ];
## degrees2dms (angles)
##   @result{}
##          10   30   0
##         -10   30   0
##           0  -30   0
##           0   30   0
## @end group
## @end example
##
## @seealso{degrees2dm, dm2degrees, dms2degrees}
## @end deftypefn

## Author: Carnë Draug <carandraug@octave.org>

function dms = degrees2dms (deg)

  if (nargin != 1)
    print_usage ();
  endif

  if (! isreal (deg))
    error ("degrees2dms: input must be a non-complex matrix or scalar");
  endif

  if (! iscolumn (deg))
    warning ("Octave:array-to-vector",
             "degrees2dms: DEG reshaped into column vector");
  endif

  if (isinteger (deg))
    ## If the angles are integers, there is no decimal part
    ## so this is easy. Also, class must be conserved.
    dms = [ deg(:) zeros(numel (deg), 2, class (deg)) ];

  elseif (ischar (deg) || islogical (deg))
    ## Handle like integer types except convert to double.
    dms = [ double(deg(:)) zeros(numel (deg), 2) ];

  elseif (isa (deg, "double") || isa (deg, "single"))
    ## Compute output intended to match that of MATLAB R2023b.
    ## Accuracy is good, but not best possible.

    ## Separate sign and magnitude.
    negative = signbit (deg)(:);
    a = abs (deg)(:);

    ## Compute output component magnitudes.
    d = fix (a);
    d_fractional_part = a - d;
    m_with_fractional_part = d_fractional_part * 60;
    m = fix (m_with_fractional_part);
    m_fractional_part = m_with_fractional_part - m;
    s = m_fractional_part * 60;

    ## Apply input sign to output components not after a nonzero component.
    d(negative) .*= -1;
    m(negative & (d == 0)) .*= -1;
    s(negative & (d == 0) & (m == 0)) .*= -1;

    dms = [d m s];
  else
    error ("degrees2dms: input class not supported");
  endif

endfunction


%!test
%! warning ("error", "Octave:array-to-vector", "local")
%! got_warn = false;
%! try
%!   degrees2dms ([1 2]);
%! catch
%!   got_warn = true;
%! end_try_catch
%! assert (got_warn, true)

%!error <non-complex> degrees2dms (1 + 2i)

%!assert (degrees2dms ("f"), [102 0 0])
%!assert (degrees2dms ("fm"), [102 0 0; 109 0 0])
%!assert (degrees2dms (true), [1 0 0])
%!assert (degrees2dms ([true false]), [1 0 0; 0 0 0])
%!assert (degrees2dms (uint8 ([5 48 9]')), uint8 ([5 0 0; 48 0 0; 9 0 0]))
%!assert (degrees2dms (10 + 30/60 + 56.25/3600), [10 30 56.25])
%!assert (degrees2dms ([-10.5; -0.5]), [-10 30 0; 0 -30 0])
%!assert (degrees2dms (realmax ()), [realmax() 0 0])
%!assert (degrees2dms (realmax ("single")), [realmax("single") 0 0])
%!assert (degrees2dms (Inf), [Inf NaN NaN]);
%!assert (degrees2dms (-Inf), [-Inf NaN NaN]);
%!assert (degrees2dms (NaN), [NaN NaN NaN])
%!assert (degrees2dms (NA), [NA NA NA])
%!assert (degrees2dms ([]), zeros (0, 3))

## Test near realmin and sixtieths of degrees.
%!test
%! x = 0:600;
%! for c = [true, false]
%!   if (c)
%!     x = single(x);
%!   endif
%!   y = x ./ 60;
%!   y = [y realmin(class (x))];
%!   n = 200;
%!   deg = y + [eps(y - eps (y)) .* ((-n):0) .'; eps(y) .* (1:n).'];
%!   deg = deg(deg >= 0);
%!   deg = [deg; -deg];
%!
%!   deg_i = fix (deg);
%!   deg_f = deg - deg_i;
%!   abs_deg = abs (deg);
%!   abs_deg_f = abs (deg_f);
%!   inv_deg = 1 ./ deg;
%!
%!   dms = degrees2dms (deg);
%!   d = dms(:, 1);
%!   m = dms(:, 2);
%!   s = dms(:, 3);
%!   abs_d = abs (d);
%!   abs_m = abs (m);
%!   abs_s = abs (s);
%!   inv_d = 1 ./ d;
%!   inv_m = 1 ./ m;
%!   inv_s = 1 ./ s;
%!
%!   assert (d, fix (d));
%!   assert (m, fix (m));
%!   assert (abs_m < 60);
%!   assert (abs_s < 60);
%!
%!   ## Verify signs match documentation.
%!   assert ( ...
%!     ((deg >= 0) & (d >= 0) & (m >= 0) & (s >= 0)) | ...
%!     ((deg <  0) & (d <  0) & (m >= 0) & (s >= 0)) | ...
%!     ((deg <  0) & (d == 0) & (m <  0) & (s >= 0)) | ...
%!     ((deg <  0) & (d == 0) & (m == 0) & (s <  0)) ...
%!   );
%!
%!   ## Verify signs (including of zeros) match MATLAB R2023b.
%!   assert ( ...
%!     ((inv_deg > 0) & (inv_d >   0  ) & (inv_m >   0  ) & (inv_s > 0)) | ...
%!     ((inv_deg < 0) & (    d <   0  ) & (inv_m >   0  ) & (inv_s > 0)) | ...
%!     ((inv_deg < 0) & (inv_d == -Inf) & (    m <   0  ) & (inv_s > 0)) | ...
%!     ((inv_deg < 0) & (inv_d == -Inf) & (inv_m == -Inf) & (inv_s < 0)) ...
%!   );
%!
%!   ## Check accuracy.
%!   ## Note that a non-zero tolerance is necessary for the round-trip tests,
%!   ## so this approach only verifies approximate correctness.
%!   assert (d, deg_i);
%!   assert (abs_s ./ 3600 + abs_m ./ 60, abs_deg_f, eps (abs_deg_f));
%!   assert (abs_s ./ 3600 + abs_m ./ 60 + abs_d, abs_deg, eps (abs_deg));
%!
%!   ## Verify minutes and seconds do not depend on integer part of input.
%!   assert (abs (dms(:, 2:3)), abs (degrees2dms (deg_f)(:, 2:3)));
%! endfor
