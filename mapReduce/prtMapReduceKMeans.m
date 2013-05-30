classdef prtMapReduceKMeans < prtMapReduce
    
    properties
        clusterCenters
    end
    
    methods
        function map = mapFn(self,dataSet)
            proximity = prtDistanceEuclidean(self.clusterCenters,dataSet.X);
            [~,inds] = min(proximity,[],1);
            
            clusterStruct = repmat(struct('sum',[],'counts',[]),1,size(proximity,1));
            for clusterInd = 1:size(proximity,1)
                clusterStruct(1,clusterInd) = struct('sum',sum(dataSet.X(inds == clusterInd,:)),'counts',sum(inds == clusterInd));
            end
            map = clusterStruct;
        end
        
        function reduce = reduceFn(self,maps) %#ok<INUSL>
            mapStructs = cat(1,maps{:});
            
            reduce = nan(size(mapStructs,2),length(mapStructs(1).sum));
            for clusterInd = 1:size(mapStructs,2)
                mean = sum(cat(1,mapStructs(:,clusterInd).sum));
                reduce(clusterInd,:) = mean./sum(cat(1,mapStructs(:,clusterInd).counts));
            end
        end
    end
    
end