function [varargout]=convert_2port(src,dest,varargin)
% CONVERT_2PORT Convert 2-port parameters
%   Pout=CONVERT_2PORT(src,dest,Pin)
%   Pout=CONVERT_2PORT(src,dest,P11,P12,P21,P22)
%   [P11,P12,P21,P22]=CONVERT_2PORT(src,dest,Pin)
%   [P11,P12,P21,P22]=CONVERT_2PORT(src,dest,P11,P12,P21,P22)
%
%   This function converts 2-port parameters from one type to another
%   Valid 2-port parameters: z,y,h,g,abcd,s,t
%
%   valid inputs for Pin, Pout:
%     src   dest   array(2,2) {Z1 {Z2}}
%     src   dest   array(2,2,:) {Z2 {Z2}}
%     src   dest   v11(:) v12(:) v13(:) v14(:) {Z1 {Z2}}
%     src   dest   cell{2,2} {Z1 {Z2}}
%
%   src, dest =
%      abcd z y h g t s (or some equivalent names like scattering)
%
%   See also: CONVERT_N_PORT LOAD_PARAMS SAVE_PARAMS

% Kerry S. Martin, martin@wild-wood.net

narginchk(3,8);

Ptype = [];

if nargin>=3 && nargin<=5
    P = varargin{1};
    if iscell(P)
        if ismatrix(P)   % was ndims(P)==2
            [r,c]=size(P);
            if r==2 && c==2
                Ptype = 'cell';
                P11 = P{1,1};
                P12 = P{1,2};
                P21 = P{2,1};
                P22 = P{2,2};
            end
        end
    elseif ismatrix(P)
        [r,c]=size(P);
        if r==2 && c==2
            Ptype = 'matx';
            P11 = P(1,1);
            P12 = P(1,2);
            P21 = P(2,1);
            P22 = P(2,2);
        end
    elseif ndims(P)==3
        [r,c,e]=size(P);
        if r==2 && c==2 && e>0
            Ptype = '3dim';
            P11 = squeeze(P(1,1,:));
            P12 = squeeze(P(1,2,:));
            P21 = squeeze(P(2,1,:));
            P22 = squeeze(P(2,2,:));
        end
    end
    
    if nargin==4
        Z1 = varargin{2};
        Z2 = Z1;
    elseif nargin==5
        Z1 = varargin{2};
        Z2 = varargin{3};
    else
        Z1 = 50;
        Z2 = 50;
    end
    
elseif nargin>=6 && nargin<=8
    P11 = varargin{1};
    P12 = varargin{2};
    P21 = varargin{3};
    P22 = varargin{4};
    
    if isequal(size(P11),size(P12),size(P21),size(P22)) && isvector(P11)
        Ptype = '4vec';
    end
    
    if nargin==7
        Z1 = varargin{5};
        Z2 = Z1;
    elseif nargin==8
        Z1 = varargin{5};
        Z2 = varargin{6};
    else
        Z1 = 50;
        Z2 = 50;
    end
end

if isempty(Ptype)
    error('Invalid 2-port parameter form');
end

R1 = real(Z1);
R2 = real(Z2);
sR1R2 = sqrt(R1*R2);

src = lower(src);
dest = lower(dest);

% This was the temporary workaround for the T-parameter issue. It may
% be deleted after my corrections have been validated. For now, it is
% commented out.
%     switch src
%         case { 't', 'transfer' }
%             S11 = P21./P11;
%             S12 = (P11.*P22-P12.*P21)./P11;
%             S21 = 1./P11;
%             S22 = -P12./P11;
%             P11 = S11; P12 = S12; P21 = S21; P22 = S22;
%             src = 's';
%     end

