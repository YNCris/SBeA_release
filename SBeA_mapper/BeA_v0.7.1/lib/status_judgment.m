function status_key=status_judgment(staus_str)
if isempty(staus_str)
     status_key=0;
else
if staus_str(1)=='Õı'
    status_key=1;
else
    status_key=0;
end
end
end

