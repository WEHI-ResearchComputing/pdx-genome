#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0

requirements:
- $import: tools/trimmomatic-types.yml
- $import: tools/envvar-global.yml
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
  # Index human bam
  human-index:
    type: File
    outputSource: index-human/index
  # compare genomes with xenomapper
  primary_specific:
    type: File?
    outputSource: xenomapping/primary_specific
  secondary_specific:
    type: File?
    outputSource: xenomapping/secondary_specific
  primary_multi:
    type: File?
    outputSource: xenomapping/primary_multi
  secondary_multi:
    type: File?
    outputSource: xenomapping/secondary_multi
  unassigned:
    type: File?
    outputSource: xenomapping/unassigned
  unresolved:
    type: File?
    outputSource: xenomapping/unresolved
  human-mpileup:
    type: File
    outputSource: mpileup-human/output

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
  # align to human reference with bowtie2
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
        default: /wehisan/bioinf/bioinf-data/Papenfuss_lab/projects/reference_genomes/human_new/no_alt/hg38_no_alt.fa
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

  #
  # index human bam
  #
  index-human:
    run: tools/samtools-index.cwl

    in:
      input:
        source: sort-human/sorted

    out: [index]

  #
  # human pileup file
  #
  mpileup-human:
    run: tools/samtools-mpileup.cwl

    in:
      bamFiles:
        source: sort-human/sorted
        valueFrom: >
          ${
              if ( self == null ) {
                return null;
              } else {
                return [self];
              }
            }

      output_fn:
        source: sort-human/sorted
        valueFrom: >
          ${
            return self.nameroot + '.pileup'
          }

    out: [output]

  #
  # varscan human
  #
  varscan-human:
    run: tools/varscan-mpileup2snp.cwl

    in:
      input:
        source: mpileup-human/output

      output-vcf:
        valueFrom: >
          ${
            return true;
          }

    out: [output]

  #
  # GRIDSS that human
  #
  gridss-human:
    run: tools/gridss-callvariants.cwl

    in:
      INPUT:
        source: sort-human/sorted
        valueFrom: >
          ${
              if ( self == null ) {
                return null;
              } else {
                return [self];
              }
            }

      REFERENCE_SEQUENCE:
        default: /wehisan/bioinf/bioinf-data/Papenfuss_lab/projects/reference_genomes/human_new/no_alt/hg38_no_alt.fa

      OUTPUT:
        source: sort-human/sorted
        valueFrom: >
          ${
              return self.nameroot + '.gridss.vcf'
          }

      ASSEMBLY:
        source: sort-human/sorted
        valueFrom: >
          ${
              return self.nameroot + '.gridss.bam'
          }

    out: [output]
  #
  # xenomapper
  #
  xenomapping:
    run: tools/xenomapper.cwl

    in:
      primary_sam:
        source: align-to-human/aligned-file
      secondary_sam:
        source: align-to-mouse/aligned-file
      primary_specific_fn:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
            return self.nameroot + '.human_specific.sam'
          }
      secondary_specific_fn:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
            return self.nameroot + '.mouse_specific.sam'
          }
      primary_multi_fn:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
            return self.nameroot + '.human_multi.sam'
          }
      secondary_multi_fn:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
            return self.nameroot + '.mouse_multi.sam'
          }
      unassigned_fn:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
            return self.nameroot + '.unassigned.sam'
          }
      unresolved_fn:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
            return self.nameroot + '.unresolved.sam'
          }

    out: [primary_specific, secondary_specific, primary_multi, secondary_multi, unassigned, unresolved]

  #
  # Gather human bam and index into one dependency
  #
  gather:
    run:
      class: ExpressionTool

      inputs:
        bamFile:
          type: File
        bamIndex:
          type: File

      outputs:
        combined:
          type: File

      expression: >
        ${
          var ret = inputs.bamFile;
          ret["secondaryFiles"] = [
            inputs.bamIndex
          ];
          return {"combined" : ret};
        }

    in:
      bamFile:
        source: sort-human/sorted
      bamIndex:
        source: index-human/index

    out: [combined]

  #
  # Call with platyus
  #
  platyus:
    run: tools/platypus.cwl

    in:
      bamFiles:
        source: gather/combined
        valueFrom: >
          ${
            if ( self == null ) {
              return null;
              } else {
              return [self];
            }
          }
      refFile:
        default: /wehisan/bioinf/bioinf-data/Papenfuss_lab/projects/reference_genomes/human_new/no_alt/hg38_no_alt.fa
      outputFileName:
        source: sort-human/sorted
        valueFrom: >
          ${
              return self.nameroot + '.platypus.vcf'
          }
      verbosity:
        valueFrom: >
          ${
            return 0;
          }

    out: [output]

#-------------------------------------------------------------------------
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