% convert all cases of source parameter to hybrid (H-parameters)
switch src
    case { 'abcd', 'chain' }
        h11 = P12./P22;
        h12 = (P11.*P22 - P12.*P21)./P22;
        h21 = -1.0./P22;
        h22 = P21./P22;
        
    case { 'y', 'admittance' }
        h11 = 1./P11;
        h12 = -P12./P11;
        h21 = P21./P11;
        h22 = (P11.*P22-P12.*P21)./P11;
        
    case { 'z', 'impedance' }
        h11 = (P11.*P22-P12.*P21)./P22;
        h12 = P12./P22;
        h21 = -P21./P22;
        h22 = 1./P22;
        
    case  { 'h', 'hybrid' }
        h11 = P11;
        h12 = P12;
        h21 = P21;
        h22 = P22;
        
    case { 'g' }
        det = P11.*P22-P21.*P12;
        h11 = P22./det;
        h12 = -P12./det;
        h21 = -P21./det;
        h22 = P11./det;
        
    case { 's', 'scattering' }
        den = (1-P11).*(conj(Z2)+P22.*Z2) + P12.*P21.*Z2;
        h11 = ((conj(Z1) + P11.*Z1).*(conj(Z2) + P22.*Z2)-P12.*P21.*Z1.*Z2) ./ den;
        h12 = 2.*P12.*sR1R2 ./ den;
        h21 = -2.*P21.*sR1R2 ./ den;
        h22 = ( (1-P11).*(1-P22)-P12.*P21  ) ./ den;
        
    case { 't', 'transfer' }
        % KSM: Something was incorrect in the original source for these
        % equations. The denominator seemed to be incorrect.
        % I worked through these on 1/24/2017 and found the correct
        % solutions, included here.
        % Original source: Frickey, Dean A., "Conversions Between S, Z,
        % Y, h, ABCD, and T Parameters which are Valid for Complex
        % Source and Load Impedances", IEEE Transactions on Microwave
        % Theory and Techniques, Vo. 42. No. 2, February 1994.
        %
        den = conj(Z2)*(P11-P21)+Z2*(P22-P12);
        h11 = (conj(Z2).*(P11.*conj(Z1)+P21.*Z1)-Z2.*(P12.*conj(Z1)+P22.*Z1)  ) ./ den;
        h12 = 2.*sR1R2.*(P11.*P22-P12.*P21) ./ den;
        h21 = -2.*sR1R2 ./ den;
        h22 = ( P11+P12-P21-P22 ) ./ den;
        
end

% convert hybrid (H-Parameters) to the destination parameter
switch dest
    case { 'h', 'hybrid' }
        P11 = h11;
        P12 = h12;
        P21 = h21;
        P22 = h22;
        
    case { 'g' }
        det = h11.*h22-h12.*h21;
        P11 = h22./det;
        P12 = -h12./det;
        P21 = -h21./det;
        P22 = h11./det;
        
    case { 'abcd', 'chain' }
        P11 = (h12.*h21-h11.*h22)./h21;
        P12 = -h11./h21;
        P21 = -h22./h21;
        P22 = -1./h21;
        
    case { 'z', 'impedance' }
        P11 = (h11.*h22-h12.*h21)./h22;
        P12 = h12./h22;
        P21 = -h21./h22;
        P22 = 1./h22;
        
    case { 'y', 'admittance' }
        P11 = 1./h11;
        P12 = -h12./h11;
        P21 = h21./h11;
        P22 = (h11.*h22-h12.*h21)./h11;
        
    case { 't', 'transfer' }
        den = 2.*h21.*sR1R2;
        P11 = ( (-h11-Z1).*(1+h22.*Z2)+h12.*h21.*Z2 ) ./ den;
        P12 = ( (h11+Z1).*(1-h22.*conj(Z2))+h12.*h21.*conj(Z2) ) ./ den;
        P21 = ( (conj(Z1)-h11).*(1+h22.*Z2)+h12.*h21.*Z2 ) ./ den;
        P22 = ( (h11-conj(Z1)).*(1-h22.*conj(Z2))+h12.*h21.*conj(Z2) ) ./ den;
        
    case { 's', 'scattering' }
        den = (Z1+h11).*(1+h22.*Z2)-h12.*h21.*Z2;
        P11 = ( (h11-conj(Z1)).*(1+h22.*Z2)-h12.*h21.*Z2 ) ./ den;
        P12 = 2.*h12.*sR1R2 ./ den;
        P21 = -2.*h21.*sR1R2 ./ den;
        P22 = ( (Z1+h11).*(1-h22.*conj(Z2))+h12.*h21.*conj(Z2) ) ./ den;
end

if nargout==4
    varargout{1} = P11;
    varargout{2} = P12;
    varargout{3} = P21;
    varargout{4} = P22;
elseif nargout==1 || nargout==0
    switch Ptype
        case {'matx'}
            varargout{1} = [P11, P12; P21, P22];
        case {'cell'}
            varargout{1} = { P11, P12; P21, P22 };
        case {'3dim'}
            P(1,1,:) = P11;
            P(1,2,:) = P12;
            P(2,1,:) = P21;
            P(2,2,:) = P22;
            varargout{1} = P;
        case {'4vec'}
            if isscalar(P11)
                varargout{1} = [P11, P12; P21, P22];
            else
                varargout{1} = { P11, P12 ; P21, P22 };
            end
            
    end
end

% Copyright (c) 2018, Kerry S. Martin, martin@wild-wood.net
