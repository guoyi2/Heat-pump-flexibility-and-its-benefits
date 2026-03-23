## Impacts and benefits of electrified space heating on renewable-based power systems

## Overview
We develop a bottom-up, building-by-building modeling framework to quantify future HP electricity demand and
assess its flexibility potential for power system operation from 2021 to 2050. The code package is structured into two major modules:

- **HP demand and flexibility identification**  
    Simulates hourly heat pump (HP) electricity consumption for individual buildings; Calculates hourly HP demand and flexibility bounds from building construction data and hourly ambient temperature trajectories.

- **data and results**  
    Performs data analysis and results visualization on HP electricity consumption, HP demand flexibility, Impact of social acceptance and building archetypes, Impact on power systems, and HP flexibility for power systems.

## Module 1: HP demand and flexibility identification
This block calculates the HP hourly demand and flexibility bounds based on the building construction dataset and hourly ambient temperature trajectories. 

### The structure of this folder is
    ```
    HP demand and flexibility identification/
    ├── Gen_building_bounds_ch/          # MATLAB code folder
    │   ├── main_cantonly.m              # Main program entry
    │   ├── cal_HP_bounds_sum_daily_COP.m # Core calculation function
    │   └── gen_HP_params.m              # Generate heat pump parameters
    ├── data/
    │   ├── buildings/
    │   │   ├── buildings_info_ch/
    │   │   │   └── projection/
    │   │   │       └── original_info/   # Building data CSV files per canton
    │   │   └── building_configuration/   # Building configuration Excel files
    │   │       ├── new_buildings_per_year.xlsx
    │   │       ├── Populations.xlsx
    │   │       ├── retrofit_plan.xlsx
    │   │       ├── RLC_parameters.xlsx
    │   │       └── temperature_range.xlsx
    │   └── temperatures/
    │       └── temperature_ch/
    │           └── CH_2021_real.mat      # Swiss 2021 temperature data
    ├── results/
    │   └── canton flexibility data/      # Output results (.mat files)
    └── README.md
    ```
### How to Run

#### 1. Requirements
- MATLAB R2020a or later

#### 2. Run the Main Program
1. Open MATLAB
2. Change the working directory to `Gen_building_bounds_ch`
3. Run `main_cantonly.m`

```matlab
cd Gen_building_bounds_ch
main_cantonly
```

#### 3. How to Modify the Canton

Find the `cantons` variable at line 11 in `main_cantonly.m`:

```matlab
% Current setting (process only AI canton)
cantons = {'AI'};

% Process all 26 cantons (uncomment lines 9-10, comment line 11)
cantons = {'AG', 'AI', 'AR', 'BE', 'BL', 'BS', 'FR', 'GE', 'GL', 'GR', 'JU', 'LU',...
    'NE', 'NW', 'OW', 'SG', 'SH', 'SO', 'SZ', 'TG', 'TI', 'UR', 'VD', 'VS', 'ZG', 'ZH'};

% Process specific cantons
cantons = {'AG', 'BE', 'ZH'};
```

**Canton Codes:**
| Code | Canton | Code | Canton |
|------|--------|------|--------|
| AG | Aargau | AI | Appenzell Innerrhoden |
| AR | Appenzell Ausserrhoden | BE | Bern |
| BL | Basel-Landschaft | BS | Basel-Stadt |
| FR | Fribourg | GE | Geneva |
| GL | Glarus | GR | Graubunden |
| JU | Jura | LU | Lucerne |
| NE | Neuchatel | NW | Nidwalden |
| OW | Obwalden | SG | St. Gallen |
| SH | Schaffhausen | SO | Solothurn |
| SZ | Schwyz | TG | Thurgau |
| TI | Ticino | UR | Uri |
| VD | Vaud | VS | Valais |
| ZG | Zug | ZH | Zurich |

#### 4. How to Modify Data Rows (Testing/Partial Data Processing)

Find the `opts.DataLines` setting at line 19 in `main_cantonly.m`:

```matlab
% Default: read all data (from row 2 to end of file)
opts.DataLines = [2, inf];

% Test mode: read only first 100 rows
opts.DataLines = [2, 100];

% Read only first 1000 rows
opts.DataLines = [2, 1000];
```

**Note:** In `[2, inf]`, `2` means starting from row 2 (skip CSV header), and `inf` means read until end of file.

#### Input Data Format

***Building Data CSV Files***
Located in `data/buildings/buildings_info_ch/projection/original_info/`, one CSV file per canton.

