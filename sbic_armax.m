function [p_star,q_star] = sbic_armax(y,X,options,p_max,q_max)

[parameters, stderrors, LLF, ht, resids, summary] = garch1(y, 'GARCH', 'GAUSSIAN', 0, 0, X, 0, 0, 0, [], options);


sbic_min = summary.BIC;
p_star = 0;
q_star = 0;


for p = 0:p_max
    for q = 0:q_max
        [parameters, stderrors, LLF, ht, resids, summary] = garch1(y, 'GARCH', 'GAUSSIAN', p, q, X, 0, 0, 0, [], options);
        if summary.BIC < sbic_min
            sbic_min = summary.BIC;
            p_star = p;
            q_star = q;
        end
        if p==q
            fprintf('\n%d\n',p)
        end
    end
end

end

