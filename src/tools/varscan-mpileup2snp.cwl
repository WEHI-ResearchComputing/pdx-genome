#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
- $import: envvar-global.yml
#- $import: samtools-docker.yml
- class: InlineJavascriptRequirement

inputs:
  input:
    type: File
    inputBinding:
      position: 0
    doc: |
      pileup file - The SAMtools pileup file

  min-coverage:
    type: int?
    inputBinding:
      prefix: --min-coverage
    doc: |
      --min-coverage  Minimum read depth at a position to make a call [8]

  min-reads2:
    type: int?
    inputBinding:
      prefix: --min-reads2
    doc: |
      --min-reads2  Minimum supporting reads at a position to call variants [2]

  min-avg-qual:
    type: int?
    inputBinding:
      prefix: --min-avg-qual
    doc: |
      --min-avg-qual  Minimum base quality at a position to count a read [15]

  min-var-freq:
    type: float?
    inputBinding:
      prefix: --min-var-freq
    doc: |
      --min-var-freq  Minimum variant allele frequency threshold [0.01]

  p-value:
    type: float?
    inputBinding:
      prefix: --p-value
    doc: |
      --p-value Default p-value threshold for calling variants [99e-02]

  strand-filter:
    type: boolean?
    inputBinding:
      prefix: "--strand-filter 1"
    doc: |
      --strand-filter Ignore variants with >90% support on one strand [1]

  output-vcf:
    type: boolean?
    inputBinding:
      prefix: "--output-vcf 1"
    doc: |
      --output-vcf  If set to 1, outputs in VCF format

  variants:
    type: boolean?
    inputBinding:
      prefix: "--variants 1"
    doc: |
      --variants  Report only variant (SNP/indel) positions (mpileup2cns only) [0]

stdout: $(inputs.input.nameroot + '.vcf')

outputs:
  output:
    type: stdout

baseCommand: [java, net.sf.varscan.VarScan, mpileup2snp]
