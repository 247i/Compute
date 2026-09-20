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


function res = fl_intersect(A, B, T = "min")
## -*- texinfo -*-
## @deftypefn{Function File} {@var{res} = } fl_intersect(@var{A}, @var{B})
## @deftypefnx{Function File} {@var{res} = } fl_intersect(@var{A}, @var{B}, @var{T})
##
## Returns the Fuzzy Logic intersection. @var{A} and @var{B} must be both row vectors or both column vectors.
##
## The argument @var{T} allows to specify a custom T-Norm function. So it can be:
## @itemize @minus
## @item 'min': use the minimum T-Norm (same as fl_intersect(@var{A},@var{B}));
## @item 'prod': use the product T-Norm;
## @item function_handle: a user-defined function as T-Norm.
## @end itemize
##
## Note that only minimum and product T-Norm will be calculated rapidly and in 
## multithread mode. Using a user-defined function as T-Norm will result 
## in a long time calculation.
## @end deftypefn


	% Check the argument number and type
	if (!(nargin == 2 || nargin == 3))
		print_usage();
	endif
	if (!(isvector(A) && isvector(B)))
		error ("fl_intersect: expecting vector arguments");
	endif

	% Check dimension compatibility
	if (!(length(A) == length(B)))
		error ("fl_intersect: expecting conformant vector arguments");
	endif

	% Check if both vectors are row vectors or column vectors
	if ((columns(A) >= rows(A)) && (columns(B) >= rows(B)))
		% Calculate the composition function with the custom T-Norm (defalut is min)
		res = transpose(fl_compose(transpose(A), B, true, T));
	elseif ((rows(A) >= columns(A)) && (rows(B) >= columns(B)))
		% Calculate the composition function with the custom T-Norm (defalut is min)
		res = fl_compose(A, transpose(B), true, T);
	else
		error ("fl_intersect: expecting vector arguments to be both column vectors or both row vectors");
	endif
	
endfunction

%!test
%! A = [0.8, 0, 0.9];
%! B = [0.4, 0.9, 0.3];
%! result = fl_intersect(A, B);
%! AB = min(A, B);
%! assert (AB, result, 1E-7)
%! result_prod = fl_intersect(A, B, "prod");
%! AB_prod = A .* B;
%! assert (AB_prod, result_prod, 1E-7)
