### Summary of Project

This is a project for illustrating my ability to identify a chemical compound from a SMILES text string - here, imatinib -
and to use python to determine some pharmacological and other properties of the compound.

My philosophy on writing code is that if the code already is out there, works, and is at least as good as what I would write,
then I should use that code and modify as-needed.

Almost all of the flow for the 2 tasks in the Jupyter notebooks is from [TeachOpenCADD](https://projects.volkamerlab.org/teachopencadd/index.html),
which is an excellent resource.

I demonstrate use of the ChEMBL web client, RDKit, UniProt, and include some nice visualizations from nglview.

There are no unit tests per-se: I do include sanity checks (does the molecule have the right number of atoms?, for example) along
the way.

I have added some code for dealing with a math.log10 ValueException, because there are IC50 values less than zero in the source data and
I wanted to remove those. I also filter-out import warnings, in particular one involving pandas that does not affect performance.

In the end, I present an IC50 value for imatinib with one of many potential tyrosine-protein kinases that could be targets; and illustrate that
the molecule satisfies Lipinski's Rule of 5 for further exploration. There are some very nice graphs that I made use of (radar plots) which
illustrate the compounds that fulfill or violate the Ro5.

### Installation Instructions

0. This does not work on Windows 10, therefore I only guarantee on a Mac (I'm on Monterey 12.6, M2 chipset).
1. Install a fresh version of [Anaconda Navigator](https://www.anaconda.com/).
2. In a terminal window on a Mac, go to where you will clone this repo.
3. Do `git clone https://github.com/toddjm/projects.git`. If this does not work, you should
download the zip file from the projects repo.
4. Change directories so you are in projects/accendero.
5. In Anaconda Navigator, import the file `accendero_env.yaml` in the Environments tab.
6. In Anaconda Navigator Home, you will see accendero_env in the channels window at the top.
7. Launch JupyterLab, making sure that the accendero_env channel is shown as in (6), above.
8. Open both Jupyter notebooks, and run the Data_Acquisition_and_Analysis_IC50 one first. It will take a few minutes to run. Note that you might have to rerun cells 5 and 6 in order for the nglview widget image to render. The second notebook can be run, as it uses data written to disk from the first one.
