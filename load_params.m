function [F,P,TYPE,IMP,N] = load_params(filename)
% LOAD_PARAMS  Load network parameters from a data file
%   [F,P,TYPE,IMP,N] = LOAD_PARAMS(filename)
%     filename = string filename to load
%     F        = output frequency vector F(L,1)         L = number of freqs
%     P        = ouput network parameter P(N,N,L)       N = number of ports
%     TYPE     = type of parameters (SYZHG)
%     IMP      = source/load impedance in Ohms
%     N        = output number of ports
%
%   Loads the network parameters from the Touchstone v1.1 format
%   network parameter file (suffix .s#p where # is the # of ports)
%   or from an LTspice data file (suffix .txt)
%
%   See also: SAVE_PARAMS CONVERT_2PORT CONVERT_N_PORT

% History:
%   2018.09.18  KSM  Corrected dB conversion
%   2024.10.27  KSM  Added ability to read LTspice files
%                    Moved touchstone-specific to load_touchstone_params.m

type = EMC.detect_file_type(filename);

switch lower(type)
    case 'touchstone'
        [F,P,TYPE,IMP,N] = EMC.load_touchstone_params(filename);
    case 'ltspice'
        [F,P,TYPE] = EMC.read_ltspice_param_txt_file(filename);
        IMP = 50;  % TODO: this is not known from the file.
        N = 2;
    otherwise
        error('Unknown file format')
end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net