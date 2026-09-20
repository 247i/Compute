## Copyright (C) 2009 VZLU Prague, a.s., Czech Republic
## Copyright (C) 2020 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn{Function File} {[@var{o1}, @var{o2}, @dots{}] =} parcellfun (@var{nproc}, @var{fun}, @var{a1}, @var{a2}, @dots{})
## @deftypefnx{Function File} {} parcellfun (nproc, fun, @dots{}, "UniformOutput", @var{val})
## @deftypefnx{Function File} {} parcellfun (nproc, fun, @dots{}, "ErrorHandler", @var{errfunc})
## @deftypefnx{Function File} {} parcellfun (nproc, fun, @dots{}, "VerboseLevel", @var{val})
## @deftypefnx{Function File} {} parcellfun (nproc, fun, @dots{}, "ChunksPerProc", @var{val})
## @deftypefnx{Function File} {} parcellfun (nproc, fun, @dots{}, "CumFunc", @var{cumfunc})
## Evaluates a function for multiple argument sets using multiple
## processes in parallel.
##
## @var{nproc} specifies the number of processes and must be at least
## 1. It will be cut to the number of available CPU cores or the size
## of the input argument(s), whichever is lower. @var{fun} is a
## function handle pointing to the requested evaluating
## function. @var{a1}, @var{a2} etc. should be cell arrays of equal
## size. @var{o1}, @var{o2} etc. will be set to corresponding output
## arguments.
##
## The UniformOutput and ErrorHandler options are supported with
## meaning identical to @dfn{cellfun}. If option VerboseLevel is set
## to 1 (default is 0), progress messages are printed to stderr. The
## ChunksPerProc option controls the number of chunks which contains
## elementary jobs. This option is particularly useful when time
## execution of function is small. Setting this option to 100 is a
## good choice in most cases.
##
## Instead of returning a result for each argument, parcellfun returns
## only one cumulative result if "CumFunc" is non-empty. @var{cumfunc}
## must be a function which performs an operation on two sets of
## outputs of @var{fun} and returnes as many outputs as @var{fun}. If
## @var{nout} is the number of outputs of @var{fun}, @var{cumfunc}
## gets a previous output set of @var{fun} or of @var{cumfunc} as
## first @var{nout} arguments and the current output of @var{fun} as
## last @var{nout} arguments. The performed operation must be
## mathematically commutative and associative. If the operation is
## e.g. addition, the result will be the sum(s) of the outputs of
## @var{fun} over all calls of @var{fun}. Since floating point
## addition and multiplication are only approximately associative, the
## cumulative result will not be exactly reproducible.
##
## Each process has its own pseudo random number generator, so when
## using this function for example to perform Monte-Carlo simulations
## one generally cannot expect results to be exactly
## reproducible. Exact reproducibility may be achievable by generating
## the random number sequence before calling parcellfun and providing
## the random numbers as arguments to @var{fun}.
##
## See @code{parallel_doc ("limitations")} for possible limitations on
## how @var{fun} can be defined.
##
## @seealso{parcellfun_set_nproc}
## @end deftypefn

## Original Author: Jaroslav Hajek <highegg@gmail.com>
## Several improvements thanks to: Travis Collier <travcollier@gmail.com>
## CumFunc feature added by Olaf Till <i7tiol@t-online.de>
##
## The original implementation used 'fork'ed Octave sessions for
## parallel computation. But 'fork' only replicates the current
## thread. This caused problems since Octave can use multi-threaded
## libraries and is itself multi-threaded. So the code for parallel
## computation has been replaced by Olaf Till <i7tiol@t-online.de> to
## be based on a new parallel computation system provided by the
## 'parallel' package as 'oct-file' plugins.

