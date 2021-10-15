function EsZerosUninterupted = GetUninteruptedZeros(ES)
  EsZerosIndices = find(ES(:,2)<0);
  EsZerosInterupts = find(diff(EsZerosIndices)~=1);
  EsZerosUninterupted = cell(length(EsZerosInterupts)+1,1);
  EsZerosUninterupted{1} = ES(EsZerosIndices(1:EsZerosInterupts(1)),1);
  for ii = 1:length(EsZerosInterupts)-1
    EsZerosUninterupted{ii+1} = ES(EsZerosIndices(EsZerosInterupts(ii)+1:EsZerosInterupts(ii+1)),1);
  end
  EsZerosUninterupted{end} = ES(EsZerosIndices(EsZerosInterupts(end)+1:end),1);
end