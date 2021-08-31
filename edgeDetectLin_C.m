function p = edgeDetectLin_C(x,edge,threshold)

        
        x = [x(:) ones(length(edge),1)];
        bb2 = x\edge';
        p = (threshold-bb2(2))/bb2(1);
        