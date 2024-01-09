function[M,m,phaseCongruency,or]=phasecong(im,nscale,norient)

    sze=size(im);

    if nargin<2
        nscale=3;
    end
    if nargin<3
        norient=6;
    end
    if nargin<4
        noiseMode=1;
    end
    if nargin<5
        minWaveLength=3;
    end
    if nargin<6
        mult=2.0;

    end
    if nargin<7
        sigmaOnf=0.55;



    end
    if nargin<8
        dThetaOnSigma=1.7;



    end
    if nargin<9
        k=3.0;



    end
    if nargin<10
        cutOff=0.4;

    end

    g=10;

    epsilon=.0001;
    thetaSigma=pi/norient/dThetaOnSigma;
    imagefft=single(fft2(im));
    sze=size(imagefft);
    rows=sze(1);
    cols=sze(2);
    zero=single(zeros(sze));
    totalEnergy=zero;
    totalSumAn=zero;

    estMeanE2n=[];
    covx2=zero;
    covy2=zero;
    covxy=zero;

    EnergyV2=zero;
    EnergyV3=zero;

    x=single(ones(rows,1)*(-cols/2:(cols/2-1))/(cols/2));
    y=single((-rows/2:(rows/2-1))'*ones(1,cols)/(rows/2));
    radius=sqrt(x.^2+y.^2);
    radius(round(rows/2+1),round(cols/2+1))=1;
    theta=single(atan2(-y,x));
    sintheta=sin(theta);
    costheta=cos(theta);
    clear x;clear y;clear theta;clear im;


    for o=1:norient

        angl=(o-1)*pi/norient;
        wavelength=minWaveLength;
        sumE_ThisOrient=zero;
        sumO_ThisOrient=zero;
        sumO_ThisOrient1=zero;
        sumAn_ThisOrient=zero;
        Energy_ThisOrient=zero;
        EOArray=single([]);
        ifftFilterArray=single([]);







        ds=sintheta*cos(angl)-costheta*sin(angl);
        dc=costheta*cos(angl)+sintheta*sin(angl);
        dtheta=abs(atan2(ds,dc));
        spread=exp((-dtheta.^2)/(2*thetaSigma^2));

        clear ds;clear dc;clear dtheta;
        for s=1:nscale

            fo=1.0/wavelength;
            rfo=fo/0.5;
            logGabor=exp((-(log(radius/rfo)).^2)/(2*log(sigmaOnf)^2));

            logGabor(round(rows/2+1),round(cols/2+1))=0;
            filter=logGabor.*spread;
            filter=fftshift(filter);
            clear logGabor;
            ifftFilt=real(ifft2(filter))*sqrt(rows*cols);
            ifftFilterArray=single([ifftFilterArray,ifftFilt]);
            clear ifftFilt;

            EOfft=imagefft.*filter;
            EO=single(ifft2(EOfft));
            clear EOfft;
            EOArray=single([EOArray,EO]);
            An=abs(EO);
            sumAn_ThisOrient=single(sumAn_ThisOrient+An);
            sumE_ThisOrient=single(sumE_ThisOrient+real(EO));
            sumO_ThisOrient=single(sumO_ThisOrient+imag(EO));
            if s>1
                sumO_ThisOrient1=single(sumO_ThisOrient1+imag(EO));
            end
            if s==1
                maxSumO=sumO_ThisOrient;
            else
                maxSumO=max(maxSumO,sumO_ThisOrient);
            end
            if s==1
                maxAn=An;
            else
                maxAn=max(maxAn,An);
            end
            if s==1
                EM_n=sum(sum(filter.^2));
            end
            wavelength=wavelength*mult;
            clear An;clear filter;
        end


        XEnergy=sqrt(sumE_ThisOrient.^2+sumO_ThisOrient.^2)+epsilon;
        MeanE=sumE_ThisOrient./XEnergy;
        MeanO=sumO_ThisOrient./XEnergy;
        clear XEnergy;





        for s=1:nscale
            EO=submat(EOArray,s,cols);
            E=real(EO);O=imag(EO);
            Energy_ThisOrient=Energy_ThisOrient+E.*MeanE+O.*MeanO-abs(E.*MeanO-O.*MeanE);
        end
        clear EO;clear E;clear O;clear MeanE;clear MeanO;














        medianE2n=median(reshape(abs(submat(EOArray,1,cols)).^2,1,rows*cols));
        meanE2n=-medianE2n/log(0.5);
        estMeanE2n=[estMeanE2n,meanE2n];
        noisePower=meanE2n/EM_n;
        clear meanE2n;clear medianE2n;clear meanE2n;



        EstSumAn2=zero;
        for s=1:nscale
            EstSumAn2=EstSumAn2+submat(ifftFilterArray,s,cols).^2;
        end

        EstSumAiAj=zero;
        for si=1:(nscale-1)
            for sj=(si+1):nscale
                EstSumAiAj=EstSumAiAj+submat(ifftFilterArray,si,cols).*submat(ifftFilterArray,sj,cols);
            end
        end

        EstNoiseEnergy2=2*noisePower*sum(sum(EstSumAn2))+4*noisePower*sum(sum(EstSumAiAj));

        clear EstSumAn2;
        tau=sqrt(EstNoiseEnergy2/2);
        EstNoiseEnergy=tau*sqrt(pi/2);
        EstNoiseEnergySigma=sqrt((2-pi/2)*tau^2);

        T=EstNoiseEnergy+k*EstNoiseEnergySigma;

        clear EstNoiseEnergy;clear EstNoiseEnergySigma;clear tau;
        clear EstNoiseEnergy2;clear EstSumAiAj;clear noisePower;






        T=T/1.7;
        Energy_ThisOrient=max(Energy_ThisOrient-T,zero);






        width=sumAn_ThisOrient./(maxAn+epsilon)/nscale;


        weight=1.0./(1+exp((cutOff-width)*g));

        K_weight_1=max(max(weight))-0.1;
        K_weight_2=min(min(weight))-0.1;



        Energy_ThisOrient=weight.*Energy_ThisOrient;
        clear weight;clear width;

        totalSumAn=totalSumAn+sumAn_ThisOrient;
        totalEnergy=totalEnergy+Energy_ThisOrient;


        PC{o}=Energy_ThisOrient./sumAn_ThisOrient;

        covx=PC{o}*cos(angl);
        covy=PC{o}*sin(angl);
        covx2=covx2+covx.^2;
        covy2=covy2+covy.^2;
        covxy=covxy+covx.*covy;


        EnergyV2=EnergyV2+(K_weight_1*cos(angl)*sumO_ThisOrient+K_weight_2*cos(angl)*sumE_ThisOrient);
        EnergyV3=EnergyV3+(K_weight_1*sin(angl)*sumO_ThisOrient+K_weight_2*sin(angl)*sumE_ThisOrient);





        clear sumAn_ThisOrient;clear Energy_ThisOrient;clear sumO_ThisOrient;
        clear sumO_ThisOrient;clear spread;clear EOArray;clear ifftFilterArray;











    end



    covx2=covx2/(norient/2);
    covy2=covy2/(norient/2);
    covxy=4*covxy/norient;
    denom=sqrt(covxy.^2+(covx2-covy2).^2)+epsilon;
    M=(covy2+covx2+denom)/2;
    m=(covy2+covx2-denom)/2;

    phaseCongruency=double(totalEnergy./(totalSumAn+epsilon));


    or=double(atan(EnergyV3./(-EnergyV2)));


    function a=submat(big,i,cols)

        a=big(:,((i-1)*cols+1):(i*cols));

    end
end