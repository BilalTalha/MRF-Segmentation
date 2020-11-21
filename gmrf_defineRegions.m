function mrf = gmrf_defineRegions(params, mrf)

    % Initialize an empty cell to store the rectangles
    rects=cell(1,params.NumOfClasses);

    % For every class, define a region using two points
    for ind=1:params.NumOfClasses
        if params.usePredefinedRegions
            p1 = params.regions(1:2, ind);
            p2 = params.regions(3:4, ind);
        else
            tmp = ginput(2);
            p1 = tmp(1,:); 
            p2 = tmp(2,:);
        end
        
        r.y1=round(min(p1(2),p2(2)));
        r.y2=round(max(p1(2),p2(2)));
        r.x1=round(min(p1(1),p2(1)));
        r.x2=round(max(p1(1),p2(1)));
        rects{ind}=r;

        % show the region boundary as a rectangle
        rectangle('Position', [r.x1 r.y1 r.x2-r.x1 r.y2-r.y1], 'LineWidth',1,'EdgeColor','r')
    end

    % For every class, compute the Gaussian distribution describing the
    % selected region
    for ind=1:params.NumOfClasses
        % ====================================== %
        %                                        %
        %    Please, put your implementation     %
        %             BELOW THIS LINE            %
        %                                        %
        % ====================================== %
        corner = rects{ind};
        crop = params.InputImage(corner.y1:corner.y2, corner.x1:corner.x2);
        mu = mean(double(crop(:)));
        sigma = std(double(crop(:)));
        mrf.gauss_params{ind}.mean = mu;
        mrf.gauss_params{ind}.dev = sigma;
        
        normal_pdf = normpdf(double(params.InputImage), mrf.gauss_params{ind}.mean, mrf.gauss_params{ind}.dev);
        
        mrf.logProbs{ind} = -log(normal_pdf);
        
        % ====================================== %
        %                                        %
        %    Please, put your implementation     %
        %             ABOVE THIS LINE            %
        %                                        %
        % ====================================== %       
        
    end

    % Also, copy the constants defined in params to the GMRF model:
    mrf.Beta        = params.Beta;
    mrf.DeltaUmin   = params.DeltaUmin;
    mrf.T0          = params.T0;
    mrf.c           = params.c;
    
    mrf.imagesize   = size(params.InputImage);
    
    mrf.InitMethod  = params.InitMethod;
    mrf.OptiMethod  = params.OptiMethod;
    
end