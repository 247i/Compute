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
## @deftypefn{Function File} {} netcellfun_worker (@var{in_arrays} @var{connections}, @var{fun}, @dots{})
##
## Undocumented internal function.
##
## @end deftypefn

function varargout = netcellfun_worker (in_arrays, conns, func, varargin)

  fname = ifelse (in_arrays, "netarrayfun", "netcellfun");

  ## nargin () >= 4 has been assured by caller (netcellfun or netarrayfun)

  if (! isa (conns, "pconnections"))
    error ("%s: `connections' must be a parallel connections object", fname);
  endif

  info = network_get_info (conns);

  ## delete local machine, if present, from connections and from info
  server_idx = ! [info.local_machine];
  conns = conns(server_idx);
  info = info(server_idx);

  if ((nhosts = numel (conns)) == 0)
    error ("%s: connections object contains no servers", fname);
  endif

  nout = nargout ();

  ## options are similar to for parcellfun/pararrayfun
  [nargs, uniform_output, error_handler, verbose_level, ...
   ~, cumfunc, vectorized, chunk_size] = parcellfun_opts (fname, varargin);
  accumulate = ifelse (isempty (cumfunc), false, true);
  args = varargin(1:nargs);

  if (nargs > 1)
    [err, args{:}] = common_size (args{:});
    if (err)
      error ("%s: arguments size must match", fname);
    endif
  endif

  argdims = size (args{1});
  args_are_columns = iscolumn (args{1});
  if (! args_are_columns)
    args = cellfun (@ (x) x(:), args, "UniformOutput", false);
  endif
      

  ## configured or default number of processes at each machine
  rnproc = ifelse ([info.nlocaljobs] == 0, [info.nproc], [info.nlocaljobs]);

  ## number of jobs per call at each machine
  rnjobs = rnproc * chunk_size;

  ## The anonymous functions for remote function calls had to be defined
  ## without using "varargin", since (up to Octave 4.0.0 at least)
  ## anonymous functions with varargin were not saved/loaded
  ## (sent/received) correctly.

  if (any (rnjobs == 1))
    ## There will be (some) single function calls (without parallelity
    ## within one machine and not via cellfun). Prepare function for
    ## single function calls. See below why the 'eh' argument is
    ## necessary.
    if (isempty (error_handler))
      if (in_arrays)
        single_func = @ (idx, eh, varargs) func (varargs{:});
      else
        single_func = @ (idx, eh, varargs) func (vertcat (varargs{:}){:});
      endif
    else
      if (in_arrays)
        single_func = @ (idx, eh, varargs) __netcellfun_guardfun__ ...
            (func, error_handler, idx, varargs{:});
      else
        single_func = @ (idx, eh, varargs) __netcellfun_guardfun__ ...
            (func, error_handler, idx, vertcat (varargs{:}){:});
      endif
    endif
  endif
  ## (For function calls via parcell/arrayfun, the possibly specified
  ## error handler must be wrapped to add a base to errs.index.)

  ## construct function calls specific to each server
  funs = cell (nhosts, 1);

  ## this caused some difficulties (4.0.0) with visibility of private functions
  ## rem_parfun = ifelse (in_arrays, @ pararrayfun, @ parcellfun);
  rem_parfun = ifelse (in_arrays, "pararrayfun", "parcellfun");

  ## (number of argument sets in remote call will be rnproc *
  ## chunk_size, while ChunksPerProc will be 1)
  for (id = 1:nhosts)
    if (rnjobs(id) == 1)
      funs{id} = single_func;
    else
      ## If (rnproc(id) == 1), this will lead to a single call of
      ## cellfun via parcell/arrayfun. This case could be treated more
      ## efficiently. But then we'd have to care for CumFunc here.

      ## We use eval() to shorten the logic, since a function handle for
      ## rem_parfun did not work (see comment above). See next comment
      ## for why the second argument 'eh' is necessary.
      if (isempty (error_handler))
        eval (sprintf ("funs{id} = @ (idx, eh, varargs) %s \
            (rnproc(id), func, varargs{:}, \
             'ChunksPerProc', 1, \
             'UniformOutput', false, \
             'Vectorized', vectorized, \
             'CumFunc', cumfunc, \
             'ErrorHandler', eh);", ...
                       rem_parfun));
      else
        ## The eval() with explicitely named anonymous function
        ## arguments is necessary due to the above mentioned issue with
        ## save/loading anonymous functions with varargin. Also, Octave
        ## doesn't seem to save the context of an anonymous function
        ## defined within another anonymous function -- it doesn't save
        ## the original error handler within the defined error handler
        ## wrapper; for this reason, the error handler has to be passed
        ## as an additional (second) argument to the funcion funs{id},
        ## an argument which could be dropped otherwise.
        arg_list = sprintf (", _%i", 1:nargs);
        eval (sprintf ("funs{id} = @ (idx, eh, varargs) %s \
            (rnproc(id), func, varargs{:}, \
             'ChunksPerProc', 1, \
             'UniformOutput', false, \
             'Vectorized', vectorized, \
             'CumFunc', cumfunc, \
             'ErrorHandler', \
             @ (err %s) eh \
                (setfield (err, 'index', idx(err.index)) \
                 %s));",
                       rem_parfun, arg_list, arg_list));
      endif
    endif
  endfor

  ## the scheduler

  njobs = numel (args{1});
  busy_hosts_lidx = false (1, nhosts);
  busy_hosts_jobs = cell (1, nhosts); # will contain index vectors
                                # into jobs
  left_lidx = true (njobs, 1);

  firstresult = true;
  first_rfeval = true;
  error_in_first_rfeval = false;
  ready = false;

  if (! accumulate)
    varargout = cell (njobs, nout);
  endif

  orig_size = size (args{1});

  unwind_protect

    while (any (left_lidx) || any (busy_hosts_lidx))

      ## create remote jobs if jobs are left

      ## go through all free hosts, there are some (first time or select
      ## returned)
      for host_nid = find (! busy_hosts_lidx)

        ## index vector into jobs for that host, stop creating remote
        ## jobs if no job is left
        if (isempty (job_idxv = find (left_lidx, rnjobs(host_nid))))
          break;
        endif

        ## cargs will contain _column_ arrays
        cargs = cellfun (@ (x) x(job_idxv), args, "UniformOutput", false);

        try
          rfeval (funs{host_nid}, job_idxv, error_handler, cargs, nout, [],
                  conns(host_nid));
        catch
          if (first_rfeval)
            error_in_first_rfeval = true;
          endif
          error (lasterr ());
        end_try_catch

        first_rfeval = false;

        busy_hosts_lidx(host_nid) = true;

        busy_hosts_jobs{host_nid} = job_idxv;

        left_lidx(job_idxv) = false;

      endfor

      ## ready creating jobs, now collect some results

      ## there are busy hosts, if not directly due to the enclosing
      ## while-condition, then due to creating jobs above
      ready_nidx = select_sockets (conns, -1);

      for id = ready_nidx

        ## a cell-array of the outputs, outputs are columns
        res = precv (conns(id));

        ## distinguish between single function and others
        if (rnjobs(id) > 1)
          ## the outputs are in cell-arrays
          res = horzcat (res{:});
        endif

        if (accumulate)
          if (firstresult)
            varargout = res;
            firstresult = false;
          else
            [varargout{:}] = cumfunc (varargout{:}, res{:});
          endif
        else
          varargout(busy_hosts_jobs{id}, :) = res;
        endif

        busy_hosts_lidx(id) = false;

        left_lidx(busy_hosts_jobs{id}) = false;

      endfor

    endwhile

    ready = true;

  unwind_protect_cleanup

    if (! (ready || error_in_first_rfeval))
      sclose (conns); # might already be closed
    endif

  end_unwind_protect

  ## transform the result

  if (uniform_output)
    varargout = cell2mat (varargout);
  endif

  varargout = mat2cell (varargout, rows (varargout), ones (1, nout));

  if (! (accumulate || args_are_columns))
    varargout = cellfun (@ (x) reshape (x, argdims), varargout,
                         "UniformOutput", false);
  endif

endfunction
