#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0

inputs:
  pattern: string
  infiles: File[]

outputs:
  outfile:
    type: File
    outputBinding:
      glob: "*.gz"

steps:
  trimmomatic:
    run: tools/trimmomatic.cwl
    in:
      pattern: pattern
      infile: infiles
    out: [outfile]
    id:
      nthreads: 4
      end_mode: PE
      illuminaClip: "ILLUMINACLIP:/stornext/System/data/apps/trimmomatic/trimmomatic-0.36/adapters/TruSeq3-PE.fa:1:30:20:4:true"
    outputs:
      output_log: log
      reads1_trimmed_paired: R1
      reads2_trimmed_paired: R2

