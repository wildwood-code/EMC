% RF Tools
%
% Author: Kerry S. Martin, martin@wild-wood.net
%
% This toolbox is freely distributable. Please email me if you find it
% useful as I would like to hear from you.
%
% This toolbox is intended to provide basic network parameter
% functionality, such as the ability to load/save network parameters,
% convert from one type of parameter to another, and extract parameters for
% plotting.
%
%  Classes (Network Parameters):
%    RF_Param         - Base class for all RF parameters
%    H_Param          - Hybrid (H) parameters
%    G_Param          - Inverse hybrid (G) parameters
%    Z_Param          - Impedance (Z) parameters
%    Y_Param          - Admittance (Y) parameters
%    S_Param          - Scattering (S) parameters
%    T_Param          - Scattering transfer (T) parameters
%    ABCD_Param       - Cascade (ABCD) parameters
%
%  Classes:
%    Limit            - Limit Line class
%    Trace            - Spectrum analyzer trace
%    Domains          - enumeration of TimeDomain and FrequencyDomain
%
%  Functions:
%    convert_2port    - convert between different 2-port parameters
%    convert_n_port   - convert between different n-port parameters
%    extract_param    - extract a given parameter from parameters matrix
%    load_params      - load parameters from Touchstone file
%    save_params      - save parameters to Touchstone file
%    SmithChart       - create a Smith chart and plot data on it

% October 2, 2024
% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net