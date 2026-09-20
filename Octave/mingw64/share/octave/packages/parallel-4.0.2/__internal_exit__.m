## This code is in the public domain.

## -*- texinfo -*-
## @deftypefn {Function File} {} __internal_exit__ (@var{status})
## Wrapper for __exit__ for backwards compatibility.
## @end deftypefn

function __internal_exit__ (varargin)

  __exit__ (varargin{:});

endfunction
