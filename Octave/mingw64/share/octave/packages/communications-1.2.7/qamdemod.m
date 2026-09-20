## Copyright (C) 2007 Sylvain Pelissier <sylvain.pelissier@gmail.com>
## Copyright (C) 2009 Christian Neumair <cneumair@gnome.org>
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
## @deftypefn {Function File} {} qamdemod (@var{x}, @var{M})
## @deftypefnx {Function File} {} qamdemod (@var{x}, @var{M}, @var{symOrder})
## Create the QAM demodulation of @var{x} with a size of alphabet @var{M} using a given @var{symOrder}
## (which can be "gray" (default), "bin", or a vector).
## @seealso{qammod, pskmod, pskdemod}
## @end deftypefn

function z = qamdemod (y, M, symOrder)

  if (nargin < 2 || nargin > 3)
    print_usage ();
  elseif (nargin == 2)
    symOrder = 'gray';
  endif

  c = sqrt (M);
  if (! (c == fix (c) && log2 (c) == fix (log2 (c))))
    error ("qamdemod: M must be a square of a power of 2");
  endif

  x = qammod (0:(M-1), M, symOrder);
  x = reshape (x, 1, M);
  z = reshape (genqamdemod(y(:), x), size(y));
  
endfunction

%% Test input validation
%!error qamdemod ()
%!error qamdemod (1)
%!error qamdemod (1, 2)
%!error qamdemod (1, 2, 3)
