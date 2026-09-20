
## Copyright (C) 2023 The Octave Project Developers
## Copyright (C) 2023 Mohammed Azmat Khan < azmat.dev0@gmail.com >
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
## @deftypefn {Function File} {@var{y} =} ssbmod (@var{x}, @var{fc}, @var{fs})
## @deftypefnx {Function File} {@var{y} =} ssbmod (@var{x}, @var{fc}, @var{fs}, @var{phi})
## @deftypefnx {Function File} {@var{y} =} ssbmod (@var{x}, @var{fc}, @var{fs}, @var{phi}, @var{band})
##
## Creates the SSB modulation of the amplitude signal @var{x}
## with carrier frequency @var{fc} , sampling frequency @var{fs}
## initial phase : @var{phi} and specified band : @var{band}
## initial phase : @var{phi} and specified band : @var{band} are optional
## arguments and initial phase : @var{phi} will be considered 0 if not given.
## specified band : @var{band} by default is lower sideband, but upper sideband
## can be specified by giving 'upper' as the fourth argument.
##
##
## references and equation for ssbmod:
## https://electronicscoach.com/single-sideband-modulation.html
## https://www.ee-diary.com/2023/02/ssb-sc-am-signal-generation-in-matlab.html
##
##
## Inputs:
## @itemize
## @item
## @var{x}: amplitude message signal
##
## @item
## @var{fc}: carrier frequency
##
## @item
## @var{fs}: sampling frequency
##
##
## @item
## @var{phi}: initial phase (defaults to 0)
##
##
## @item
## @var{band}: specified band (if upper)
## @end itemize
##
## Output:
## @itemize
## @var{y}: The SSB modulation of @var{x}
## @end itemize
## Demo
## @example
## demo ssbmod
## @end example
## @seealso{ssbdemod,ammod,amdemod, fmmod, fmdemod}
## @end deftypefn







function y = ssbmod (x, fc, fs, varargin)

  % checks for input arguments

  % check for no. of arguments
  if (nargin > 5 || nargin < 3)
    print_usage ();
  endif

  % check if fs < 2*fc
  if (fs < 2 .* fc)
    error ("ssbmod: fs is too small, must be at least 2 * fc")
  endif

  % check for initial phase. if empty phi = 0
  if( nargin >= 4)
    phi = varargin{1};
    if (isempty(phi))
      phi = 0;
    endif
  else
    phi = 0;
  endif

  % check if upper band specified band
  band = '';
  if (nargin == 5)
    band = varargin{2};
    if (!strcmpi(band,'upper'))
      error ("ssbmod: band argument can only be 'upper'")
    endif
  endif


  % Input arguments check end


  l = length (x);

  % defining t from sampling frequency fs
  t = reshape (0: 1 ./ fs: (l - 1) ./ fs, size(x));

  % Hilbert transform of message signal
  mh = imag(hilbert(x));

  % ssbmod equation for upper sideband
  if (strcmpi(band, 'upper'))
    y = (x .* cos(2 .* pi .* fc .* t + phi)) - (mh .* sin(2 .* pi .* fc .* t + phi));

  % ssbmod equation for Lower side band
  else
    y = (x .* cos(2 .* pi .* fc .* t + phi)) + (mh .* sin(2 .* pi .* fc .* t + phi));
  endif


endfunction

%------------------------------- end of function ----------------------
%
## Test input validation
%!error ssbmod ()
%!error ssbmod (1)
%!error ssbmod (1, 2)
%!error ssbmod (1, 2, 3, 4)
%!error ssbmod (1, 2, 3, 4, 5)
%
%!error <fs is too> ssbmod (pi/2, 100, 10)
%
%
%!demo
%! #carrier frequency
%! fc=400;
%! #sampling frequency
%! fs=8000;
%!
%! t=0:(1/fs):0.1;
%!
%! #message signal y
%! y=sin(20*pi*t);
%!
%! #ssb modulation
%! y1=ssbmod(y,fc,fs);
%!
%! #plot results
%! figure(1)
%! subplot(2,1,1)
%! plot(t,y)
%!
%! #ssbmod plot
%! subplot(2,1,2)
%! plot(t,y1)

