## Copyright (C) 2015, 2016 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn{Function File} {} netarrayfun (@var{connections}, @var{fun}, @dots{})
## Evaluates function @var{fun} in a parallel cluster and collects results.
##
## This function handles arguments and options equivalently to
## @code{pararrayfun} and returnes equivalent output. Differently, the
## first argument specifies server machines for parallel remote
## execution, see @code{pconnect} for a description of the
## @var{connections} variable. A further difference is that the option
## "ChunksPerProc" is ignored and instead the chunk size can be
## specified directly with an option "ChunkSize" (option "Vectorized"
## can be used together with option "ChunkSize" in function
## @code{netarrayfun}).
##
## The further details of operation are the same as for
## @code{netcellfun}, please see there.
##
## @seealso{netcellfun, pconnect, pserver, sclose, rfeval, install_vars}
## @end deftypefn

function varargout = netarrayfun (varargin)

  if (nargin () < 3)
    print_usage ();
  endif

  [varargout{1 : nargout ()}] = netcellfun_worker (true, varargin{:});

endfunction
