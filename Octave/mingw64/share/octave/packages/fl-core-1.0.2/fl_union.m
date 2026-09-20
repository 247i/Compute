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


function res = fl_union(A, B, S = "max")
## -*- texinfo -*-
## @deftypefn{Function File} {@var{res} = } fl_union(@var{A}, @var{B})
## @deftypefnx{Function File} {@var{res} = } fl_union(@var{A}, @var{B}, @var{S})
##
## Returns the Fuzzy Logic union. @var{A} and @var{B} must be both row vectors or both column vectors.
##
## The argument @var{S} allows to specify a custom S-Norm function. So it can be:
## @itemize @minus
## @item 'max': use the maximum S-Norm (same as fl_union(@var{A}, @var{B}));
## @item 'sum': use the probabilistic sum S-Norm;
## @item function_handle: a user-defined function as S-Norm.
## @end itemize
##
## Note that only maximum and probabilistic sum S-Norm will be calculated rapidly and in 
## multithread mode. Using a user-defined function as S-Norm will result 
## in a long time calculation.
## @end deftypefn



	% Check the argument number and type
	if (!(nargin == 2 || nargin == 3))
		print_usage();
	endif
	if (!(isvector(A) && isvector(B)))
		error ("fl_union: expecting vector arguments");
	endif

	% Check dimension compatibility
	if (!(length(A) == length(B)))
		error ("fl_union: expecting conformant vector arguments");
	endif

	% Check if both vectors are row vectors or column vectors
	if ((columns(A) >= rows(A)) && (columns(B) >= rows(B)))
		% Calculate the composition function with the custom S-Norm (defalut is max)
		res = transpose(fl_compose(transpose(A), B, true, S));
	elseif ((rows(A) >= columns(A)) && (rows(B) >= columns(B)))
		% Calculate the composition function with the custom S-Norm (defalut is max)
		res = fl_compose(A, transpose(B), true, S);
	else
		error ("fl_union: expecting vector arguments to be both column vectors or both row vectors");
	endif
	
endfunction

%!test
%! A = [0.8, 0, 0.9];
%! B = [0.4, 0.9, 0.3];
%! result = fl_union(A, B);
%! AB = max(A, B);
%! assert (AB, result, 1E-7)
%! result_sum = fl_union(A, B, "sum");
%! AB_sum = 1 - (1-A).*(1-B);
%! assert (AB_sum, result_sum, 1E-7)

