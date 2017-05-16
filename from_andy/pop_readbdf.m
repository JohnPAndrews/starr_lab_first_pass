% pop_readbdf() - Read Biosemi 24-bit BDF file 
%
% Usage:
%   >> EEG = pop_readbdf;             % an interactive window pops up
%   >> EEG = pop_readbdf( filename ); % no pop-up window 
%
% Inputs:
%   filename       - Biosemi 24-bit BDF file 
%
% Optional input:
%   range          - [min max] integer range of data blocks to import.
% 
% Outputs:
%   EEG            - EEGLAB data structure
%
% Author: Arnaud Delorme, CNL / Salk Institute, 13 March 2002
%
% See also: openbdf(), readbdf()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 13 March 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% programmed from pop_readedf() version 1.15

% $Log: pop_readbdf.m,v $
% Revision 1.5  2003/11/04 01:22:40  arno
% removing warnings
%
% Revision 1.4  2003/10/13 17:42:44  arno
% fix blockrage
%
% Revision 1.3  2003/10/10 17:11:12  arno
% fixing default arg
%
% Revision 1.2  2003/08/29 18:44:16  arno
% adding gui for block range
%
% Revision 1.1  2003/06/05 15:38:44  arno
% Initial revision
%

function [EEG, command] = pop_readbdf(filename, blockrange); 
EEG = [];
command = '';

if nargin < 2
    blockrange = [];
end;

if nargin < 1 
	% ask user
	[filename, filepath] = uigetfile('*.BDF;*.bdf', 'Choose an BDF file -- pop_readbdf()'); 
    drawnow;
    
	if filename == 0 return; end;
	filename = [filepath filename];
    
    promptstr    = { 'Data block range to read (default all [1 Inf])' };
    inistr       = { '' };
    result       = inputdlg2( promptstr, 'Import BDF file -- pop_readbdf()', 1,  inistr, 'pop_readbdf');
    if length(result) == 0 return; end;
    blockrange   = eval( [ '[' result{1} ']' ] );
end;

% load datas
% ----------
EEG = eeg_emptyset;
fprintf('Reading BDF, 24 bits format...\n');
dat = openbdf(filename);
if isempty(blockrange)
    blockrange = [1 dat.Head.NRec];
end;
vectrange = [blockrange(1):min(blockrange(2), dat.Head.NRec)];
DAT=readbdf(dat,vectrange);
EEG.nbchan          = size(DAT.Record,1);
EEG.srate           = dat.Head.SampleRate(1);
EEG.data            = DAT.Record;
EEG.pnts            = size(EEG.data,2);
EEG.trials          = 1;
EEG.setname 		= 'BDF file';
disp('Event information might be encoded in the last channel');
disp('To extract these events, use menu File > Import event info > From data channel'); 
EEG.filename        = filename;
EEG.filepath        = '';
EEG.xmin            = 0; 

EEG = eeg_checkset(EEG);
if ~isempty(blockrange)
    command = sprintf('EEG = pop_readbdf(''%s'');', filename); 
else
    command = sprintf('EEG = pop_readbdf(''%s'', [%d %d]);', filename, blockrange(1), blockrange(2)); 
end;

return;