function output = date_format(input)
%Converts dates of format dd.mm.yyyy to YYYY-MM-DD for column cell vector

[T,temp] = size(input);
output = input;

for t = 1:T
    date = input{t};
    day = upper(date(1:2));
    month = upper(date(4:5));
    year = upper(date(7:10));
    out_date = [year '-' month '-' day];
    output{t} = out_date;
end



end

