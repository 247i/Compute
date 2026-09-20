## Copyright (C) 2015, 2016 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn{Function File} {} __netcellfun_guardfun__ (@dots{})
##
## Undocumented internal function.
##
## @end deftypefn

function varargout = __netcellfun_guardfun__ (func, errh, idx, varargin)

  ## This must be an extra function file to be visible at the remote
  ## side.

  nout = nargout ();

  try
    [varargout{1:nout}] = func (varargin{:});
  catch
    errs = lasterror ();
    errs.index = idx;
    [varargout{1:nout}] = errh (errs, varargin{:});
  end_try_catch

endfunction
