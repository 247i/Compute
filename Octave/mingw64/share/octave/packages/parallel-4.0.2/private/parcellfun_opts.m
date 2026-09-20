## Copyright (C) 2010 VZLU Prague, a.s., Czech Republic
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
## @deftypefn{Function File} {} parcellfun_opts (args)
## Undocumented internal function.
## @end deftypefn

function [nargs, uniform_output, error_handler, verbose_level, ...
          chunks_per_proc, cumfunc, vectorized, ...
          chunk_size] = parcellfun_opts (caller, args)

  uniform_output = true;
  error_handler = [];
  verbose_level = 0;
  chunks_per_proc = 0; # 0 means than size of chunk is 1
  vectorized = false;
  cumfunc = [];
  chunk_size = 1;

  nargs = length (args);

  ## parse options
  while (nargs > 1)
    opt = args{nargs-1};
    if (! ischar (opt))
      break;
    else
      optl = tolower (opt);
      val = args{nargs};
    endif
    switch (optl)
    case "uniformoutput"
      uniform_output = logical (val);
      if (! isscalar (uniform_output))
        error ("%s: UniformOutput must be a logical scalar", caller);
      endif
    case "errorhandler"
      error_handler = val;
      if (! (isempty (error_handler) || isa (error_handler, "function_handle")))
        error ("%s: ErrorHandler must be a function handle", caller);
      endif
    case "verboselevel"
      verbose_level = val;
      if (! isscalar (verbose_level))
        error ("%s: VerboseLevel must be a numeric scalar", caller);
      endif
    case "chunksperproc"
      if (! isempty (val))
        chunks_per_proc = round (val);
        if (! isscalar (chunks_per_proc) || chunks_per_proc <= 0)
          error ("%s: ChunksPerProc must be a positive scalar", caller);
        endif
      endif
    case "vectorized"
      vectorized = logical (val);
      if (! isscalar (vectorized))
        error ("%s: Vectorized must be a logical scalar", caller);
      endif
    case "cumfunc"
      cumfunc = val;
      if (! (isempty (cumfunc) || is_function_handle (cumfunc)))
        error ("%s: CumFunc must be empty or a function handle", caller);
      endif      
    case "chunksize"
      chunk_size = round (val);
      if (! isscalar (chunk_size) || chunk_size <= 0)
        error ("%s: ChunkSize must be a positive scalar", caller);
      endif
    otherwise
      error ("%s: invalid option ""%s""", caller, opt);
    endswitch
    nargs -= 2;
  endwhile

  if (vectorized)
    if (any (strcmp (caller, {"parcellfun", "netcellfun"})))
      error ("%s: ""Vectorized"" option not accepted by %s",
             caller, caller);
    elseif (chunks_per_proc <= 0 && strcmp (caller, "pararrayfun"))
      error ("%s: the ""Vectorized"" option requires also ""ChunksPerProc""",
             caller);
    endif
  endif

endfunction
