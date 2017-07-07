#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
- $import: envvar-global.yml
- class: InlineJavascriptRequirement
- class: ShellCommandRequirement
# - class: DockerRequirement
#   #dockerImageId: scidap/bowtie:v1.1.2 #not yet ready
#   dockerPull: scidap/bowtie:v1.1.2
#   dockerFile: >
#     $import: bowtie-Dockerfile

inputs:
  bamFiles:
    type: File[]
    inputBinding:
      prefix: --bamFiles=
      itemSeparator: ','
      separate: false
    doc: |
      --bamFiles  List of BAM files for calling. Can be comma-separated list, or the name of a text file with one BAM name per line.

  refFile:
    type: string
    inputBinding:
      prefix: --refFile=
      separate: false
    doc: |
      --refFile Name of the (indexed) reference FASTA file used for variant calling

  outputFileName:
    type: string
    inputBinding:
      prefix: --output=
      separate: false
    doc: |
      --output, -o  Name of the output VCF file

  regions:
    type: string?
    inputBinding:
      prefix: --regions=
      separate: false
    doc: |
      --regions List of regions in which to identify variants, or a text file containing one region per line.

  assemble:
    type: boolean?
    inputBinding:
      prefix: --assemble
    doc: |
      --assemble  Whether to use the assembler to generate candidate haplotypes

  source:
    type: File?
    inputBinding:
      prefix: --source=
      separate: false
    doc: |
      --source  Name of any input VCF(s) to be used for genotyping

  nCPU:
    type: int?
    inputBinding:
      prefix: --nCPU=
      separate: false
    doc: |
      --nCPU  Number of processors/cores to use when running Platypus

  logFileName:
    type: string?
    inputBinding:
      prefix: --logFileName=
      separate: false
    doc: |
      --logFileName Name of the log file

  bufferSize:
    type: int?
    inputBinding:
      prefix: --bufferSize=
      separate: false
    doc: |
      --bufferSize  Size of genomic region (in bases) to read into memory at any one time. Increasing this increases memory usage and reduces run-time.

  minReads:
    type: int?
    inputBinding:
      prefix: --minReads=
      separate: false
    doc: |
      --minReads  Minimum number of reads required to support a variant, before that variant is considered for calling

  maxReads:
    type: int?
    inputBinding:
      prefix: --maxReads=
      separate: false
    doc: |
      --maxReads  Maximum number of allowed reads in region of 'bufferSize'. Platypus will skip any regions with more reads than this, to avoid memory problems.

  maxVariants:
    type: int?
    inputBinding:
      prefix: --maxVariants=
      separate: false
    doc: |
      --maxVariants   Maximum number of variants allowed in a window (windows are typically around 100bp). Increasing this will slow Platypus down, but may give more accurate calls in very divergent regions.

  verbosity:
    type: int?
    inputBinding:
      prefix: --verbosity=
      separate: false
    doc: |
      --verbosity Level of information produced in log file. Useful for debugging.

  minPosterior:
    type: int?
    inputBinding:
      prefix: --minPosterior=
      separate: false
    doc: |
      undocumented

  maxSize:
    type: int?
    inputBinding:
      prefix: --maxSize=
      separate: false
    doc: |
      undocumented

  minFlank:
    type: int?
    inputBinding:
      prefix: --minFlank=
      separate: false
    doc: |
      undocumented

outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.outputFileName)

  logFile:
    type: File?
    outputBinding:
      glob: $(inputs.logFileName)

baseCommand: [python2, /home/thomas.e/home/dev/Platypus_0.8.1/Platypus.py, callVariants]


