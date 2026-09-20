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



function res = fl_cartproduct(A, B, N= "min")
## -*- texinfo -*-
## @deftypefn{Function File} {@var{res} = } fl_cartproduct(@var{A}, @var{B})
## @deftypefnx{Function File} {@var{res} = } fl_cartproduct(@var{A}, @var{B}, @var{N})
##
## Returns the bi-dimensional Fuzzy Logic cartesian product. @var{A} and @var{B} must be both vectors.
## The argument @var{N} allows to specify a custom function. So it can be:
## @itemize @minus
## @item 'min': use the minimum function (same as fl_cartproduct(A,B));
## @item 'prod': use the product function;
## @item 'max': use the maximum function;
## @item 'sum': use the probabilistic sum function;
## @item function_handle: a user-defined function.
## @end itemize
##
## Note that only the predefined functions will be calculated rapidly and in 
## multithread mode. Using a user-defined function will result 
## in a long time calculation.
## @end deftypefn


	% Check the argument number and type
	if (nargin !=2 && nargin !=3)
		print_usage();
	elseif (!(isvector(A) && isvector(B)))
		error("fl_cartproduct: the first two arguments must be vectors");
	endif

	% Transpose the vectors if necessary (the first as column vector and the second as row vector)
	if (rows(A)<columns(A))
		A = A';
	endif
	if(rows(B)>columns(B))
		B = B';
	endif

	res = fl_compose(A,B,N);	

%!test
%! A = [0.2, 0.7, 0.4];
%! B = [0.5, 0.6];
%! result = fl_cartproduct(A, B);
%! AB = [0.2 0.2; 0.5 0.6; 0.4 0.4];
%! assert (AB, result, 1E-7)

endfunction


