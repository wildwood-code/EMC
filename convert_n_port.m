function Pout=convert_n_port(src,dest,Pin,Z)
% CONVERT_N_PORT Convert n-port parameters
%   Pout=CONVERT_N_PORT(src,dest,Pin,Z)
%
%   This function converts n-port parameters from one type to another
%   Valid 2-port parameters: z,y,h,g,abcd,s,t
%   Valid n-port parameters: z,y,s (n>2)
%
%   src, dest = type of parameter ('z', 'y,' 'h', 'g', 'abcd', 's', 't')
%   Pin = array(n,n,:) of the source parameter
%   Z0 = array(1,n) of impedances (required for conversion to, from s or t
%
%   See also: CONVERT_2PORT LOAD_PARAMS SAVE_PARAMS

% Kerry S. Martin, martin@wild-wood.net

narginchk(3,4)

[N,Nc,Np]=size(Pin);

if ~ischar(src) || ~ischar(dest)
    error('src and dest must be character arrays')
end

src = lower(src);
dest = lower(dest);

if (N~=Nc)
    error('parameters must be square matrix')
elseif N<1  % TODO: allow 1x1 for conversion between S and Z,Y
    error('parameters matrix must be at least 2x2')
end

if nargin<4
    % default impedance is 50 ohms
    Z = eye(N)*50;
elseif isvector(Z)
    Nz=length(Z);
    if Nz==1
        Z = Z*eye(N,N);
    elseif Nz==N
        Z = diag(Z);
    else
        error('number of Z0 entries must match dimension of parameter matrix')
    end
else
    error('Z must be a row or column vector')
end


if N==2
    Pout = EMC.convert_2port(src, dest, Pin);
else
    sqrtz = sqrt(Z);
    sqrty = inv(sqrtz);
    eyen = eye(N,N);
    Z = zeros(N,N,Np);
    Pout = zeros(N,N,Np);
    switch src
        case { 'abcd', 'chain', 'h', 'hybrid', 'g', 't', 'transfer' }
            error('parameter type %s is not supported for more than 2 ports', src)

        case { 'z', 'impedance' }
            % Z is the intermediate conversion
            Z = Pin;
            
        case { 'y', 'admittance' }
            % convert y to z
            for i=1:Np
                Z(:,:,i) = inv(Pin(:,:,i));
            end

        case { 's', 'scattering' }
            % convert s to z
            for i=1:Np
                Z(:,:,i) = sqrtz*(eyen+Pin(:,:,i))/(eyen-Pin(:,:,i))*sqrtz;
            end
            
        otherwise
            error('unknown source parameter type %s', src)  
    end
    switch dest
        case { 'z', 'impedance' }
            % Z is the intermediate conversion
            Pout = Z;
            
        case { 'y', 'admittance' }
            % convert z to y
            for i=1:Np
                Pout(:,:,i) = inv(Z(:,:,i));
            end

        case { 's', 'scattering' }
            % convert s to z
            for i=1:Np
                ZZ = sqrty*Z(:,:,i)*sqrty;
                Pout(:,:,i) = (ZZ-eyen)/(ZZ+eyen);
            end
    end
end

% Copyright (c) 2018, Kerry S. Martin, martin@wild-wood.net
