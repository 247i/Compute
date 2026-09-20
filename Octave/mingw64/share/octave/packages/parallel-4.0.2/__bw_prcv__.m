## This code is in the public domain.

## -*- texinfo -*-
## @deftypefn {Function File} {ret =} __bw_prcv__ (@var{fd})
## Wrapper for fload for backwards compatibility (optim package).
## @end deftypefn

function ret = __bw_prcv__ (varargin)

  ret.psend_var = fload (varargin{:});

endfunction
