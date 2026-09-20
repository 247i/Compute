%       Copyright(C) 2011 Gianvito Pio, Piero Molino
%  
%       Contact Email: pio.gianvito@gmail.com piero.molino@gmail.com
%       
%	fl-core - Fuzzy Logic Core functions for Octave
%       This file is part of fl-core.
%       
%       fl-core is free software: you can redistribute it and/or modify
%       it under the terms of the GNU Lesser General Public License as published by
%       the Free Software Foundation, either version 3 of the License, or
%       (at your option) any later version.
%       
%       fl-core is distributed in the hope that it will be useful,
%       but WITHOUT ANY WARRANTY; without even the implied warranty of
%       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%       GNU Lesser General Public License for more details.
%       
%       You should have received a copy of the GNU Lesser General Public License
%       along with fl-core.  If not, see <http://www.gnu.org/licenses/>.
%


function res = fl_complement(A)
## -*- texinfo -*-
## @deftypefn{Function File} {@var{res} = } fl_complement(@var{A})
##
## Returns the Fuzzy Logic complement (1 - @var{A}). @var{A} can be a vector or a matrix.
## @end deftypefn
	
	% Check the argument number	
	if (nargin != 1)
		print_usage();
	endif

	% Check the argument type
	if (ismatrix(A))
    res = 1 - A;
	else
		error ("fl_complement: expecting vector or matrix argument");
	endif

endfunction

%!test
%! R = [0.8, 0.1, 0.1, 0.7; 0.0 0.8 0.0 0.0; 0.9 1.0 0.7 0.8];
%! result = fl_complement(R);
%! Rc = [0.2, 0.9, 0.9, 0.3; 1.0 0.2 1.0 1.0; 0.1 0.0 0.3 0.2];
%! assert (Rc, result, eps(R))
