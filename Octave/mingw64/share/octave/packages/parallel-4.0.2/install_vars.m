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
## @deftypefn{Function File} {} install_vars (@var{varname}, @dots{}, @var{connections})
## Install named variables at remote machines.
##
## The variables named in the arguments are distrubted to the remote
## machines specified by @var{connections} and installed there. The
## variables must be accessible within the calling function. If
## variables have been declared to have global scope, they will also
## have global scope at the remote machines.
##
## This function can only be successfully called at the client machine.
## See @code{pconnect} for a description of the @var{connections}
## variable. @var{connections} can contain all connections of the
## network, a subset of them, or a single connection. The local machine
## (client), if contained in @var{connections}, is ignored.
##
## To install, e.g., all visible variables,
##
## @code{install_vars (who ()@{:@}, @dots{});}
##
## can be used.
##
## Internally, this function sends the variables only to one server and
## then issues the necessary commands to distribute them to all
## specified servers over server-to-server data connections.
##
## @seealso{pconnect, pserver, sclose, rfeval, netcellfun}
## @end deftypefn

function ret = install_vars (varargin)

  if ((nargs = nargin ()) < 1 || ...
      ! iscellstr (varnames = varargin(1 : end - 1)))
    print_usage ();
  endif

  fname = "install_vars";

  if (! isa (conns = varargin{end}, "pconnections"))
    error ("%s: `connections' must be a parallel connections object", fname);
  endif

  ## reval() will check if specified at server side

  ## delete local machine from connections if present
  conns = conns(! [network_get_info(conns).local_machine]);

  if ((nhosts = numel (conns)) == 0)
    return;
  endif

  if ((nvars = numel (varnames)) == 0)
    return;
  endif

  ## get an index translation into the remote variable of connections
  ## ('sockets')
  ridx = [network_get_info(conns).real_node_id] + 1;

  ## retrieve cell-array of variable values from variable names in
  ## calling function
  [vars{1:nvars}] = evalin("caller",
                           sprintf ("{%s%s}{:}", varnames{1},
                                    ifelse (nvars > 1,
                                            sprintf (", %s", varnames{2:end}),
                                            "")));

  ## retrieve logical vector of corresponding 'global' states
  vglobal = __visglobal__ (varnames);

  ## construct binary tree of transfers
  source_hosts = 1;
  source_id = zeros (0, 1);
  target_ids = zeros (0, 2);

  [source_id, target_ids] = add_transfers (source_id, target_ids,
                                           source_hosts, nhosts);

  if (any (vglobal))
    recv_cmd1 = sprintf ("%s%s%s",
                         "global ",
                         sprintf ("%s ", varnames{vglobal}),
                         "; ");
  else
    recv_cmd1 = "";
  endif

  ## we need a temporary for easily sending the vars to the next server
  recv_cmd2_mask = sprintf ("__pserver_tvars__ = precv (sockets(%%i)); [%s%s] = __pserver_tvars__{:}; ",
                            varnames{1},
                            ifelse (nvars > 1,
                                    sprintf (", %s", varnames{2:end}),
                                    ""));

  recv_cmd_mask = cstrcat (recv_cmd1, recv_cmd2_mask);

  send_cmd_mask = "psend (__pserver_tvars__, sockets([%s]));";

  ## It is better to reval the recv command and the possibly following
  ## send commands for a specific server within the same string.
  ## Otherwise the client or a server might block if the command string
  ## does not fit into the socket buffers (and we may have long command
  ## strings here).

  error_in_first_command = false;
  ready = false;

  unwind_protect

    ## initial transfer
    recv_cmd = sprintf (recv_cmd_mask, 1);
    if (nhosts > 1)
      send_cmd = sprintf (send_cmd_mask,
                          get_ridx_string (target_ids(1, :), ridx));
    else
      send_cmd = "";
    endif
    cmd = sprintf ("%s%s", recv_cmd, send_cmd);
    try
      reval (cmd, conns(1));
    catch
      error_in_first_command = true;
      error (lasterror ());
    end_try_catch
    psend (vars, conns(1));

    ## remote transfers
    for ida = 1 : numel (source_id)
      for idb = 1:2
        if ((did = target_ids(ida, idb)) != 0)
          recv_cmd = sprintf (recv_cmd_mask, ridx(source_id(ida)));
          if (isempty (sid = find (source_id == did)))
            send_cmd = "";
          else
            send_cmd = sprintf (send_cmd_mask,
                                get_ridx_string (target_ids(sid, :), ...
                                                 ridx));
          endif
          cmd = sprintf ("%s%s", recv_cmd, send_cmd);
          reval (cmd, conns(did));
        endif
      endfor
    endfor

    ready = true;

  unwind_protect_cleanup

    if (! (ready || error_in_first_command))
      sclose (conns);
    endif

  end_unwind_protect

endfunction

function ret = get_ridx_string (targ_idx, ridx)

  ret = sprintf ("%i", ridx(targ_idx(1)));

  if (targ_idx(2) != 0)
    ret = sprintf ("%s, %i", ret, ridx(targ_idx(2)));
  endif

endfunction

function [source_id, target_ids] = add_transfers (source_id, target_ids,
                                                  source_hosts, nhosts)

  if ((left = nhosts - source_hosts(end)) == 0)
    return;
  endif

  new_source_hosts = zeros (1, 0);

  for idb = 1:2 # two branches

    for ids = 1 : (nsh = numel (source_hosts))

      current_target_id = nhosts + 1 - left;

      if (idb == 1)
        source_id = vertcat (source_id, source_hosts(ids));
        target_ids = vertcat (target_ids, [current_target_id, 0]);
      else
        target_ids(end + ids - nsh, 2) = current_target_id;
      endif

      new_source_hosts = horzcat (new_source_hosts, current_target_id);

      left--;

      if (left == 0) break; endif

    endfor # source hosts

    if (left == 0) break; endif

  endfor # two branches

  [source_id, target_ids] = add_transfers (source_id, target_ids,
                                           new_source_hosts,
                                           nhosts);

endfunction
