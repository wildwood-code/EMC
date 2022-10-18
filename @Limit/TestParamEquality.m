function [tf, val] = TestParamEquality(p1, p2)

if isempty(p1)
    tf = true;
    val = p2;
elseif isempty(p2)
    tf = true;
    val = p1;
elseif ~ischar(p1)
    if p1==p2
        tf = true;
        val = p1;
    else
        tf = false;
        val = [];
    end
elseif strcmp(p1, p2)
    tf = true;
    val = p1;
else
    tf = false;
    val = [];
end