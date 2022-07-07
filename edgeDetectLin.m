function [leadingEdgeProfiles,trailingEdgeProfiles] = edgeDetectLin(leadingEdges,trailingEdges,Arc,b,threshold)

%Linear fitting

leadingEdgeProfiles = zeros(size(Arc,1),length(leadingEdges));
trailingEdgeProfiles = zeros(size(Arc,1),length(trailingEdges));
for n = 1:length(leadingEdges)
    for m = 1:size(Arc,1)
        s1 = max(leadingEdges(n)-b,1);
        s2 = min(leadingEdges(n)+b,size(Arc,2));
        
        Arcl = Arc(m,s1:s2);
        
        segm = Arcl;
        
        y = segm(:);
        x = s1:s2;
        x = [x(:) ones(length(segm),1)];
        bb = x\y;
        p = (threshold-bb(2))/bb(1);
        %p = p+s1-1;
        leadingEdgeProfiles(m,n) = p;
        %end
        
        s1b = max(trailingEdges(n)-b,1);
        s2b = min(trailingEdges(n)+b,size(Arc,2));
        segm = (Arc(m,s1b:s2b));
        %p = find(segm>threshold,1,'last');
        %if isempty(p)
        %    trailingEdgeProfiles(m,n)=nan;
        %elseif (p == s2b-s1b+1)
        %    trailingEdgeProfiles(m,n)=nan;
        %else
        y = segm(:);
        x = s1b:s2b;
        x = [x(:) ones(length(segm),1)];
        bb2 = x\y;
        p = (threshold-bb2(2))/bb2(1);
        trailingEdgeProfiles(m,n) = p;
        
        %end
%                         disp(bb)
%                         plot(s1:s2b,Arc(m,s1:s2b),s1:s2,Arc(m,s1:s2),'r',...
%                             s1b:s2b,Arc(m,s1b:s2b),'r',s1:s2,bb(1)*(s1:s2)+bb(2),'g',...
%                             s1b:s2b,bb2(1)*(s1b:s2b)+bb2(2),'g')
%                         waitforbuttonpress
    end
end
end