
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
## @deftypefn {Function File} {@var{m} =} ssbdemod (@var{s}, @var{fc}, @var{fs})
## @deftypefnx {Function File} {@var{m} =} ssbdemod (@var{s}, @var{fc}, @var{fs}, @var{phi})
##
##
## Creates the SSB demodulation of the signal @var{s}
## with carrier frequency @var{fc}, sampling frequency @var{fs}
## initial phase @var{phi} and a standard 5th order low pass butterworth filter
## [b a] = butter (5, fc .* 2 ./ fs) where b and a are numerator and
## denominator respectively.
##
## The initial phase @var{phi} is optional
## and will be considered 0 if not given.
##
## references and equation for ssdebmod:
## https://electronicscoach.com/single-sideband-modulation.html
## https://www.ee-diary.com/2023/02/ssb-sc-am-signal-generation-in-matlab.html
##
## Inputs:
## @itemize
## @item
## @var{s}: amplitude message signal
##
## @item
## @var{fc}: carrier frequency
##
## @item
## @var{fs}: sampling frequency
##
##
## @item
## @var{phi}: initial phase
## @end itemize
##
## Output:
## @itemize
## @var{m}: The SSB demodulation of @var{s}
## @end itemize
## Demo
## @example
## demo ssbmod
## @end example
## @seealso{ssbmod,ammod,amdemod, fmmod, fmdemod}
## @end deftypefn
function m = ssbdemod (s, fc, fs, varargin)

  % check for arguments
  if(nargin > 4)
    print_usage ();
  endif

  % check if fs > 2*fc
  if (fs < 2 .* fc)
    error ("ssbdemod: fs is too small must be at least 2 * fc")
  endif

  % set phi = 0 if phase is empty

  if(nargin>=4)
    phi = varargin{1};
    if(isempty(phi))
      phi = 0;
    endif
  else
    phi = 0;
  endif

  % Argument check ends

  l = length (s);
  t = reshape (0: 1 ./ fs: (l - 1) ./ fs, size(s));

  % Demodulation equation
  e = s .* cos (2 .* pi .* fc .* t + phi);

  % filtering high frequencies
  [b a] = butter (5, fc .* 2 ./ fs);

  % filtered ssb demodulated equation
  m = filtfilt (b, a, e) .* 2;

endfunction

## Test input validation
%!error ssbdemod ()
%!error ssbdemod (1)
%!error ssbdemod (1, 2)
%!error ssbdemod (1, 2, 3, 4)
%!error ssbdemod (1, 2, 3, 4, 5)
%
%
%!demo
%! fc=400;
%! fs=8000;
%! t=0:(1/fs):0.1;
%! y=sin(20*pi*t);
%! y1=ssbmod(y,fc,fs);
%! y2=ssbdemod(y1,fc,fs);
%! figure(1)
%! subplot(3,1,1)
%! plot(t,y)
%! subplot(3,1,2)
%! plot(t,y1)
%! subplot(3,1,3)
%! plot(t,y2)
