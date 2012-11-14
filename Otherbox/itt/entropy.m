function h = gonientropy(v)

values = unique(v);
numValues = numel(v);
h=0;

for i = values'
    p = numel(find(v==i))/numValues;
    h = h + p*log2(p);
end
h=-h;
    