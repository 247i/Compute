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

function circle2 = transformCircle3d(circle, tfm)
%TRANSFORMCIRCLE3D Transform a 3D circle with a 3D affine transformation.
%
%   CIRCLE2 = transformPlane3d(CIRCLE, TFM)
%
%   Example
%     circle = [1 1 1 2 45 45 0];
%     tfm = createRotationOz(pi);
%     circle2 = transformCircle3d(circle, tfm);
%     figure('color','w'); hold on; axis equal tight; view(-10,25);
%     xlabel('x'); ylabel('y'); zlabel('z');
%     drawCircle3d(circle,'r'); drawPoint3d(circle(1:3),'r+')
%     drawCircle3d(circle2,'g'); drawPoint3d(circle2(1:3),'g+')
%
%   See also 
%     transforms3d, transformPoint3d, transformVector3d, transformLine3d, 
%     transformPlane3d
%

% ------
% Author: oqilipo
% E-mail: N/A
% Created: 2022-12-03, using MATLAB 9.13.0.2080170 (R2022b) Update 1
% Copyright 2022-2023

parser = inputParser;
addRequired(parser, 'circle', @(x) validateattributes(x, {'numeric'},...
    {'ncols',7,'real','finite','nonnan'}));
addRequired(parser, 'tfm', @isTransform3d);
parse(parser, circle, tfm);
circle = parser.Results.circle;
tfm = parser.Results.tfm;

% Compute transformation from local basis to world basis
initialTfm = localToGlobal3d(circle(1:3), circle(5), circle(6), circle(7));
% Add the additional transformation
newTfm = tfm*initialTfm;

% Convert to Euler angles
[phi, theta, psi] = rotation3dToEulerAngles(newTfm, 'ZYZ');

% Create transformed circle
circle2 = [transformPoint3d(circle(1:3), tfm), circle(4), theta, phi, psi];
