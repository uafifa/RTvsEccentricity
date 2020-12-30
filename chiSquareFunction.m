function [chiSquareFit] = chiSquareFunction(xVals, yVals, yErr) 
    xVals = transpose(xVals);
    weights = 1./yErr;
    f = @(x, xPoints, yPoints, w)sum(w.*((yPoints-((xPoints.*x(1))+x(2))).^2));
    optFun = @(x)f(x, xVals, yVals, weights);
    ms = MultiStart;
    OLSFit = polyfit(xVals, yVals, 1);
    chiSquareFit.R = corrcoef(xVals,  yVals);
    guessParams = [OLSFit(1), OLSFit(2)];
    problem = createOptimProblem('fmincon', 'x0', guessParams, ...
        'objective', optFun, 'lb' , [-15, 100], 'ub', [15, 700] );
    params = run(ms,problem,50);
    slope = params(1);
    intercept = params(2);
    chiSquareFit.slope = slope;
    chiSquareFit.intercept = intercept;
%     chi2Val = sum((weights.*((yVals - ((xVals.*slope) + intercept)))).^2);
    chi2Val = optFun(params);
    syms sErr;
    chiSquareFit.chi2Val = chi2Val;
%     slopeErrTemp = solve(sum((weights.*((yVals - ((xVals.*sErr) + intercept)))).^2)...
%         == chi2Val+1 , sErr); 
    slopeErrTemp = solve(f([sErr, intercept],xVals, yVals, weights)...
            == chi2Val+1 , sErr); 
    slopeErr = vpa(slopeErrTemp);
    chiSquareFit.slopeErr = double(slopeErr(2) - slope);
    syms iErr;
%     intErrTemp = solve(sum((weights.*((yVals - ((xVals.*slope) + iErr)))).^2)...
%         == chi2Val+1 , iErr);  
    intErrTemp = solve(f([slope, iErr],xVals, yVals, weights)== chi2Val+1 , iErr); 
    intErr = vpa(intErrTemp);
    chiSquareFit.interceptErr = double(intErr(2)-intercept);
    chiSquareFit.redChiSquare = chi2Val / (length(xVals)-2);
end