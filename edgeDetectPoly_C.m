function [p,pp1,Mu1] = edgeDetectPoly_C(app,x,edge)

        threshold = app.ThresholdEditField.Value; 
        [pp1,~,Mu1] = polyfit(x,edge,4);
        pp = pp1;
        pp(end)=pp(end)-threshold;
        try
        R1 = roots(pp)*Mu1(2)+Mu1(1);
        catch
            disp('darn')
        end
        R1 = R1(~abs(imag(R1)));
        if ~isempty(R1)
            [~,id] = min(abs(R1-mean(x)));
            R1 = R1(id);
            p = R1;
        else
            p = nan;
        end