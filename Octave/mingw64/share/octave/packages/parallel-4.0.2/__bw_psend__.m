## This code is in the public domain.

## -*- texinfo -*-
## @deftypefn {Function File} {} __bw_psend__ (@var{fd}, @var{var})
## Wrapper for fload for backwards compatibility (optim package).
## @end deftypefn

function __bw_psend__ (varargin)

  fsave (varargin{:});

endfunction
