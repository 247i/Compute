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
## @deftypefn {Function File} {} degrees2dm (@var{deg})
## Convert decimal degrees to its degrees and minutes components.
##
## Separates the fractional part of an angle in decimal degrees and converts
## it into minutes.  Each row of the output corresponds to one angle,
## the first column to the degree component (an integer), and the second
## to the minutes (which may have a fractional part, and will have magnitude
## less than 60).
##
## @example
## @group
## degrees2dm (10 + 22.5/60)
## @result{}  [ 10   22.5 ]
## @end group
## @end example
##
## The sign of the first non-zero component indicates the sign of
## the angle, i.e., if the degree component is zero, the sign of the minutes
## indicates the sign of the angle, but if the degree component is non-zero,
## the minute component will be positive independently of the sign of the
## angle.  For example:
##
## @example
## @group
## angles = [  10.5
##            -10.5
##             -0.5
##              0.5 ];
## degrees2dm (angles)
##   @result{}
##          10   30
##         -10   30
##           0  -30
##           0   30
## @end group
## @end example
##
## @seealso{degrees2dms, dm2degrees, dms2degrees}
## @end deftypefn

## Author: Carnë Draug <carandraug@octave.org>

function dm = degrees2dm (deg)

  if (nargin != 1)
    print_usage ();
  endif

  if (! isreal (deg))
    error ("degrees2dm: input must be a non-complex matrix or scalar");
  endif

  if (! iscolumn (deg))
    warning ("Octave:array-to-vector",
             "degrees2dm: DEG reshaped into column vector");
  endif

  if (isinteger (deg))
    ## If the angles are integers, there is no decimal part
    ## so this is easy. Also, class must be conserved.
    dm = [ deg(:) zeros(numel (deg), 1, class (deg)) ];

  elseif (ischar (deg) || islogical (deg))
    ## Handle like integer types except convert to double.
    dm = [ double(deg(:)) zeros(numel (deg), 1) ];

  elseif (isa (deg, "single") || isa (deg, "double"))
    d = fix (deg(:));
    m = (deg(:) - d) * 60;

    ## Make minutes positive where degrees are nonzero.
    ## Avoid changing NaN.
    idx = (d != 0) & (m <= 0);
    m(idx) = abs (m(idx));

    ## For compatibility with MATLAB R2023b:
    ## Make sign of minutes match sign of degrees where both are zero.
    idx = (d == 0) & (m == 0);
    m(idx) = d(idx);

    dm = [d m];
  else
    error ("degrees2dm: input class not supported");
  endif

endfunction


%!test
%! deg = [10 10.5 -10.5 -0.5 0.5]';
%! dm = [ 10    0
%!        10   30
%!       -10   30
%!         0  -30
%!         0   30];
%! for i = 1:rows (deg)
%!   assert (degrees2dm (deg(i)), dm(i,:));
%!   assert (degrees2dm (single (deg(i))), single (dm(i,:)));
%! endfor
%! assert (degrees2dm (deg), dm);
%! assert (degrees2dm (single (deg)), single (dm));
%!
%! warning ("error", "Octave:array-to-vector", "local")
%! got_warn = false;
%! try
%!   degrees2dm (deg');
%! catch
%!   got_warn = true;
%! end_try_catch
%! assert (got_warn, true)

%!error <non-complex> degrees2dm (1 + 2i)

%!assert (degrees2dm ("f"), [102 0])
%!assert (degrees2dm ("fm"), [102 0; 109 0])
%!assert (degrees2dm (true), [1 0])
%!assert (degrees2dm ([true false]), [1 0; 0 0])
%!assert (degrees2dm (uint8 ([5 48 9]')), uint8 ([5 0; 48 0; 9 0]))
%!assert (degrees2dm (10 + 22.5/60), [10 22.5])
%!assert (degrees2dm ([-10.5; -0.5]), [-10 30; 0 -30])
%!assert (degrees2dm (realmax ()), [realmax() 0])
%!assert (degrees2dm (realmax ("single")), [realmax("single") 0])
%!assert (degrees2dm (Inf), [Inf NaN]);
%!assert (degrees2dm (-Inf), [-Inf NaN]);
%!assert (degrees2dm (NaN), [NaN NaN])
%!assert (degrees2dm (NA), [NA NA])
%!assert (degrees2dm ([]), zeros (0, 2))
%!assert (degrees2dm (2e14 + 0.25), [2e14 15])
%!assert (degrees2dm (single(3e5 + 0.25)), single([3e5 15]))
%!assert (degrees2dm (1 - eps (1 - eps (1))) < [1 60])
%!assert (degrees2dm (1 - eps (1 - eps (single (1)))) < [1 60])

## Verify signs (including of zeros) match MATLAB R2023b.
%!assert (1 ./ degrees2dm(+0.0), [Inf Inf])
%!assert (1 ./ degrees2dm(-0.0), [-Inf -Inf])
%!assert (1 ./ degrees2dm(-0.5), [-Inf -1/30])
%!assert (1 ./ degrees2dm(-2.0), [-0.5 Inf])
