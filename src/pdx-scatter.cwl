#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0

requirements:
- class: InlineJavascriptRequirement
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: SubworkflowFeatureRequirement

inputs:
  reads1: File[]
  reads2: File[]
  adapters:
      type: File
      default:
        class: File
        path: /stornext/System/data/apps/trimmomatic/trimmomatic-0.36/adapters/TruSeq3-PE.fa
        location: /stornext/System/data/apps/trimmomatic/trimmomatic-0.36/adapters/TruSeq3-PE.fa

outputs:
  # trim with trimmomatic and rename
  trim-logs:
    type: File[]
    outputSource: all/trim-logs
  rename_reads1_trimmed_file:
    type: File[]
    outputSource: all/rename_reads1_trimmed_file
  rename_reads2_trimmed_paired_file:
    type:
    - "null"
    -  File[]
    outputSource: all/rename_reads2_trimmed_paired_file
  reads1_trimmed_unpaired_file:
    type:
    - "null"
    - File[]
    outputSource: all/reads1_trimmed_unpaired_file
  reads2_trimmed_unpaired_file:
    type:
    - "null"
    - File[]
    outputSource: all/reads2_trimmed_unpaired_file
  # align to mouse with bowtie2
  mouse-aligned:
    type: File[]
    outputSource: all/reads2_trimmed_unpaired_file
  # align to human with bowtie2
  human-aligned:
    type: File[]
    outputSource: all/human-aligned
  # convert
  human-sorted:
    type: File[]
    streamable: true
    outputSource: all/human-sorted
  # sort and compress
  human-compress:
    type: File[]
    outputSource: all/human-compress
  # Index human bam
  human-index:
    type: File[]
    outputSource: all/human-index
  # compare genomes with xenomapper
  primary_specific:
    type:
    - "null"
    - File[]
    outputSource: all/primary_specific
  secondary_specific:
    type:
    - "null"
    - File[]
    outputSource: all/secondary_specific
  primary_multi:
    type:
    - "null"
    - File[]
    outputSource: all/primary_multi
  secondary_multi:
    type:
    - "null"
    - File[]
    outputSource: all/secondary_multi
  unassigned:
    type:
    - "null"
    - File[]
    outputSource: all/unassigned
  unresolved:
    type:
    - "null"
    - File[]
    outputSource: all/unresolved
  # pileip
  human-mpileup:
    type: File[]
    outputSource: all/human-mpileup
 # varscan output
  varscan:
    type: File[]
    outputSource: all/varscan
  # platypus output
  platypus-vcf:
    type: File[]
    outputSource: all/platypus-vcf
  # gridss
  gridss:
    type: File[]
    outputSource: all/gridss
  # VEP
  vep-text:
    type: File[]
    outputSource: all/vep-text
  vep-html:
    type: File[]
    outputSource: all/vep-html

steps:

  all:
    run: pdx-pl.cwl

    scatter: [read1, read2]
    scatterMethod: dotproduct

    in:
      read1:
        source: reads1
      read2:
        source: reads2
      adapters:
        source: adapters


    out: [trim-logs, rename_reads1_trimmed_file, rename_reads2_trimmed_paired_file, reads1_trimmed_unpaired_file, reads2_trimmed_unpaired_file, mouse-aligned, human-aligned, human-sorted, human-compress, human-index, primary_specific, secondary_specific, primary_multi, secondary_multi, unassigned, unresolved, human-mpileup, varscan, platypus-vcf, gridss, vep-text, vep-html]


