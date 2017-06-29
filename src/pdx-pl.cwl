#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0

requirements:
- $import: tools/trimmomatic-types.yml
- class: InlineJavascriptRequirement
- class: ScatterFeatureRequirement

inputs:
  read1: File[]
  read2: File[]

outputs:
  trim-logs:
    type: File[]
    outputSource: trimmomatic/output_log
  read1-paired:
    type: File[]
    outputSource: trimmomatic/reads1_trimmed
  read2-paired:
    type: File[]
    outputSource: trimmomatic/reads1_trimmed_unpaired
  read1-unpaired:
    type: File[]
    outputSource: trimmomatic/reads2_trimmed_paired
  read2-unpaired:
    type: File[]
    outputSource: trimmomatic/reads2_trimmed_unpaired

steps:
  trimmomatic:
    run: tools/trimmomatic.cwl
    scatter: [reads1, reads2]
    scatterMethod: dotproduct
    in:
      reads1: read1
      reads2: read2
      end_mode:
        default: PE
      nthreads:
        default: 4
      illuminaClip:
        default:
          adapters:
            class: File
            location: "/stornext/System/data/apps/trimmomatic/trimmomatic-0.36/adapters/TruSeq3-PE.fa"
          seedMismatches: 1
          palindromeClipThreshold: 30
          simpleClipThreshold: 20
          minAdapterLength: 4
          keepBothReads: "true"

    out: [output_log, reads1_trimmed, reads1_trimmed_unpaired, reads2_trimmed_paired, reads2_trimmed_unpaired]

  # rename:
  #   run:
  #     class: ExpressionTool
  #     inputs:
  #       login:
  #         type: File
  #     outputs:
  #       logout: Directory
  #     expression: >
  #       ${
  #       var outfile = inputs.login;
  #       outfile.path = outfile.path + '/dataout';
  #       return {"logout" : {
  #                 "class" : "Directory",
  #                 "basename" : "dataout",
  #                 "listing" : [inputs.login]
  #                         }
  #               }
  #       }

  #   in:
  #     login: trimmomatic/output_log
  #   out: [logout]


