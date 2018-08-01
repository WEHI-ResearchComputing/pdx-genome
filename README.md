# pdx-genome
Patient derived cancer xenograph genome analysis

1. Trimmomatic palindrome mode with high threshold (20)
2. Mapping paired end local alignment with either bwa-mem or bowtie2 to GRCh38_no_alt and GRCm38 preserving read order and only reporting one alignment per read.
3. Processing the mouse and human alignments with xenomapper (needs only python3 and a samtools binary in the path.  Pip3 installable)
4. Samtools sort and index human reads

Using the human specific reads for:

5. Platypus mutation calling (tumour only)
6. Varscan mutation calling (tumour only)
7. Gridss
8. Annotation of variants with VEP including population variant frequencies (ExAC)

## Instructions
1. Create a new empty directory to hold code, scripts and output
2. Clone this repository: `git clone --recursive https://github.com/WEHI-ResearchComputing/pdx-genome` Note the recursive argument to bring in the common tool definitions.
3. Create a python virtual enviroment to hold the software
    * `module load python`
    * `virtualenv toil-env`
    * `. toil-env/bin/activate`
    * `pip install git+https://github.com/WEHI-ResearchComputing/wehi-pipeline`
4. You should now be able to run the tests against the minimal data in the `pdx-genome/data` directory.
    1. Test with the CWL reference implementation
        * `cd /path/to/pdx-genome`
        * `mkdir test`
        * `cd test`
        * `cwltool ../src/pdx-scatter.cwl ../src/pdx-inp.yml`
    2. Test with Toil. Inspect the `runall.sh` script and make sure the directories are correct. 