function [leadingEdgeProfiles,trailingEdgeProfiles] = edgeDetectThreshold(leadingEdges,trailingEdges,Arc,CD,b,threshold)
%linear fitting (no filtering)
leadingEdgeProfiles = zeros(size(Arc,1),length(leadingEdges));
trailingEdgeProfiles = zeros(size(Arc,1),length(trailingEdges));
for n = 1:length(leadingEdges)
    for m = 1:size(Arc,1)
        s1 = max(leadingEdges(n)-round(CD*b),1);
        s2 = min(leadingEdges(n)+round(CD*b),size(Arc,2));
        
        segm = Arc(m,s1:s2);
        
        p = find(segm>threshold,1,'first');
        if isempty(p)
            leadingEdgeProfiles(m,n)=nan;
        else
            p = p+s1-1;
            leadingEdgeProfiles(m,n) = p;
        end
        
        s1b = max(trailingEdges(n)-round(CD*b),1);
        s2b = min(trailingEdges(n)+round(CD*b),size(Arc,2));
        
        segm = Arc(m,s1b:s2b);
        
        p = find(segm>threshold,1,'last');
        if isempty(p)
            trailingEdgeProfiles(m,n)=nan;
        else
            p = p+s1b-1;
            trailingEdgeProfiles(m,n) = p;
        end
        
        %                 disp(bb)
        %                 plot(s1:s2b,Arc(m,s1:s2b),s1:s2,Arc(m,s1:s2),'r',...
        %                     s1b:s2b,Arc(m,s1b:s2b),'r',s1:s2,bb(1)*(s1:s2)+bb(2),'g',...
        %                     s1b:s2b,bb2(1)*(s1b:s2b)+bb2(2),'g')
        %                 waitforbuttonpress
    end
end
end


