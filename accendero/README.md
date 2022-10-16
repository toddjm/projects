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

1. Install a fresh version of Anaconda Navigator on a Mac. I wrote this and ran it on Monterey 12.6, Macbook with M2 chipset.
2. In a terminal window, go to where you will clone this repo. Clone the repo.
3. In the cloned repo (you want to be in projects/accendero), create a new virtual environment:
  `conda create --name <env> --file requirements.txt`
4. If you wish to install packages using `pip`:
  `pip install -r requirements_pip.txt`
