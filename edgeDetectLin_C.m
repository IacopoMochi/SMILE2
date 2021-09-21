function [p,bb2] = edgeDetectLin_C(app,x,edge)

        threshold = app.ThresholdEditField.Value; 
        x = [x(:) ones(length(edge),1)];
        bb2 = x\edge';
        p = (threshold-bb2(2))/bb2(1);
        