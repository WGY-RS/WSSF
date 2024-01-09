function f = GuidanceFilter(I, G,  params)
    LineRadius = params.LineRadius; 
    sigmaR = 0.05*sqrt(size(G,3)); 
    sigmaW = params.sigmaW;
    f = BLFilteringGPU(I, G, LineRadius, sigmaR, sigmaW); 

end