    function [Pmin,Pmax,Emin,Emax,Pbase] = cal_HP_bounds_sum_daily_COP(HPs,temperature)%COP is not constant
    global deltaT T days T_abszero;
    Pmin = zeros(T,days);
    Pmax = zeros(T,days);
    Emin = zeros(T,days);
    Emax = zeros(T,days);
    Pbase = zeros(T,days);
    cutting_temperature = 16;
    for i = 1:length(HPs)
        HP = HPs(i);
        H = HP.H;
        C = HP.C;
        alpha = exp(-deltaT/(C/H));
        P_baseline = zeros(T,days);
        P_slowest = zeros(T,days);
        P_fastest = zeros(T,days);
        %Q_baseline = zeros(T,days);
        %Q_slowest = zeros(T,days);
        Q_fastest = zeros(T,days);
        T_in_slowest = zeros(T+1,days);
        T_in_fastest = zeros(T+1,days);
        T_in_baseline = zeros(T+1,days);
        T_amb = reshape(temperature{HP.idx}.temperature,T,days);
        T_init_min = max([mean([T_amb(:,2:end),T_amb(:,1)]);HP.T_set']);
        T_init_max = max([mean([T_amb(:,2:end),T_amb(:,1)]);HP.T_set']);
        T_init_baseline = max([mean([T_amb(:,2:end),T_amb(:,1)]);HP.T_set']);
        
        T_in_slowest(1,:) = T_init_min;
        T_in_fastest(1,:) = T_init_max;
        T_in_baseline(1,:) = T_init_baseline;
        
        for d = 1:days
            if mean(T_amb(:,d))<=cutting_temperature

            for t = 1:T
                T_HK = HP.k_HK*(T_amb(t,d)-T_abszero)+HP.b_HK;
                T_HP = min(HP.T_HP_max,T_HK);
                coef = HP.COP_coef;
                T_in_slowest(t+1,d) = alpha*(T_in_slowest(t,d)-T_abszero)+(1-alpha)*(T_amb(t,d)-T_abszero)+T_abszero;
                if T_in_slowest(t+1,d) < HP.Tmin(d)
                    T_in_slowest(t+1,d) = HP.Tmin(d); 
                    Q_required = HP.H*((T_in_slowest(t+1,d)-T_abszero-alpha*(T_in_slowest(t,d)-T_abszero))/(1-alpha)-(T_amb(t,d)-T_abszero));
                    %Q_slowest(t,d) = 1;
                    if HP.type == 2
                        DT = T_HP - (HP.T_source+normrnd(0,0.3));
                    else
                        DT = T_HP-T_amb(t,d); %sink - source sink is T_HP
                    end
                    COP = abs(coef(1)+coef(2)*DT+coef(3)*DT^2)+1e-8;
                    %P_required = Q_required/COP;
                    if Q_required>HP.P_r
                        P_slowest(t,d) = HP.P_r/COP;
                        Q_input = HP.P_r;
                        T_in_slowest(t+1,d) = alpha*(T_in_slowest(t,d)-T_abszero)+...
                            (1-alpha)*(T_amb(t,d)-T_abszero+Q_input/H)+T_abszero;
                    else
                        P_slowest(t,d) = Q_required/COP;
                    end
                end
                
                T_in_baseline(t+1,d) = alpha*(T_in_baseline(t,d)-T_abszero)+(1-alpha)*(T_amb(t,d)-T_abszero)+T_abszero;
                if T_in_baseline(t+1,d) < HP.T_set(d)
                    T_in_baseline(t+1,d) = HP.T_set(d); 
                    Q_required = HP.H*((T_in_baseline(t+1,d)-T_abszero-alpha*(T_in_baseline(t,d)-T_abszero))/(1-alpha)-(T_amb(t,d)-T_abszero));
                    if HP.type == 2
                        DT = T_HP - (HP.T_source+normrnd(0,0.3));
                    else
                        DT = T_HP-T_amb(t,d); %sink - source sink is T_HP
                    end
                    COP = coef(1)+coef(2)*DT+coef(3)*DT^2;
                    %P_required = Q_required/COP;
                    if Q_required>=HP.P_r
                        P_baseline(t,d) = HP.P_r/COP;
                        Q_input = HP.P_r;
                        T_in_baseline(t+1,d) = alpha*(T_in_baseline(t,d)-T_abszero)+...
                            (1-alpha)*(T_amb(t,d)-T_abszero+Q_input/H)+T_abszero;
                    else
                        P_baseline(t,d) = Q_required/COP;
                    end
                    %P_baseline(t,d) = Q_baseline(t,d)/COP;
                end
    
                if HP.type == 2
                    DT = T_HP - (HP.T_source+normrnd(0,0.3));
                else
                    DT = T_HP-T_amb(t,d); %sink - source sink is T_HP
                end
                COP = coef(1)+coef(2)*DT+coef(3)*DT^2;
                Q_fastest(t,d) = HP.P_r;
                P_fastest(t,d) = Q_fastest(t,d)/COP;
                T_in_fastest(t+1,d) = alpha*(T_in_fastest(t,d)-T_abszero)+(1-alpha)*(T_amb(t,d)-T_abszero+Q_fastest(t,d)/H)+T_abszero;
                if T_in_fastest(t+1,d)>HP.Tmax(d)
                    T_natural = alpha*(T_in_fastest(t,d)-T_abszero)+(1-alpha)*(T_amb(t,d)-T_abszero)+T_abszero;
                    if T_natural>HP.Tmax(d)
                        T_in_fastest(t+1,d) = T_natural;
                        P_fastest(t,d) = 0;
                    else
                        T_in_fastest(t+1,d) = HP.Tmax(d);
                        Q_fastest(t,d) = HP.H*((T_in_fastest(t+1,d)-T_abszero-alpha*(T_in_fastest(t,d)-T_abszero))/(1-alpha)-(T_amb(t,d)-T_abszero));
%                         if HP.type == 2
%                             DT = T_HP - (HP.T_source+normrnd(0,0.3));
%                         else
%                             DT = T_HP-T_amb(t,d); %sink - source sink is T_HP
%                         end
%                         COP = coef(1)+coef(2)*DT+coef(3)*DT^2;
                        P_fastest(t,d) = Q_fastest(t,d)/COP;
                    end
                end
            end
            end
        end
            

        UP = HP.P_r/HPs(i).COP*deltaT*ones(T,days);
        LP = zeros(T,days);
        LE = cumsum(P_slowest)*deltaT; 
        UE = cumsum(P_fastest)*deltaT; 
        Pmin = Pmin+LP;
        Pmax = Pmax+UP;
        Emin = Emin+LE;
        Emax = Emax+UE;
        Pbase = Pbase+P_baseline;
    end
end