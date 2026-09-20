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

function [ax, varargin] = parseAxisHandle(varargin)
%PARSEAXISHANDLE Parse handle to axis, or return current axis.
%
%   Usage:
%   [ax, varargin] = parseAxisHandle(varargin{:});
%
%   Example
%   parseAxisHandle
%
%   See also 
%     isAxisHandle

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2023-09-05, using Matlab 9.14.0.2206163 (R2023a)
% Copyright 2023 INRAE - BIA Research Unit - BIBS Platform (Nantes)

% varargin can not be empty
if isempty(varargin)
    error('Requires at least one input argument');
end

% extract handle of axis to draw on
var1 = varargin{1};
if isscalar(var1) && ishandle(var1) && strcmp(get(var1, 'type'), 'axes')
    ax = varargin{1};
    varargin(1) = [];
else
    ax = gca;
end
