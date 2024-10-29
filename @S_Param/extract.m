function [P1,P2,P3,P4] = extract(obj, spec, n2)
% EXTRACT   Extract RF parameter data from the object to an array
%   P = obj.extract(n1, n2)
%   P = obj.extract(id)
%   [F,P] = obj.extract(n1, n2)
%   [F,P] = obj.extract(id)
%
%    n1, n2 are indices into the parameter set (e.g., 1, 2 for S12)
%    id is an abbreviated index (e.g., 12, '12', or "12", 'S12' for S12)
%    id may be 'A', 'B', 'C', or 'D' to extract ABCD parameter
%
% S_Param extract will extract as an S_Param object if possible
% This differs from the other parameters which extract as data

narginchk(1,3)

if nargin==1 && nargout>1
    % this is a special case for extracting mixed-mode parameters
    % [Sdd, Sdc, Scd, Scc] = obj.extract()
    if obj.is_mixed
        if obj.is_legacy
            % extract the 2-port mixed-mode S-parameters
            P1 = EMC.S_Param(obj.Freq,obj.Data([1 3],[1 3],:),obj.Impedance,obj.FScale);
            P2 = EMC.S_Param(obj.Freq,obj.Data([1 3],[2 4],:),obj.Impedance,obj.FScale);
            if nargout>=3
                P3 = EMC.S_Param(obj.Freq,obj.Data([2 4],[1 3],:),obj.Impedance,obj.FScale);
            end
            if nargout>=4
                P4 = EMC.S_Param(obj.Freq,obj.Data([2 4],[2 4],:),obj.Impedance,obj.FScale);
            end
        else
            % extract the 2-port mixed-mode S-parameters
            P1 = EMC.S_Param(obj.Freq,obj.Data([1 2],[1 2],:),obj.Impedance,obj.FScale);
            P2 = EMC.S_Param(obj.Freq,obj.Data([1 2],[3 4],:),obj.Impedance,obj.FScale);
            if nargout>=3
                P3 = EMC.S_Param(obj.Freq,obj.Data([3 4],[1 2],:),obj.Impedance,obj.FScale);
            end
            if nargout>=4
                P4 = EMC.S_Param(obj.Freq,obj.Data([3 4],[3 4],:),obj.Impedance,obj.FScale);
            end
        end
    else
        error('This form of extract() is only valid for mixed-mode S-parameters')
    end
elseif nargin==2 && nargout>1
    error('[Sdd,...] extraction is only valid without spec argument')
elseif nargin==2 && isstring(spec) || ischar(spec)
    if obj.is_mixed
        m = regexp(spec, '^S?([dc]{2})([12]{2})?$', 'ignorecase', 'tokens');
        if ~isempty(m)
            dc = lower(m{1}{1});
            ij = m{1}{2};
            dc_idx = (dc(1)-'c')*2 + dc(2)-'c';  % cc=0, cd=1, dc=2, dd=3

            [Sdd, Sdc, Scd, Scc] = obj.extract(); % recursie call to extract the 4 matrices

            switch dc_idx
                case 0 % cc
                    Smm = Scc;
                case 1 % cd
                    Smm = Scd;
                case 2 % dc
                    Smm = Sdc;
                case 3 % dd
                    Smm = Sdd;
            end

            if isempty(ij)
                % Sdc format - extract whole matrix
                P1 = Smm;
            else
                % Sdcij format - extract one parameter
                i = str2double(ij(1)); j = str2double(ij(2));
                P1 = EMC.S_Param(Smm.Freq,Smm.Data(i,j,:),Smm.Impedance,Smm.FScale);
            end
        else
            error('Unrecognized spec. Must have form Sdcij.')
        end
    else
        m = regexp(spec, '^S?([1-9]{2})$', 'tokens');
        if ~isempty(m)
            ij = m{1}{1};
            i = str2double(ij(1)); j = str2double(ij(2));
            P1 = EMC.S_Param(obj.Freq,obj.Data(i,j,:),obj.Impedance,obj.FScale);
            % TODO: future improvement - when extracting a single element,
            % name it with the extracted i,j
            % for example, S23 = S('S23'); S23.plot() labels as 'S23' not 'S11'
        else
            error('Unrecognized spec. Must have form Sij')
        end

    end
else
    % send to RF_Param extract
    if nargin==2
        var = { spec };
    else
        var = { spec, n2 };
    end

    P1 = extract@EMC.RF_Param(obj, var{:});
end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net