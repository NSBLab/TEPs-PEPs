# TEPs-PEPs
## Characterizing and minimizing the contribution of sensory inputs to TMS-evoked potentials

Please read our paper, and if you use this code, please cite our paper:

M.Biabani, A.Fornito, T.Mutanen, J.Morrow, N.Rogasch. [Characterizing and minimizing the contribution of sensory inputs to TMS-evoked potentials](https://www.biorxiv.org/content/early/2018/12/09/489864).

This repository provides the code for reproducing a range of analyses on EEG signals recorded in responses to transcranial magnetic stimulation (TMS). The code is divided into two categories:  pre-processing (cleaning) and processing pipelines. The processing pipeline runs a range of analyses to probe the similarities and differences between TMS-evoked potentials (TEPs) and peripherally-evoked potentials (PEPs), at both source and sensor levels. 
Dependencies
 [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php), [TESA](https://nigelrogasch.github.io/TESA/), and [FieldTrip](http://www.fieldtriptoolbox.org/) toolboxes.
 
### Data files
Please create two directories called **Inputs** and **Outputs** in the root directory of this repository.

In order to reproduce data used in this project please download the data from [this figshare repository](https://figshare.com/s/d19e40ed1f02b8ada178) to **Inputs** directory. The data provided here are the results of pre-processing pipeline (at both source and sensor levels). If you require the raw data please contact [Mana Biabani](mailto:mana.biabani@gmail.com).

### Data processing
After retrieving data, all of the processing analyses done for this project can be carried out by running processingPipeline.m. This script is located in Code > processing folder. It takes the clean data from Inputs folder, runs each analysis step and saves the outputs of each step to Outputs folder.

In case of any questions please contact [Mana Biabani](mailto:mana.biabani@gmail.com).
