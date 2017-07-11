#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
- $import: envvar-global.yml
#- $import: samtools-docker.yml
- class: InlineJavascriptRequirement

inputs:
  bamFiles:
    type: File[]
    inputBinding:
      position: 99
    doc: |
      List of input bam files

  illumina1.3:
    type: boolean?
    inputBinding:
      prefix: --illumina1.3+
    doc: |
      -6, --illumina1.3+ Assume the quality is in the Illumina 1.3+ encoding.

  count-orphans:
    type: boolean?
    inputBinding:
      prefix: --count-orphans
    doc: |
      -A, --count-orphans Do not skip anomalous read pairs in variant calling.

  bam-list:
    type: File?
    inputBinding:
      prefix: --bam-list
    doc: |
      -b, --bam-list FILE List of input BAM files, one file per line [null]

  no-BAQ:
    type: boolean?
    inputBinding:
      prefix: --no-BAQ
    doc: |
      -B, --no-BAQ Disable probabilistic realignment for the computation of base alignment quality (BAQ).
      BAQ is the Phred-scaled probability of a read base being misaligned. Applying this option greatly
      helps to reduce false SNPs caused by misalignments.

  adjust-MQ:
    type: int?
    inputBinding:
      prefix: --adjust-MQ
    doc: |
      -C, --adjust-MQ INT Coefficient for downgrading mapping quality for reads containing excessive mismatches.
      Given a read with a phred-scaled probability q of being generated from the mapped position, the new mapping
      quality is about sqrt((INT-q)/INT)*INT. A zero value disables this functionality; if enabled, the recommended
      value for BWA is 50. [0]

  max-depth:
    type: int?
    inputBinding:
      prefix: --max-depth
    doc: |
      -d, --max-depth INT At a position, read maximally INT reads per input file. Note that samtools has a minimum
      value of 8000/n where n is the number of input files given to mpileup. This means the default is highly likely
      to be increased. Once above the cross-sample minimum of 8000 the -d parameter will have an effect. [250]

  redo-BAQ:
    type: boolean?
    inputBinding:
      prefix: --redo-BAQ
    doc: |
      -E, --redo-BAQ Recalculate BAQ on the fly, ignore existing BQ tags

  fasta-ref:
    type: File?
    inputBinding:
      prefix: --fasta-ref
    doc: |
      -f, --fasta-ref FILE The faidx-indexed reference file in the FASTA format. The file can be optionally compressed by bgzip. [null]

  exclude-RG:
    type: File?
    inputBinding:
      prefix: --exclude-RG
    doc: |
      -G, --exclude-RG FILE Exclude reads from readgroups listed in FILE (one @RG-ID per line)

  positions:
    type: File?
    inputBinding:
      prefix: --positions
    doc: |
      -l, --positions FILE BED or position list file containing a list of regions or sites where pileup or BCF should be generated.
      Position list files contain two columns (chromosome and position) and start counting from 1. BED files contain at least 3 columns
      (chromosome, start and end position) and are 0-based half-open.

      While it is possible to mix both position-list and BED coordinates in the same file, this is strongly ill advised due to the
      differing coordinate systems. [null]

  min-MQ:
    type: int?
    inputBinding:
      prefix: --min-MQ
    doc: |
      -q, -min-MQ INT Minimum mapping quality for an alignment to be used [0]

  min-BQ:
    type: int?
    inputBinding:
      prefix: --min-BQ
    doc: |
      -Q, --min-BQ INT Minimum base quality for a base to be considered [13]

  region:
    type: string?
    inputBinding:
      prefix: --region
    doc: |
      -r, --region STR Only generate pileup in region. Requires the BAM files to be indexed. If used in conjunction with -l then
      considers the intersection of the two requests. STR [all sites]

  ignore-RG:
    type: boolean?
    inputBinding:
      prefix: --ignore-RG
    doc: |
      -R, --ignore-RG Ignore RG tags. Treat all reads in one BAM as one sample.

  incl-flags:
    type: string?
    inputBinding:
      prefix: --incl-flags
    doc: |
      --rf, --incl-flags STR|INT Required flags: skip reads with mask bits unset [null]

  excl-flags:
    type: string?
    inputBinding:
      prefix: --excl-flags
    doc: |
      --ff, --excl-flags STR|INT Filter flags: skip reads with mask bits set [UNMAP,SECONDARY,QCFAIL,DUP]

  ignore-overlaps:
    type: boolean?
    inputBinding:
      prefix: --ignore-overlaps
    doc: |
      -x, --ignore-overlaps Disable read-pair overlap detection.

  output_fn:
    type: string
    inputBinding:
      prefix: --output
    doc: |
      -o, --output FILE Write pileup or VCF/BCF output to FILE, rather than the default of standard output.

      (The same short option is used for both --open-prob and --output. If -o's argument contains any non-digit
      characters other than a leading + or - sign, it is interpreted as --output. Usually the filename extension
      will take care of this, but to write to an entirely numeric filename use -o ./123 or --output 123.)

  BCF:
    type: boolean?
    inputBinding:
      prefix: --BCF
    doc: |
      -g, --BCF Compute genotype likelihoods and output them in the binary call format (BCF). As of v1.0, this
      is BCF2 which is incompatible with the BCF1 format produced by previous (0.1.x) versions of samtools.

  VCF:
    type: boolean?
    inputBinding:
      prefix: --VCF
    doc: |
      -v, --VCF Compute genotype likelihoods and output them in the variant call format (VCF). Output is bgzip-compressed
      VCF unless -u option is set.

  output-BP:
    type: boolean?
    inputBinding:
      prefix: --output-BP
    doc: |
      -O, --output-BP Output base positions on reads.

  output-MQ:
    type: boolean?
    inputBinding:
      prefix: --output-MQ
    doc: |
      -s, --output-MQ Output mapping quality.

  a:
    type: boolean?
    inputBinding:
      prefix: -a
    doc: |
      -a Output all positions, including those with zero depth.

  aa:
    type: boolean?
    inputBinding:
      prefix: -aa
    doc: |
      -a -a, -aa Output absolutely all positions, including unused reference sequences. Note that when used in conjunction
      with a BED file the -a option may sometimes operate as if -aa was specified if the reference sequence has coverage
      outside of the region specified in the BED file.

  output-tags:
    type: string?
    inputBinding:
      prefix: --output-tags
    doc: |
      -t, --output-tags LIST Comma-separated list of FORMAT and INFO tags to output (case-insensitive): AD (Allelic depth, FORMAT),
      INFO/AD (Total allelic depth, INFO), ADF (Allelic depths on the forward strand, FORMAT), INFO/ADF (Total allelic depths on
      the forward strand, INFO), ADR (Allelic depths on the reverse strand, FORMAT), INFO/ADR (Total allelic depths on the
      reverse strand, INFO), DP (Number of high-quality bases, FORMAT), DV (Deprecated in favor of AD; Number of high-quality
      non-reference bases, FORMAT), DPR (Deprecated in favor of AD; Number of high-quality bases for each observed allele, FORMAT),
      INFO/DPR (Number of high-quality bases for each observed allele, INFO), DP4 (Deprecated in favor of ADF and ADR; Number of
      high-quality ref-forward, ref-reverse, alt-forward and alt-reverse bases, FORMAT), SP (Phred-scaled strand bias P-value, FORMAT)
      [null]

  uncompressed:
    type: boolean?
    inputBinding:
      prefix: --uncompressed
    doc: |
      -u, --uncompressed Generate uncompressed VCF/BCF output, which is preferred for piping.

  ext-prob:
    type: int?
    inputBinding:
      prefix: --ext-prob
    doc: |
      -e, --ext-prob INT Phred-scaled gap extension sequencing error probability. Reducing INT leads to longer indels. [20]

  gap-frac:
    type: float?
    inputBinding:
      prefix: --gap-frac
    doc: |
      -F, --gap-frac FLOAT Minimum fraction of gapped reads [0.002]

  tandem-qual:
    type: int?
    inputBinding:
      prefix: --tandem-qual
    doc: |
      -h, --tandem-qual INT Coefficient for modeling homopolymer errors. Given an l-long homopolymer run, the sequencing error of
      an indel of size s is modeled as INT*s/l. [100]

  skip-indels:
    type: boolean?
    inputBinding:
      prefix: --skip-indels
    doc: |
      -I, --skip-indels Do not perform INDEL calling

  max-idepth:
    type: int?
    inputBinding:
      prefix: --max-idepth
    doc: |
      -L, --max-idepth INT Skip INDEL calling if the average per-input-file depth is above INT. [250]

  min-ireads:
    type: int?
    inputBinding:
      prefix: --min-ireads
    doc: |
      -m, --min-ireads INT Minimum number gapped reads for indel candidates INT. [1]

  open-prob:
    type: int?
    inputBinding:
      prefix: --open-prob
    doc: |
      -o, --open-prob INT Phred-scaled gap open sequencing error probability. Reducing INT leads to more indel calls. [40]

      (The same short option is used for both --open-prob and --output. When -o's argument contains only an optional + or -
      sign followed by the digits 0 to 9, it is interpreted as --open-prob.)

  per-sample-mF:
    type: boolean?
    inputBinding:
      prefix: --per-sample-mF
    doc: |
      -p, --per-sample-mF Apply -m and -F thresholds per sample to increase sensitivity of calling. By default both
      options are applied to reads pooled from all samples.

  platforms:
    type: string?
    inputBinding:
      prefix: --platforms
    doc: |
      -P, --platforms STR Comma-delimited list of platforms (determined by @RG-PL) from which indel candidates are obtained.
      It is recommended to collect indel candidates from sequencing technologies that have low indel error rate such as ILLUMINA. [all]

outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_fn)

baseCommand: [samtools, mpileup]
