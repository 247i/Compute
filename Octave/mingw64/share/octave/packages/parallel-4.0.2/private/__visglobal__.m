## This file is granted to the public domain.
##
## Olaf Till <i7tiol@t-online.de>

## -*- texinfo -*-
## @deftypefn{Function File} {} __visglobal__ (@var{varname}, @dots{})
## Undocumented internal function.
##
## @end deftypefn

function ret = __visglobal__ (varargin)

  ret = logical (cellfun (@ (x) isglobal (x), varargin));

endfunction
