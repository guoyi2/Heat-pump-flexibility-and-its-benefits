clear,clc;
load('..\data\temperatures\temperature_ch\CH_2021_real.mat');
global deltaT T days T_abszero;
T_abszero = -273.15;
deltaT = 1;
T = 24;
days = length(temperature{1}.temperature)/T;
month_days = cumsum([31,28,31,30,31,30,31,31,30,31,30,31]);
params.Tmax = 24;
params.Tmax_retrofit = 25;
params.Tmin = 20;
params.Tmin_retrofit  = 20;
params.Tset  = 22;
% cantons = {'AG', 'AI', 'AR', 'BE', 'BL', 'BS', 'FR', 'GE', 'GL', 'GR', 'JU', 'LU',...
%     'NE', 'NW', 'OW', 'SG', 'SH', 'SO', 'SZ', 'TG', 'TI', 'UR', 'VD', 'VS', 'ZG', 'ZH'};
cantons = {'AI'};

temperature0 = temperature;
for i = 1:length(cantons)
    canton = cantons{i}
    temperature = temperature0;
    opts = detectImportOptions(['../data/buildings/buildings_info_ch/projection/original_info/',canton,'.csv']);
    opts.SelectedVariableNames={'HBLD','CBLD','HHTR','THKM8','THK15','QRTnew','TMPIDX','ISHP','ISRSD','HPTYP','TSN','GBAUJ','ISRTF'};
    opts.DataLines = [2,inf];
    building_data = readmatrix(['../data/buildings/buildings_info_ch/projection/original_info/',canton,'.csv'],opts);
    idx_HPs = find(building_data(:,8)==1);
    HPs = gen_HP_params(building_data(idx_HPs,:), params);
    Flexibilities.N_buildings = length(building_data(:,1));
    clear building_data
    
    Flexibilities.N_HPs = length(idx_HPs);
    [Pmin,Pmax,Emin,Emax,Pbase] = cal_HP_bounds_sum_daily_COP(HPs,temperature);
    scalar = 1e-6;%GW/GWH
    Flexibilities.Pmin = Pmin(1,1) * scalar;
    Flexibilities.Pmax = Pmax(1,1) * scalar;
    Flexibilities.Emin = Emin * scalar;
    Flexibilities.Emax = Emax * scalar;
    Flexibilities.Pbase = Pbase * scalar;
    save(['../results/canton flexibility data/',canton,'.mat'],"Flexibilities")
end