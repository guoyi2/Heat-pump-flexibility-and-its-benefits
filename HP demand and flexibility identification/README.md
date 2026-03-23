# Swiss Building Heat Pump Flexibility Analysis

This project calculates the flexibility bounds of building heat pumps (HP) across Swiss cantons.

## Project Structure

```
code-share/
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

## How to Run

### 1. Requirements
- MATLAB R2020a or later

### 2. Run the Main Program
1. Open MATLAB
2. Change the working directory to `Gen_building_bounds_ch`
3. Run `main_cantonly.m`

```matlab
cd Gen_building_bounds_ch
main_cantonly
```

### 3. How to Modify the Canton

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

### 4. How to Modify Data Rows (Testing/Partial Data Processing)

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

## Input Data Format

### Building Data CSV Files
Located in `data/buildings/buildings_info_ch/projection/original_info/`, one CSV file per canton.

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

### Temperature Data
- File: `data/temperatures/temperature_ch/CH_2021_real.mat`
- Format: MATLAB cell array containing hourly temperature data for each station

## Output Results

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

## Core Algorithm

### cal_HP_bounds_sum_daily_COP.m
This function calculates heat pump flexibility bounds, considering:
- **Variable COP**: Dynamically calculates coefficient of performance based on ambient temperature
- **Heat Pump Types**:
  - ASHP (Air-Source Heat Pump): COP coefficients `[5.06, -0.04, 0.00006]`
  - GSHP (Ground-Source Heat Pump): COP coefficients `[10.18, -0.18, 0.0008]`
- **Three Operating Modes**:
  - `P_slowest`: Slowest charging (minimum power)
  - `P_baseline`: Baseline operation
  - `P_fastest`: Fastest charging (maximum power)

## FAQ

**Q: File not found error?**
A: Ensure MATLAB working directory is in the `Gen_building_bounds_ch` folder, or use absolute paths.

**Q: Out of memory?**
A: Use `opts.DataLines = [2, 1000]` to reduce data size for testing.

**Q: How to add a new canton?**
A: Add the corresponding CSV file to `data/buildings/buildings_info_ch/projection/original_info/` and add the canton code to the `cantons` variable.
