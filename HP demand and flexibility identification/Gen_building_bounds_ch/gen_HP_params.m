function HPs = gen_HP_params(building_data, params)
    HPs = [];
    T_HP_max = 55;
    T_abszero = -273.15;
    global days;
    coef_ASHP = [5.06, -0.04, 0.00006];
    coef_GSHP = [10.18, -0.18, 0.0008];
    count=0;
    for i = 1:size(building_data,1)
        building = building_data(i,:);
        if building(8)
            count = count+1;
            HPs(count).H = building(1);
            HPs(count).C = building(2);
            HPs(count).k_HK = (building(4)- building(5))/(-8-15);
            HPs(count).b_HK = building(4)-HPs(count).k_HK*(-8 - T_abszero);
            HPs(count).P_r = building(6);%need data
            if building(13) && building(9)
                HPs(count).Tmax = params.Tmax_retrofit*ones(days,1);
                HPs(count).Tmin = params.Tmin_retrofit*ones(days,1);
            else
                HPs(count).Tmax = params.Tmax*ones(days,1);
                HPs(count).Tmin = params.Tmin*ones(days,1);
            end
            HPs(count).T_set = params.Tset*ones(days,1);%assume T_init=T_set
            % summer_start = 121;
            % summer_end = 270;
            % HPs(count).Tmax(summer_start:summer_end) = 26;
            % HPs(count).Tmin(summer_start:summer_end) = 23;

            
            %HPs(count).T_set = HPs(count).Tmax;
            if building(10)
                HPs(count).COP_coef = coef_ASHP;
                HPs(count).type = 1;%ASHP
                % coef = coef_ASHP;
                % DT = 48;
                % COP = abs(coef(1)+coef(2)*DT+coef(3)*DT^2)+1e-8;
                % 1
            else
                HPs(count).COP_coef = coef_GSHP;
                HPs(count).type = 2;%GSHP
                HPs(count).T_source = 15;%ground temperature

                % coef = coef_GSHP;
                % DT = 34;
                % COP = abs(coef(1)+coef(2)*DT+coef(3)*DT^2)+1e-8;
                % 1
            end
            HPs(count).COP = 3.87;
            HPs(count).T_HP_max = T_HP_max;
            HPs(count).idx = building(7);
            HPs(count).TSN = building(11);
            
        end
    end
end