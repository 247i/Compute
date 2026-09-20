## Copyright (C) 2015-2020 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn{Function File} {} netcellfun (@var{connections}, @var{fun}, @dots{})
## Evaluates function @var{fun} in a parallel cluster and collects results.
##
## This function handles arguments and options equivalently to
## @code{parcellfun} and returnes equivalent output. Differently, the
## first argument specifies server machines for parallel remote
## execution, see @code{pconnect} for a description of the
## @var{connections} variable. A further difference is that the option
## "ChunksPerProc" is ignored and instead the chunk size can be
## specified directly with an option "ChunkSize".
##
## This function can only be successfully called at the client machine
## of the parallel cluster. @var{connections} can contain all
## connections of the network, a subset of them, or a single connection.
## The local machine (client), if contained in @var{connections}, is
## ignored. However, one of the servers can run at the local machine
## under certain conditions (see @code{pconnect}) and will not be
## ignored in this case, so that the local machine can take part in
## parallel execution with @code{netcellfun}.
##
## As a second level of parallelism, @var{fun} is executed at each
## server machine (using @code{parcellfun or pararrayfun}) by default in
## as many local processes in parallel as the server has processor cores
## available. The number of local parallel processes can be configured
## for each server with the "nlocaljobs" option (see
## @code{network_set}), a value of @code{0} means that the default value
## will be used, a value of @code{1} means that execution is not
## parallel within the server (but still parallel over the cluster).
##
## See @code{parallel_doc ("limitations")} for possible limitations
## e.g. on how @var{fun} can be defined.
##
## Cluster execution incurs a considerable overhead. A speedup is
## likely if the computation time of @var{fun} is long. To speed up
## execution of a large set of arguments with short computation times
## of @var{fun}, increase "ChunkSize", possibly use "Vectorize" (see
## @code{pararrayfun}), and possibly experiment with increasing
## "nlocaljobs" from the default.
##
## @seealso{netarrayfun, pconnect, pserver, sclose, rfeval, install_vars}
## @end deftypefn

function varargout = netcellfun (varargin)

  if (nargin () < 3)
    print_usage ();
  endif

  [varargout{1 : nargout ()}] = netcellfun_worker (false, varargin{:});

endfunction