function varargout = parcellfun (nproc, fun, varargin)

  if (nargin < 3 || ! isscalar (nproc) || nproc <= 0)
    print_usage ();
  endif

  if (ischar (fun))
    fun = str2func (fun);
  elseif (! isa (fun, "function_handle"))
    error ("parcellfun: fun must be either a function handle or name")
  endif

  [nargs, uniform_output, error_handler, verbose_level, ...
   chunks_per_proc, cumfunc] = parcellfun_opts ("parcellfun", varargin);

  accumulate = ifelse (isempty (cumfunc), false, true);

  args = varargin(1:nargs);
  if (! all (cellfun ("isclass", args, "cell")))
    error ("parcellfun: all non-option arguments except the first one must be cell arrays");
  endif

  if (nargs == 0)
    print_usage ();
  elseif (nargs > 1)
    [err, args{:}] = common_size (args{:});
    if (err)
      error ("parcellfun: arguments size must match");
    endif
  endif

  njobs = numel (args{1});

  nproc = min (nproc, njobs);

  nproc = __parcellfun_set_nproc_used__ (nproc);

  if (chunks_per_proc > 0 && chunks_per_proc < njobs / nproc)
    ## We need chunked evaluation.

    if (accumulate)
      chunk_uniform_output = false;
    else
      chunk_uniform_output = uniform_output;
    endif

    ## Function executed for a chunk.
    if (isempty (error_handler))
      chunk_fun = @(varargin) cellfun (fun, varargin{:},
                                       "UniformOutput", chunk_uniform_output);
    else
      chunk_fun = @(varargin) cellfun (fun, varargin{:},
                                       "UniformOutput", chunk_uniform_output,
                                       "ErrorHandler", error_handler);
    endif

    if (accumulate)
      chunk_fun = @(varargin) acc_chunk_fun (cumfunc, chunk_fun, varargin{:});
    endif

    [varargout{1:nargout}] = chunk_parcellfun (nproc, chunks_per_proc,
                                               chunk_fun, [], verbose_level,
                                               cumfunc, uniform_output,
                                               args{:});
    return
  endif


  if (accumulate)
    results = cell (1, nargout);
    firstresult = true;
  else
    results = cell (njobs, nargout);
  endif

  unfinished = njobs;
  sent = 0;

  try

    if (isempty (error_handler))
      __parcellfun_initialize_job__ (fun, pwd (), path (), nargout);
    else
      __parcellfun_initialize_job__ (fun, pwd (), path (), nargout,
                                     error_handler);
    endif

  catch

    ## try a reset

    parcellfun_set_nproc (0);

    if (__parcellfun_set_nproc_used__ (nproc) != nproc)

      error ("could not set nproc in reset");

    endif

    if (isempty (error_handler))
      __parcellfun_initialize_job__ (fun, pwd (), path (), nargout);
    else
      __parcellfun_initialize_job__ (fun, pwd (), path (), nargout,
                                     error_handler);
    endif

  end_try_catch

  while (unfinished > 0)

    while ((arg_idx = sent + 1)
           && sent < njobs
           && __parcellfun_send_next_args__
                (arg_idx, get_arg (args, nargs, arg_idx)))

      sent++;

    endwhile

    [idx, res] = __parcellfun_get_next_result__ ();

    if (accumulate)
      if (firstresult)
        results(1, :) = res;
        firstresult = false;
      else
        [results{1, :}] = cumfunc (results{:}, res{:});
      endif
    else
      results(idx, :) = res;
    endif

    unfinished--;

    if (verbose_level > 0)

      fprintf (stderr, "\rparcellfun: %d/%d calculations done",
               njobs - unfinished, njobs);

      fflush (stderr);

    endif

  endwhile

  if (verbose_level > 0)

    fputs (stderr, "\n");

    fflush (stderr);

  endif

  ## transform result

  if (accumulate)

    if (uniform_output)
      varargout = results;
    else
      varargout = num2cell (results);
    endif

  else

    varargout = cell (1, nargout);

    shape = size (args{1});

    for id = 1:nargout

      ## reshape is done after cell2mat because of bug #51448

      if (uniform_output)
        varargout{id} = cell2mat (results(:, id));
      else
        varargout{id} = results(:, id);
      endif

      varargout{id} = reshape (varargout{id}, shape);

    endfor

  endif

endfunction

function varargout = acc_chunk_fun (cumfunc, chunk_fun, varargin)

  [chunk_out{1:nargout}] = chunk_fun (varargin{:});

  nel = numel (chunk_out{1});

  chunk_out = horzcat (chunk_out{:});

  res = chunk_out(1, :);

  for (id = 2 : nel)
    [res{:}] = cumfunc (res{:}, chunk_out{id, :});
  endfor

  varargout = res;

endfunction

function arg = get_arg (args, nargs, idx)

  arg = cell (1, nargs);

  for id = 1:nargs

    arg{id} = args{id}{idx};

  endfor

endfunction

%!test
%! assert (res = parcellfun (3, @ (x, y) x * y, {1, 2, 3, 4}, {2, 3, 4, 5}), [2, 6, 12, 20])

%!test
%! assert (res = parcellfun (4, @ (x, y) x * y, {1, 2, 3, 4}, {2, 3, 4, 5}, "UniformOutput", false), {2, 6, 12, 20})

%!test
%! assert (res = parcellfun (2, @ (x, y) x * y, {1, 2, 3, 4}, {2, 3, 4, 5}, "ChunksPerProc", 2), [2, 6, 12, 20])

%!test
%! assert (res = parcellfun (4, @ (x, y) x * y, {1, 2, 3, 4}, {2, 3, 4, 5}, "CumFunc", @ (a, b) a + b), 40)

%!test
%! assert (res = parcellfun (2, @ (x, y) x * y, {1, 2, 3, 4}, {2, 3, 4, 5}, "ChunksPerProc", 2, "CumFunc", @ (a, b) a + b), 40)

%!test
%! assert (ischar ((res = parcellfun (4, @ (x) sqrt (x), {1, "a", 3, 4, 5, 6},
%!                                    "ErrorHandler",
%!                                    @ (info, x) info.message,
%!                                    "UniformOutput", false)){2}))
