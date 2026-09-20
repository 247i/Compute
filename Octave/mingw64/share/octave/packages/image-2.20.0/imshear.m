## Copyright (C) 2002 Jeff Orchard <jjo@sfu.ca>
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
## @deftypefn {Function File} {} imshear (@var{M}, @var{axis}, @var{alpha}, @var{bbox})
## Applies a shear to a given image.
##
## The argument @var{M} is either a matrix or an RGB image.
##
## @var{axis} is the axis along which the shear is to be applied, and can
## be either 'x' or 'y'.
## For example, to shear sideways is to shear along the 'x' axis. Choosing
## 'y' causes an up/down shearing.
##
## @var{alpha} is the slope of the shear. For an 'x' shear, it is the
## horizontal shift (in pixels) applied to the pixel above the
## center. For a 'y' shear, it is the vertical shift (in pixels)
## applied to the pixel just to the right of the center pixel.
##
## NOTE: @var{alpha} does NOT need to be an integer.
##
## @var{bbox} can be one of 'loose', 'crop' or 'wrap'.
## 'loose' allows the image to grow to accommodate the new transformed image.
## 'crop' keeps the same size as the original, clipping any part of the image
## that is moved outside the bounding box.
## 'wrap' keeps the same size as the original, but does not clip the part
## of the image that is outside the bounding box. Instead, it wraps it back
## into the image.
##
## If called with only 3 arguments, @var{bbox} is set to 'loose' by default.
## @end deftypefn

function g = imshear(m, axis, alpha, bbox, noshift)

  if (nargin < 3 || nargin > 5)
    print_usage ();
  endif

  if (! isnumeric (m) || islogical (m) || ndims (m) > 3 ...
        || all (size (m, 3) !=  [1, 3]))
    error ("imshear: M must be a matrix or RBG image");
  endif

  if (! any (strcmpi (axis, {'x', 'y'})))
    error ("imshear: AXIS must be either 'X' or 'Y'")
  endif

  if (! isnumeric (alpha) || ! isscalar (alpha))
    error ("imshear: ALPHA must be a numeric scalar");
  endif

  # The code below only does y-shearing. This is because of
  # the implementation of fft (operates on columns, but not rows).
  # So, transpose first for x-shearing.
  if ( strcmp(axis, "x")==1 )
    m = m';
  endif

  if (nargin < 5)
    noshift = 0;
    if (nargin < 4)
      bbox = "loose";
    else
      if (! any (strcmpi (bbox, {"loose", "crop", "wrap"})))
        error ("imshear: BBOX must be either 'loose', 'crop' or 'wrap'");
      endif
    endif
  else
    if (! isscalar (noshift) || all (noshift != [0, 1]))
      error ("imshear: NOSHIFT must be true of false");
    endif
  endif

  [ydim_orig xdim_orig] = size(m);
  if ( strcmp(bbox, "wrap") == 0 )
    ypad = ceil( (xdim_orig+1)/2 * abs(alpha) );
    m = padarray (m, ypad);
  endif

  [ydim_new xdim_new] = size(m);
  xcentre = ( xdim_new + 1 ) / 2;
  ycentre = ( ydim_new + 1 ) / 2;

  # This applies FFT to columns of m (x-axis remains a spatial axis).
  # Because the way that fft and fftshift are implemented, the origin
  # will move by 1/2 pixel, depending on the polarity of the image
  # dimensions.
  #
  # If dim is even (=2n), then the origin of the fft below is located
  # at the centre of pixel (n+1). ie. if dim=16, then centre is at 9.
  #
  # If dim is odd (=2n+1), then the origin of the fft below is located
  # at the centre of pixel (n). ie. if dim=15, then centre is at 8.
  if ( noshift==1 )
    M = fft(m);
  else
    #M = imtranslate(fft(imtranslate(m, -xcentre, ycentre, "wrap")), xcentre, -ycentre, "wrap");
    M = fftshift(fft(fftshift(m)));
  endif

  [ydim xdim] = size(m);
  x = zeros(ydim, xdim);

  # Find coords of the origin of the image.
  if ( noshift==1 )
    xc_coord = 1;
    yc_coord = 1;
    l = (1:ydim)' - yc_coord;
    r = (1:xdim) - xc_coord;
    if ( strcmp(bbox, "wrap")==1 )
      l((ydim/2):ydim) = l((ydim/2):ydim) - ydim;
      r((xdim/2):xdim) = r((xdim/2):xdim) - xdim;
    endif
  else
    xc_coord = (xdim+1)/2;
    yc_coord = (ydim+1)/2;
    l = (1:ydim)' - yc_coord;
    r = (1:xdim) - xc_coord;
  endif
  x = l * r;

  Ms = M.* exp(2*pi*I*alpha/ydim * x);

  if ( noshift==1 )
    g = abs(ifft(Ms));
  else
    #g = abs(imtranslate( ifft( imtranslate(Ms, -xcentre, ycentre, "wrap") ), xcentre, -ycentre, "wrap"));
    g = abs( fftshift(ifft(ifftshift(Ms))) );
  endif

  if ( strcmp(bbox, "crop")==1 )
    g = g(ypad+1:ydim_orig+ypad, :);
  endif

  # Un-transpose if x-shearing was wanted
  if ( strcmp(axis, "x")==1 )
    g = g';
  endif
endfunction

%!error imshear ()
%!error imshear (1)
%!error imshear (1, "x")
%!error imshear (1, "x", 3, "loose", 5, 6)
%!error <M must be a matrix or RBG image> imshear ("foo", "x", 3)
%!error <M must be a matrix or RBG image> imshear ({1, 2, 3}, "x", 3)
%!error <M must be a matrix or RBG image> imshear (reshape (1:24, 4, 3, 2), "x", 3)
%!error <M must be a matrix or RBG image> imshear (reshape (1:24, 2, 3, 2, 2), "x", 3)
%!error <AXIS must be either> imshear (1, "Z", 3)
%!error <ALPHA must be a numeric scalar> imshear (1, "x", "foo")
%!error <ALPHA must be a numeric scalar> imshear (1, "x", "f")
%!error <ALPHA must be a numeric scalar> imshear (1, "x", [1, 2, 3])
%!error <ALPHA must be a numeric scalar> imshear (1, "x", {3})
%!error <BBOX must be> imshear (1, "x", 3, "foo")
%!error <NOSHIFT must be> imshear (1, "x", 3, "loose", 7)
%!error <NOSHIFT must be> imshear (1, "x", 3, "loose", "foo")
%!error <NOSHIFT must be> imshear (1, "x", 3, "loose", [1 0])

