#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0

requirements:
- $import: tools/trimmomatic-types.yml
- class: InlineJavascriptRequirement
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement

inputs:
  read1: File
  read2: File

outputs:
  # trim with trimmomatic
  trim-logs:
    type: File
    outputSource: trim/output_log
  read1-paired:
    type: File
    outputSource: trim/reads1_trimmed
  read2-paired:
    type: File?
    outputSource: trim/reads1_trimmed_unpaired
  read1-unpaired:
    type: File?
    outputSource: trim/reads2_trimmed_paired
  read2-unpaired:
    type: File?
    outputSource: trim/reads2_trimmed_unpaired
  # align to mouse with bowtie2
  mouse-aligned:
    type: File
    outputSource: align-to-mouse/aligned-file
  # align to human with bowtie2
  human-aligned:
    type: File
    outputSource: align-to-human/aligned-file
  # convert
  human-sorted:
    type: File
    streamable: true
    outputSource: convert-human/output
  # sort and compress
  human-compress:
    type: File
    outputSource: sort-human/sorted


steps:

  #
  # trim with trimmomatic
  #
  trim:
    run: tools/trimmomatic.cwl

    in:
      reads1: read1
      reads2: read2
      end_mode:
        default: PE
      nthreads:
        valueFrom: ${ return 4; }
      illuminaClip:
        default:
          adapters:
            class: File
            location: "/stornext/System/data/apps/trimmomatic/trimmomatic-0.36/adapters/TruSeq3-PE.fa"
          seedMismatches: 1
          palindromeClipThreshold: 20
          simpleClipThreshold: 20
          minAdapterLength: 4
          keepBothReads: "true"

    out: [output_log, reads1_trimmed, reads1_trimmed_unpaired, reads2_trimmed_paired, reads2_trimmed_unpaired]

  #
  # align to mouse reference with bowtie2
  #
  align-to-mouse:
    run: tools/bowtie2.cwl

    in:
      samout:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
              return self.nameroot + '.mouse.sam'
          }
      threads:
        valueFrom: ${ return 4; }
      one:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
            return [self];
          }
      two:
        source: trim/reads2_trimmed_paired
        valueFrom: >
          ${
            if ( self == null ) {
              return null;
              } else {
              return [self];
            }
          }
      unpaired:
        source: trim/reads1_trimmed_unpaired
        valueFrom: >
          ${
            if ( self == null ) {
              return null;
              } else {
              return [self];
            }
          }
      bt2-idx:
        default: /stornext/HPCScratch/PapenfussLab/reference_genomes/bowtie2/GRCm38
      local:
        default: true
      reorder:
        default: true

    out: [aligned-file]

  #
  # align to mouse reference with bowtie2
  #
  align-to-human:
    run: tools/bowtie2.cwl

    in:
      samout:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
              return self.nameroot + '.human.sam'
          }
      threads:
        valueFrom: ${ return 4; }
      one:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
            return [self];
          }
      two:
        source: trim/reads2_trimmed_paired
        valueFrom: >
          ${
            if ( self == null ) {
              return null;
              } else {
              return [self];
            }
          }
      unpaired:
        source: trim/reads1_trimmed_unpaired
        valueFrom: >
          ${
            if ( self == null ) {
              return null;
              } else {
              return [self];
            }
          }
      bt2-idx:
        default: /stornext/HPCScratch/PapenfussLab/reference_genomes/bowtie2/GRCh38_no_alt
      local:
        default: true
      reorder:
        default: true

    out: [aligned-file]

  #
  # convert human
  #
  convert-human:
    run: tools/samtools-view.cwl

    in:
      input:
        align-to-human/aligned-file
      output_name:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
              return self.nameroot + '.human.bam'
          }
      threads:
        valueFrom: ${ return 4; }

    out: [output]

  #
  # sort and compress human
  #
  sort-human:
    run: tools/samtools-sort.cwl

    in:
      input:
        source: convert-human/output
      output_name:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
              return self.nameroot + '.sorted.human.bam'
          }
      threads:
        valueFrom: ${ return 4; }

    out: [sorted]

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


