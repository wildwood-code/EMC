% IS_DETECTOR  determines if the detector is valid, and returns the
%              standard name for the detector
% [tf,det] = IS_DETECTOR(det)
%
%  standard detectors: pk, qpk, av, npk, samp
function [tf,det] = is_detector(det)

tf = true;

if regexpi(det,'^p(?:ea)?k$')
    det = 'pk';
elseif regexpi(det, '^q(?:uasi)?p(?:ea)?k?$')
    det = 'qpk';
elseif regexpi(det, '^av(?:g|erage)?$')
    det = 'av';
elseif regexpi(det, '^n(?:eg)?p(?:ea)?k?$')
    det = 'npk';
elseif regexpi(det, '^sa(?:mp(?:le)?)?$')
    det = 'samp';
else
    tf = false;
    det = [];
end

if nargout<2
    clear det
end