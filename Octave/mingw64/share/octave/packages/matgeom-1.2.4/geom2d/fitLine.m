## Copyright (C) 2024 David Legland
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## 
## The views and conclusions contained in the software and documentation are
## those of the authors and should not be interpreted as representing official
## policies, either expressed or implied, of the copyright holders.

function [line, res] = fitLine(varargin)
%LINEFIT Fit a straight line to a set of points.
%
%   LIN = lineFit(X, Y)
%   Computes parametric line minimizing square error of all points (X,Y).
%   Result is a 4*1 array, containing coordinates of a point of the line,
%   and the direction vector of the line, that is  L=[x0 y0 dx dy];
%
%   LIN = lineFit(PTS) 
%   Gives coordinats of points in a single array.
%
%   LIN = lineFit(PT0, PTS);
%   LIN = lineFit(PT0, X, Y);
%   with PT0 = [x0 y0], imposes the line to contain point PT0.
%
%   [LIN, RES] = lineFit(...)
%   Also returns the residual error.
%
%
%   Requires:
%   Optimization toolbox
%
%   See also 
%     lines2d, fitEllipse, polyfit, polyfit2, lsqlin
%

% ------
% Author: David Legland 
% E-mail: david.legland@inrae.fr
% Created: 2004-04-30
% Copyright 2004-2023 INRA - TPV URPOI - BIA IMASTE

%% Extract input arguments
if length(varargin)==1
    % argument is an array of points
    var = varargin{1};
    x = var(:,1);
    y = var(:,2);   
elseif length(varargin)==2
    var = varargin{1};
    if size(var, 1)==1
        var = varargin{2};
        x = var(:,1);
        y = var(:,2);
    else
        % two arguments : x and y
        x = var;
        y = varargin{2};
    end
elseif length(varargin)==3
    % three arguments : ref point, x and y
    x = varargin{2};
    y = varargin{3};
end


%% Main algorithm

% Initializations:
N = size(x, 1);

% main matrix of the problem
X = [x y ones(N,1)];

% conditions initialisations
A = zeros(0, 3);
b = [];
Aeq1 = [1 1 0];
beq1 = 1;
Aeq2 = [1 -1 0];
beq2 = 1;

% disable verbosity of optimisation
opt = optimset('lsqlin');
opt.LargeScale = 'off';
opt.Display = 'off';

% compute line coefficients [a;b;c] , in the form a*x + b*y + c = 0
% using linear regression
% Check for both a=1 and b=1, such that we keep the result with lowest
% residual error
[coef1, res1] = lsqlin(X, zeros(N, 1), A, b, Aeq1, beq1, [], [], [], opt);
[coef2, res2] = lsqlin(X, zeros(N, 1), A, b, Aeq2, beq2, [], [], [], opt);

% choose the regression model with lowest remaining residual error
if res1 < res2
    coef = coef1;
    res = res1;
else
    coef = coef2;
    res = res2;
end


% convert coefficients to [X0 Y0 DX DY] format
line = cartesianLine(coef');
