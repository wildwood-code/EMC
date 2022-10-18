% S_PARAM  RF Network Scattering (S) parameter class
%
%   S_PARAM is a class for holding S-parameter data
%
%   S_Param Methods:
%     S_Param              - constructor
%     ConvertToMixedMode   - convert to mixed-mode (DM/CM) form
%
%   See also:  RF_PARAM H_PARAM G_PARAM Z_PARAM Y_PARAM ABCD_PARAM T_PARAM
%     
classdef S_Param < EMC.RF_Param
    
    properties (SetAccess = private)
        Impedance       % impedance Zinout or [Zin Zout]
    end
    
    methods

        % -------------------------------
        % S_Param constructor        
        function obj = S_Param(freq, data, Z, unitf, unit)
            % Constructor
            % obj = S_PARAM(freq, data, Z, unitf, unit)
            narginchk(0,5)

            if nargin<5
                unit = 'complex';
            elseif ~ischar(unit)
                error('Unit must be a character vector')
            end
            
            if nargin<4
                unitf = 'Hz';
            elseif ischar(unit)
                [~, unitf] = EMC.RF_Param.check_freq_unit(unitf);
            else
                error('UnitF must be a character vector')
            end
            
            if nargin<1
                data = zeros(1,1,0);
                freq = zeros(1,0);
            elseif nargin<2
                NL = length(freq);
                data = zeros(1,1,NL);
            end
            if nargin<3
                Z = 50.0;
            end
            if ~isreal(Z) || Z<=0
                error('Impedance must be real and >0')
            end
            
            obj@EMC.RF_Param(freq, data, unitf, unit);
            obj.Type = 'S';  % property of superclass
            obj.Impedance = Z;
        end

        %-----------------------------------
        % Convert to Mixed-Mode form
        function [SM_SDD,SDC,SCD,SCC] = ConvertToMixedMode(obj)
            % CONVERTTOMIXEDMODE Convert 4-port S-parameters to Mixed-mode S-parameters
            %   SM = obj.ConvertToMixedMode                 % extract 4-port SM
            %   [SDD,SDC,SCD,SCC] = obj.ConvertToMixedMode  % extract all 4 2-port Sxy
            %   [SDD,~] = obj.ConvertToMixedMode            % extract only SDD
            %
            %   Mixed-mode form includes differential-mode (DM) and
            %   common-mode (CM) parameters and is used for measuring
            %   differential-pair networks using a 4-port VNA.
            %
            %   The network is connected between Port1-Port2 to Port3-Port4
            %     Port1 - Port2 <==NETWORK==> Port3 - Port4
            %
            %   The output S-parameters SM take the form:
            %      [ Sdd11 Sdc11 Sdd12 Sdc12;
            %        Scd11 Scc11 Scd12 Scc12;
            %        Sdd21 Sdc21 Sdd22 Sdc22;
            %        Scd21 Scc21 Scd22 Scc22 ]
            %
            %   Sdd = differential-mode S-parameters
            %   Sdc = CM to DM mode conversion
            %   Scd = DM to CM mode conversion
            %   Scc = common-mode S-parameters
            %
            %   Alternately, the four 2-port mixed-mode S-parameter sets
            %   can be extracted if 2 or more output variables are
            %   specified. The order is [SDD, SDC, SCD, SCC]. If only SDD
            %   is needed, specify a second unused output [SDD,~].
            %
            if obj.nPorts ~= 4
                error('This is only defined for 4-port S-parameters')
            end
            
            M = [1 -1 0 0;1 1 0 0;0 0 1 -1;0 0 1 1]/sqrt(2);
            
            SM = EMC.S_Param(obj.Freq, obj.Data, obj.Impedance, obj.UnitF, obj.Unit);
            
            for i=1:SM.nPoints
                SM.Data(:,:,i) = M*SM.Data(:,:,i)/M;
            end
            
            if nargout<2
                % full 4-port mixed-mode S-parameters
                SM_SDD = SM;
            else
                % extract the 2-port mixed-mode S-parameters
                SM_SDD = EMC.S_Param(SM.Freq,SM.Data([1 3],[1 3],:),SM.Impedance,SM.UnitF,SM.Unit);
                SDC = EMC.S_Param(SM.Freq,SM.Data([1 3],[2 4],:),SM.Impedance,SM.UnitF,SM.Unit);
                if nargout>=3
                    SCD = EMC.S_Param(SM.Freq,SM.Data([2 4],[1 3],:),SM.Impedance,SM.UnitF,SM.Unit);
                end
                if nargout==4
                    SCC = EMC.S_Param(SM.Freq,SM.Data([2 4],[2 4],:),SM.Impedance,SM.UnitF,SM.Unit);
                end
            end
        end
        
    end

end

% Copyright (c) 2018, Kerry S. Martin, martin@wild-wood.net
