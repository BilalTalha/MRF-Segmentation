function mrf=gmrf_doMMD(mrf)

         cmap = load('MRF_colormap.mat'); % the colormap
            h = mrf.imagesize(1);         % height of the image
            w = mrf.imagesize(2);         % width of the image
         cnum = mrf.classnum;             % number of classes
         beta = mrf.Beta;                 % value of parameter beta
    DeltaUmin = mrf.DeltaUmin;            % value of minimal necessary energy change
            T = mrf.T0;                   % temperature at the begining
            c = mrf.c;                    % the c constant parameter
     

           cycle = 0;
    summa_deltaE = 2 * DeltaUmin; % the first iteration is guaranteed

    while summa_deltaE > DeltaUmin 
        
        % ====================================== %
        %                                        %
        %    Please, put your implementation     %
        %             BELOW THIS LINE            %
        %                                        %
        % ====================================== %
        summa_deltaE = 0; %Set summa_deltaE to zero
        cycle = cycle+1; %Increment the cycle counter
        %For each pixel
        for y = 1:w
            for x = 1:h
                C = mrf.classmask(y, x); %Get the current class label at location (y,x)
                %Get the class label of the 8 (or less) neighboring pixels
                Cn(1) = mrf.classmask(y, max(x-1, 1)); 
                Cn(2) = mrf.classmask(y, min(x+1, w)); 
                Cn(3) = mrf.classmask(max(y-1, 1),x); 
                Cn(4) = mrf.classmask(min(y+1, h),x); 
                Cn(5) = mrf.classmask(max(1, y-1), max(1, x-1)); 
                Cn(6) = mrf.classmask(max(1, y-1), min(w, x+1)); 
                Cn(7) = mrf.classmask(min(h, y+1), max(1, x-1)); 
                Cn(8) = mrf.classmask(min(h, y+1), min(w, x+1)); 
                
                %Get the actual posterior probability
                posterior_prob = mrf.logProbs{C}(y, x);
                
                %Compute the actual prior probability
                prior_prob = 0;
                for i = 1:8 
                    if Cn(i) == C 
                        b = -beta;
                    else 
                        b = beta;
                    end
                    prior_prob = prior_prob + b; 
                end
                
                %Randomly pick a class label
                Rand_C = C;
                while Rand_C == C 
                    Rand_C = ceil(cnum*rand()); 
                end
                
                %Compute the new posterior and prior probabilities
                new_posterior_prob = mrf.logProbs{Rand_C}(y, x);
                new_prior_prob = 0;
                for i = 1:8
                    if Cn(i) == Rand_C
                        b = -beta;
                    else
                        b = beta;
                    end
                    new_prior_prob = new_prior_prob + b;
                end
                %Compute the actual and new energies
                U_act = posterior_prob + prior_prob;
                U_new = new_posterior_prob + new_prior_prob;
                %Compute the energy change
                dU = U_new - U_act;
                %If this gain is less than 0 or the gain is higher than 0 but a random float from the
                %[0,1) interval is smaller than exp(-dU/T), then update:
                  %■ summa_deltaE, increase its value by abs(dU)
                  %■ mrf.classmask(y, x), store the randomly picked label into the class mask
                if dU < 0 || rand() < exp(-dU/T)  
                    summa_deltaE = summa_deltaE + abs(dU);
                    mrf.classmask(y,x) = Rand_C;
                end
            end
            
        end
        %update the temperature (T), multiply it by c and store the new value
        T = c*T;

        % ====================================== %
        %                                        %
        %    Please, put your implementation     %
        %             ABOVE THIS LINE            %
        %                                        %
        % ====================================== %    
        
        imshow(uint8(255*reshape(cmap.color(mrf.classmask,:), h, w, 3)));
        %fprintf('Iteration #%i\n', cycle);
        title(['Class map in cycle ', num2str(cycle)]);
        drawnow;
    end
end