*Note that only a limited subset of the building data is provided here to illustrate the calculation procedure. The full analysis spans all 1.8 million buildings in Switzerland and considers multiple heat pump deployment, building retrofit, and climate mitigation scenarios. Each scenario requires a complete building dataset, leading to a total data volume of up to hundreds of gigabytes. Therefore, for review purposes, we include only the data for one scenaior (building information in 2021) in this package. We are ready to make the full building datasets for all considered scenarios publicly available as part of this submission.*

**Key Fields:**
| Field | Description |
|-------|-------------|
| HBLD | Building heat loss coefficient (H) |
| CBLD | Building thermal capacity (C) |
| HHTR | Heating system design heat load |
| THKM8 | Design heating temperature (at -8°C) |
| THK15 | Design heating temperature (at 15°C) |
| QRTnew | Rated heating power |
| TMPIDX | Temperature station index |
| ISHP | Has heat pump (1=yes) |
| ISRSD | Is residential building |
| ISRTF | Is retrofitted building |
| HPTYP | Heat pump type (1=ASHP air-source, 2=GSHP ground-source) |
| TSN | Temperature station number |
| GBAUJ | Year of construction |

#### Temperature Data
- File: `data/temperatures/temperature_ch/CH_2021_real.mat`
- Format: MATLAB cell array containing hourly ambient temperature data for all weather measurement station in Switzerland.

### Output Results

Results are saved in `results/canton flexibility data/`, one `.mat` file per canton.

**Output Variables (Flexibilities struct):**
| Field | Description | Unit |
|-------|-------------|------|
| N_buildings | Total number of buildings | - |
| N_HPs | Number of heat pumps | - |
| Pmin | Minimum power | GW |
| Pmax | Maximum power | GW |
| Emin | Minimum energy | GWh |
| Emax | Maximum energy | GWh |
| Pbase | Baseline power | GW |

### Output Dimensions

The power and energy matrices have the following dimensions:

| Variable | Dimensions | Description |
|----------|------------|-------------|
| Pmin, Pmax | 24 × 365 | Hourly power bounds for each hour of the year |
| Pbase | 24 × 365 | Hourly baseline power for each hour of the year |
| Emin, Emax | 24 × 365 | Cumulative energy bounds for each hour of the year |

**Where:**
- **24** = Number of hours per day (T = 24, set in `main_cantonly.m` line 6)
- **365** = Number of days per year (calculated from temperature data length)

**Matrix Structure:**
```
         Day 1  Day 2  Day 3  ...  Day 365
Hour 1   [1,1]  [1,2]  [1,3]  ...  [1,365]
Hour 2   [2,1]  [2,2]  [2,3]  ...  [2,365]
...       ...    ...    ...   ...    ...
Hour 24 [24,1] [24,2] [24,3]  ... [24,365]
```

**Interpretation:**
- `Pmin(t, d)` = Minimum power bound at hour t of day d
- `Pmax(t, d)` = Maximum power bound at hour t of day d
- `Pbase(t, d)` = Baseline power (normal operation) at hour t of day d
- `Emin(t, d)` = Cumulative minimum energy from start of day d up to hour t
- `Emax(t, d)` = Cumulative maximum energy from start of day d up to hour t

### Core Algorithm

#### cal_HP_bounds_sum_daily_COP.m
This function calculates heat pump flexibility bounds, considering:
- **Variable COP**: Dynamically calculates coefficient of performance based on ambient temperature
- **Heat Pump Types**:
  - ASHP (Air-Source Heat Pump): COP coefficients `[5.06, -0.04, 0.00006]`
  - GSHP (Ground-Source Heat Pump): COP coefficients `[10.18, -0.18, 0.0008]`
- **Three Operating Modes**:
  - `P_slowest`: Slowest charging (minimum power)
  - `P_baseline`: Baseline operation
  - `P_fastest`: Fastest charging (maximum power)

### FAQ

**Q: File not found error?**
A: Ensure MATLAB working directory is in the `Gen_building_bounds_ch` folder, or use absolute paths.

**Q: Out of memory?**
A: Use `opts.DataLines = [2, 1000]` to reduce data size for testing.

**Q: How to add a new canton?**
A: Add the corresponding CSV file to `data/buildings/buildings_info_ch/projection/original_info/` and add the canton code to the `cantons` variable.



