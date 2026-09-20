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
## @deftypefn{Function File} {} rfeval (@var{func}, @dots{}, @var{nout}, @var{isout}, @var{connection})
## Evaluate a function at a remote machine.
##
## @var{func} is evaluated with arguments @code{@dots{}} and number of
## output arguments set to @var{nout} at remote machine given by
## @var{connection}. If @var{isout} is not empty, it must be a logical
## array with @var{nout} elements, which are true for each of the
## @var{nout} output arguments which are requested from the function;
## the other output arguments will be  marked as not requested
## with @code{~} at remote execution.
##
## This function can only be successfully called at the client machine.
## See @code{pconnect} for a description of the @var{connection}
## variable. @var{connection} must contain one single connection.
##
## If an output argument is given to @code{rfeval}, the function waits
## for completion of the remote function call, retrieves the results and
## returns them. They will be returned as one cell-array with an entry
## for each output argument. If some output arguments are marked as not
## requested by setting some elements of @var{isout} to false, the
## returned cell-array will only have entries for the requested output
## arguments. For consistency, the returned cell-array can be empty. To
## assign the output arguments to single variables, you can for example
## use: @code{[a, b, c] = returned_cell_array@{:@};}.
##
## If no output argument is given to @code{rfeval}, the function does
## not retrieve the results of the remote function call but returns
## immediately. It is left to the user to retrieve the results with
## @code{precv}. The results will be in the same format as if returned
## by @code{rfeval}. Note that a cell-array, possibly empty, will always
## have to be retrieved, even if the remote function call should have
## been performed without output arguments.
##
## Parallel execution can be achieved by calling @code{rfeval} several
## times with different specified server machines before starting to
## retrieve the results.
##
## The specified function handle can refer to a function present at
## the executing machine or be an anonymous function. See
## @code{parallel_doc ("limitations")} for possible limitations.
##
## @seealso{pconnect, pserver, sclose, install_vars, netcellfun}
## @end deftypefn

function ret = rfeval (varargin)

  if ((nargs = nargin ()) < 4)
    print_usage ();
  endif

  fname = "rfeval";

  if (! isa (conn = varargin{end}, "pconnections"))
    error ("%s:  `connection' must be a parallel connections object", fname);
  elseif (numel (conn) != 1)
    error ("%s: exactly one connection must be specified", fname);
  elseif (network_get_info (conn).local_machine)
    error ("%s: client was specified instead of server");
    ## reval() checks if specified at server side
  endif

  if (! is_function_handle (varargin{1}))
    error ("%s: `func' must be a function handle", fname);
  endif

  if (! isnumeric (nout = varargin{end - 2}) || ! isscalar (nout) || ...
      (nout = round (nout)) < 0)
    error ("%s: `nout' must be a non-negative integer", fname);
  endif

  if (isempty (isout = varargin{end - 1}))
    isout = true (1, nout);
  elseif (! islogical (isout) || numel (isout) != nout)
    error ("%s: `isout' must be empty or a logical with `nout' elements",
           fname);
  endif
  isout = isout(:);

  ## feval() isn't called remotely since it doesn't resepect ignoring of
  ## output variables with '~'. So the function handle has to be sent
  ## separately and a remote temporary variable has to be used for it.
  ##
  ## rargs = varargin(1 : end - 3); # could be used with feval
  func = varargin{1};
  rargs = varargin(2 : end - 3);

  if (any (ign = ! isout))
    rout = repmat ({"__pserver_tout__{%i},"}, nout, 1);
    rout(ign) = {"~,"};
    rout = cstrcat (rout{:});
    rout = sprintf (rout, 1 : sum (isout));
    rout = rout(1 : end - 1); # remove final ','
    rout = sprintf ("[%s]", rout);
    if (all (ign))
      init_rout = "__pserver_tout__ = {}; ";
    else
      init_rout = "";
    endif
  else
    rout = sprintf ("[__pserver_tout__{1:%i}]", nout);
    init_rout = "";
  endif

  cmd = sprintf ...
      ("__pserver_tfunc__ = precv (sockets(1)); %s%s = __pserver_tfunc__ (precv (sockets(1)){:}); psend (__pserver_tout__, sockets(1)); clear ('__pserver_tout__');",
       init_rout, rout);

  reval (cmd, conn);

  ready = false;

  unwind_protect

    psend (func, conn);

    psend (rargs, conn);

    ready = true;

  unwind_protect_cleanup

    if (! ready)
      sclose (conn); # might already be closed from within reval or psend
    endif

  end_unwind_protect

  if (nargout () > 0)
    ret = precv (conn);
  endif

endfunction
