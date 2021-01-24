# Prerequisites

The script `facerecognition.m` requires the Mapping toolbox which needs to be installed as MATLAB add-on if not already done so. 

Moreover, the script saves all the generated images in the `images` directory. This `images` directory along with its subdirectories need to be created before running the script. The directory hierarchy is given as follows:

- `images`
    - `performance_plots`
        - `FMR_FNMR_plots`
        - `ROC_plots`
        - `DET_plots`

The script will throw an error if these directories are not already present.