## Module 2: Output data and results
This folder contains the Jupyter notebooks used to analyse the outputs and generate the figures included in the manuscript, the Extended Data, and the Supplementary Information, which contains the following results:

### Main figures
- `Figure 1.ipynb`
- `Figure 2.ipynb`
- `Figure 3.ipynb`
- `Figure 4.ipynb`

### Extended Data figures
- `Extended Data Figure 2 - Supplementary Figure 6-8.ipynb`
- `Extended Data Figure 3-4.ipynb`
- `Extended Data Figure 5.ipynb`

### Supplementary figures
- `Supplementary Figure 1.ipynb`
- `Supplementary Figure 2.ipynb`
- `Supplementary Figure 3.ipynb`
- `Supplementary Figure 4.ipynb`
- `Supplementary Figure 5.ipynb`

### Software environment
The notebooks were saved with a Python 3 Jupyter kernel. The notebook metadata indicates Python **3.13.5** in the saved environment. To reproduce the figures, the following Python packages are required:

- `jupyter`
- `numpy`
- `pandas`
- `matplotlib`
- `scipy`
- `pathlib`
- `os`
- `datetime`
- `random`

Additional packages required by some notebooks:
- `seaborn`
- `geopandas`
- `shapely`
- `pyproj`
- `mpl_toolkits`

which also are included in `requirement.text`.

### Data requirements
All data required to run the analyses and visualization can be found in the folder `Output_data`. 

*Note that only a limited subset of the simulation results is included in this package due to space constraints. This subset is sufficient to reproduce the plots presented in the manuscript and Supplementary Information. However, we are prepared to publish the complete set of four-year simulation results covering four HP deployment scenarios, three climate change mitigation strategies, six levels of HP control availability, three levels of indoor temperature setpoints, and three levels of indoor temperature ranges, including both the HP demand and flexibility identification results and the power system simulation outputs. In total, these results amount to hundreds of gigabytes of data. For review purposes, we therefore include only the data necessary to reproduce the results presented in this submission.*

### The structure of this folder is

```text
Output data and results/
│
├── Analysis and Visualization/
│   ├── Figure 1.ipynb
│   ├── Figure 2.ipynb
│   ├── Figure 3.ipynb
│   ├── Figure 4.ipynb
│   ├── Extended Data Figure 2 - Supplementary Figure 6-8.ipynb
│   ├── Extended Data Figure 3-4.ipynb
│   ├── Extended Data Figure 5.ipynb
│   ├── Supplementary Figure 1.ipynb
│   ├── Supplementary Figure 2.ipynb
│   ├── Supplementary Figure 3.ipynb
│   ├── Supplementary Figure 4.ipynb
│   ├── Supplementary Figure 5.ipynb
│   ├── Aggregated_flexibility_PROJECTION_per_canton_2021_2050.xlsx
│   └── requirement.txt
│
├── Output_data/
│   ├── power systems results/
|   |   ├──CaseX/
|   |   |   ├── national_generation_and_capacity/
|   |   |   |   ├── 0-national_curtailment_annual_c_ch
|   |   |   |   ├── 0-national_elecprice_annual_c
|   |   |   |   ├── 0-national_elecprice_monthly_c_2050
|   |   |   |   ├── 0-national_generation_annual_twh_c_ch
|   |   |   |   ├── 0-national_generation_hourly_gwh_c_ch_2050
|   |   |   |   ├── 0-systemcosts_percosttype_5_an
|   |   |   |   ├── 0-systemcosts_trading_5_an
|   |   |   |   ├── 0-demand_hourly_c_ch_2050
|   |   |   ├── Centlv_2050/
|   |   |   |   ├── 0-CH_exports.csv
|   |   |   |   ├── 0-CH_imports.csv
|   |   |   |   ├── 0-LoadHeatPump_AfterShift_hourly_ALL_LP
│   ├── flexibility_demand_quantification/
|   |   ├──CaseX/
|   |   |   ├── canton flexibility data/
|   |   |   ├── nodal flexibility data/
│   ├── SHP-SWEET EDGE/
│   └── municipalities_result/
│   └── flexibility_temperature_ch_2024_Tset22.0_10000_RCP26_Quant50_Category II.mat
└── README.MD

```

### Power system simulation

