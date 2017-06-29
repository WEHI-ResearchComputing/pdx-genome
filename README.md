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
