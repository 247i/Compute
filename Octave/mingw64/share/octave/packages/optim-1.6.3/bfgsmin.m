## Copyright (C) 2006 Michael Creel <michael.creel@uab.es>
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

## bfgsmin: bfgs or limited memory bfgs minimization of function
##
## Usage: [x, obj_value, convergence, iters] = bfgsmin(f, args, control)
##
## The function must be of the form
## [value<, derivative>] = f(arg_1, arg_2,..., arg_n)
## By default, minimization is w.r.t. arg_1, but it can be done
## w.r.t. any argument that is a vector. Numeric derivatives are
## used unless analytic derivatives are supplied. See bfgsmin_example.m
## for methods.
##
## Arguments:
## * f: name of function to minimize (string)
## * args: a cell array that holds all arguments of the function
## 	The argument with respect to which minimization is done
## 	MUST be a vector
## * control: an optional cell array of 1-9 elements. If a cell
##   array shorter than 9 elements is provided, the trailing elements
##   are provided with default values. If elements are set to an empty
##   matrix (so that isempty() is true), they are set to the
##   corresponding default values.
## 	* elem 1: maximum iterations  (positive integer, or -1 or Inf for unlimited (default))
## 	* elem 2: verbosity
## 		0 = no screen output (default)
## 		1 = only final results
## 		2 = summary every iteration
## 		3 = detailed information
## 	* elem 3: convergence criterion
## 		1 = strict (function, gradient and param change) (default)
## 		0 = weak - only function convergence required
## 	* elem 4: arg in f_args with respect to which minimization is done (default is first)
## 	* elem 5: (optional) Memory limit for lbfgs. If it's a positive integer
## 		then lbfgs will be use. Otherwise ordinary bfgs is used
## 	* elem 6: function change tolerance, default 1e-12
## 	* elem 7: parameter change tolerance, default 1e-6
## 	* elem 8: gradient tolerance, default 1e-5
##      * elem 9: a boolean, telling if f() returns a second output
##                with the analytic derivative, default false
##
## Returns:
## * x: the minimizer
## * obj_value: the value of f() at x
## * convergence: 1 if normal conv, other values if not
## * iters: number of iterations performed
##
## Example: see bfgsmin_example.m

function [parameter, obj, convergence, iters] = bfgsmin(f, f_args, control)

 	# check number and types of arguments
 	if ((nargin < 2) || (nargin > 3))
    		error("bfgsmin: you must supply 2 or 3 arguments");
    	endif
	if (!ischar(f)) error("bfgsmin: first argument must be string holding objective function name"); endif
	if (!iscell(f_args)) error("bfgsmin: second argument must cell array of function arguments"); endif
	if (nargin > 2)
		if (!iscell(control))
			error("bfgsmin: 3rd argument must be a cell array of 1-9 elements");
		endif
		if (length(control) > 9)
			error("bfgsmin: 3rd argument must be a cell array of 1-9 elements");
		endif
	else control = cell(0, 1);
	endif

	# provide defaults for missing controls
        control = control(:);
        defaults = {-1; # limit on iterations
                     0; # level of verbosity
                     1; # strong (function, gradient and parameter change) convergence required?
                     1; # argument with respect to which minimization is done
                     0; # memory for lbfgs: 0 uses ordinary bfgs
                     1e-10; # tolerance for function convergence
                     1e-6; # tolerance for parameter convergence
                     1e-5; # tolerance for gradient convergence
                     false}; # analytic gradient is returned
        curr_n = length (control);
        def_n = length (defaults);
        control(curr_n + 1 : def_n) = defaults(curr_n + 1 : def_n);
        missing_idx = cellfun ('isempty', control);
        control(missing_idx) = defaults(missing_idx);

	# validity checks on all controls
	tmp = control{1};
	if (((tmp !=Inf) && (tmp != -1)) && (tmp > 0 && (mod(tmp,1) != 0)))
		error("bfgsmin: 1st element of 3rd argument (iteration limit) must be Inf or positive integer");
	endif
	tmp = control{2};
	if ((tmp < 0) || (tmp > 3) || (mod(tmp,1) != 0))
		error("bfgsmin: 2nd element of 3rd argument (verbosity level) must be 0, 1, 2, or 3");
	endif
	tmp = control{3};
	if ((tmp != 0) && (tmp != 1))
		error("bfgsmin: 3rd element of 3rd argument (strong/weak convergence) must be 0 (weak) or 1 (strong)");
	endif
	tmp = control{4};
	if ((tmp < 1) || (tmp > length(f_args)) || (mod(tmp,1) != 0))
		error("bfgsmin: 4th element of 3rd argument (arg with respect to which minimization is done) must be an integer that indicates one of the elements of f_args");
	endif
	tmp = control{5};
	if ((tmp < 0) || (mod(tmp,1) != 0))
		error("bfgsmin: 5th element of 3rd argument (memory for lbfgs must be zero (regular bfgs) or a positive integer");
	endif
	tmp = control{6};
	if (tmp < 0)
		error("bfgsmin: 6th element of 3rd argument (tolerance for function convergence) must be a positive real number");
	endif
	tmp = control{7};
	if (tmp < 0)
		error("bfgsmin: 7th element of 3rd argument (tolerance for parameter convergence) must be a positive real number");
	endif
	tmp = control{8};
	if (tmp < 0)
		error("bfgsmin: 8th element of 3rd argument (tolerance for gradient convergence) must be a positive real number");
	endif

	# check that the parameter we minimize w.r.t. is a vector
	minarg = control{4};
	theta = f_args{minarg};
	theta = theta(:);
	if (!isvector(theta)) error("bfgsmin: minimization must be done with respect to a vector of parameters"); endif
	f_args{minarg} = theta;

	# now go ahead and do the minimization
	[parameter, obj, convergence, iters] = __bfgsmin(f, f_args, control);
endfunction