Code and data for power systems simulations are available upon request.The details of power system optimization and its assocaited software can be found at (https://nexus-e.org/). Our simulations were running on the ETH Euler (https://docs.hpc.ethz.ch/hardware/). One full scenario run typically requires approximately 5 days of computing time.*

### Figure-to-notebook mapping
The notebooks are named according to the figure(s) they reproduce:

| Notebook | Figures reproduced |
|---|---|
| `Figure 1.ipynb` | Figure 1 in main manuscript |
| `Figure 2.ipynb` | Figure 2 in main manuscript |
| `Figure 3.ipynb` | Figure 3 in main manuscript |
| `Figure 4.ipynb` | Figure 4 in main manuscript |
| `Extended Data Figure 2 - Supplementary Figure 6-8.ipynb` | Extended Data Figure 2 in main manuscript and Supplementary Figures 6–8 in supplementary information |
| `Extended Data Figure 3-4.ipynb` | Extended Data Figures 3–4 in main manuscript |
| `Extended Data Figure 5.ipynb` | Extended Data Figure 5 in main manuscript |
| `Supplementary Figure 1.ipynb` | Supplementary Figure 1 in supplementary information |
| `Supplementary Figure 2.ipynb` | Supplementary Figure 2 in supplementary information |
| `Supplementary Figure 3.ipynb` | Supplementary Figure 3 in supplementary information |
| `Supplementary Figure 4.ipynb` | Supplementary Figure 4 in supplementary information |
| `Supplementary Figure 5.ipynb` | Supplementary Figure 5 in supplementary information |

### How to run
1. Create and activate the Python environment with the required dependencies.
2. Open Jupyter Notebook or JupyterLab.
3. Navigate to `Analysis and Visualization/`.
4. Run the notebook from top to bottom (`Kernel -> Restart & Run All` is recommended).


### Definition of scenarios

| No. of Scenario | Abbr. of Scenarios | Range of Indoor Temperatures | Set-points of the Demand Calculations | HP Deployment Rate | Climate Mitigation Rate | HP Controllability |
|---|---|---|---:|---:|---|---:|
| case1a | HP16RCP26 | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 20% | RCP 2.6 | 100% |
| case1b | HP25RCP26 | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 30% | RCP 2.6 | 100% |
| case1c | HP38RCP26 | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 40% | RCP 2.6 | 100% |
| case1d | HP70RCP26 | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 60% | RCP 2.6 | 100% |
| case1e | HP16RCP45 | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 20% | RCP 4.5 | 100% |
| case1f | HP25RCP45 | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 30% | RCP 4.5 | 100% |
| case1g | HP38RCP45 | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 40% | RCP 4.5 | 100% |
| case1h | HP70RCP45 | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 60% | RCP 4.5 | 100% |
| case1i | HP16RCP85 | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 20% | RCP 8.5 | 100% |
| case1j | HP25RCP85 | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 30% | RCP 8.5 | 100% |
| case1k | HP38RCP85 | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 40% | RCP 8.5 | 100% |
| case1l | HP70RCP85 | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 60% | RCP 8.5 | 100% |
| case2a | Category I | In 2021, all buildings follow Category I; once the residential buildings are renovated, they change to Category I-R. | 22 | 60% | RCP 2.6 | 100% |
| case2b | Category II | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 60% | RCP 2.6 | 100% |
| case2c | Category III | In 2021, all buildings follow Category III; once the residential buildings are renovated, they change to Category III-R. | 22 | 60% | RCP 2.6 | 100% |
| case3a | Category II-a | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 20 | 60% | RCP 2.6 | 100% |
| case3b | Category II-b | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 21 | 60% | RCP 2.6 | 100% |
| case3c | Category II-c | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 22 | 60% | RCP 2.6 | 100% |
| case3d | Category II-d | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 23 | 60% | RCP 2.6 | 100% |
| case4a | Category II-e | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 20 | 60% | RCP 2.6 | 80% |
| case4b | Category II-f | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 20 | 60% | RCP 2.6 | 60% |
| case4c | Category II-g | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 20 | 60% | RCP 2.6 | 40% |
| case4d | Category II-h | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 20 | 60% | RCP 2.6 | 20% |
| case4e | Category II-i | In 2021, all buildings follow Category II; once the residential buildings are renovated, they change to Category II-R. | 20 | 60% | RCP 2.6 | 0% |

*Note: A zero appended to the case name (e.g., `case10`) indicates a power system simulation without HP flexible operation.*


## Contact information

**Cooresponding author:** Yi Guo  
**Organization:** Beijing Institute of Technology  
**Email:** yi.guo@bit.edu.cn; yi.guo@ieee.org  

