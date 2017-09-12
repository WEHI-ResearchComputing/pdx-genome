#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0

requirements:
- class: InlineJavascriptRequirement
  expressionLib:
  - var rename_trim_file = function() {
      if ( self == null ) {
        return null;
      } else {
        var xx = self.basename.split('.');
        var id = xx.indexOf('fastq');
        xx.splice(id, 1);
        return xx.join('.');
      }
    };
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: SchemaDefRequirement
  types:
  - $import: ../tools/src/tools/trimmomatic-end_mode.yml
  - $import: ../tools/src/tools/trimmomatic-sliding_window.yml
  - $import: ../tools/src/tools/trimmomatic-phred.yml
  - $import: ../tools/src/tools/trimmomatic-illumina_clipping.yml
  - $import: ../tools/src/tools/trimmomatic-max_info.yml

inputs:
  read1: File
  read2: File
  adapters:
      type: File
      default:
        class: File
        path: /stornext/System/data/apps/trimmomatic/trimmomatic-0.36/adapters/TruSeq3-PE.fa
        location: /stornext/System/data/apps/trimmomatic/trimmomatic-0.36/adapters/TruSeq3-PE.fa

outputs:
  # trim with trimmomatic and rename
  trim-logs:
    type: File
    outputSource: trim/output_log
  rename_reads1_trimmed_file:
    type: File
    outputSource: rename_reads1_trimmed/renamed
  rename_reads2_trimmed_paired_file:
    type:
    - "null"
    -  File
    outputSource: trim/reads2_trimmed_unpaired
  reads1_trimmed_unpaired_file:
    type:
    - "null"
    - File
    outputSource: trim/reads1_trimmed_unpaired
  reads2_trimmed_unpaired_file:
    type:
    - "null"
    - File
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
  # # pileup
  # human-mpileup:
  #   type: File
  #   outputSource: mpileup-human/output
 # # varscan output
 #  varscan:
 #    type: File
 #    outputSource: varscan-human/output
  # platypus output
  platypus-tabix-output:
    type: File
    outputSource: platypus-tabix/tabix
  # gridss
  gridss-tabix-output:
    type: File
    outputSource: gridss-tabix/tabix
  gridss-vcf-work-dir:
    type: Directory
    outputSource: gridss-human/vcf_working
  gridss-bam-work-dir:
    type: Directory
    outputSource: gridss-human/bam_working

  # # VEP
  # vep-text:
  #   type: File
  #   outputSource: vep-human/text
  # vep-html:
  #   type: File
  #   outputSource: vep-human/html

steps:
  #
  # trim with trimmomatic
  #
  trim:
    run: ../tools/src/tools/trimmomatic.cwl
    requirements:
      ResourceRequirement:
        coresMin: 2
        ramMin: 16000

    in:
      reads1:
        source: read1
        valueFrom: >
          ${
              self.format = "http://edamontology.org/format_1930";
              return self;
          }
      reads2:
        source: read2
        valueFrom: >
          ${
              self.format = "http://edamontology.org/format_1930";
              return self;
          }
      end_mode:
        default: PE
      nthreads:
        valueFrom: $( 2 )
      illuminaClip:
        source: adapters
        valueFrom: |
          ${
              return {
              "adapters": self,
              "seedMismatches": 1,
              "palindromeClipThreshold": 20,
              "simpleClipThreshold": 20,
              "minAdapterLength": 4,
              "keepBothReads": true };
          }

    out: [output_log, reads1_trimmed, reads1_trimmed_unpaired, reads2_trimmed_paired, reads2_trimmed_unpaired]

  #
  # rename trimmed files by removing redundant '.fastq' from the filename
  #
  rename_reads1_trimmed:
    run: ../tools/src/tools/rename-file.cwl
    requirements:
      ResourceRequirement:
        coresMin: 1
        ramMin: 4000

    in:
      infile: trim/reads1_trimmed
      outfile:
        source: trim/reads1_trimmed
        valueFrom: ${ return rename_trim_file(); }

    out: [renamed]

  rename_reads2_trimmed_paired:
    run: ../tools/src/tools/rename-file.cwl
    requirements:
      ResourceRequirement:
        coresMin: 1
        ramMin: 4000

    in:
      infile: trim/reads2_trimmed_paired
      outfile:
        source: trim/reads2_trimmed_paired
        valueFrom: ${ return rename_trim_file(); }

    out: [renamed]

  #
  # align to mouse reference with bowtie2
  #
  align-to-mouse:
    run: ../tools/src/tools/bowtie2.cwl
    requirements:
      ResourceRequirement:
        coresMin: 25
        ramMin: 64000

    in:
      samout:
        source: rename_reads1_trimmed/renamed
        valueFrom: ${ return self.nameroot + '.mouse.sam'; }
      threads:
        valueFrom: ${ return 27; }
      one:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
            return [self];
          }
      two:
        source: rename_reads2_trimmed_paired/renamed
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
    run: ../tools/src/tools/bowtie2.cwl
    requirements:
      ResourceRequirement:
        coresMin: 25
        ramMin: 64000

    in:
      samout:
        source: rename_reads1_trimmed/renamed
        valueFrom: >
          ${
              return self.nameroot + '.human.sam'
          }
      threads:
        valueFrom: $( 25 )
      one:
        source: rename_reads1_trimmed/renamed
        valueFrom: >
          ${
            return [self];
          }
      two:
        source: rename_reads2_trimmed_paired/renamed
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
    run: ../tools/src/tools/samtools-view.cwl
    requirements:
      ResourceRequirement:
        coresMin: 10
        ramMin: 32000

    in:
      input:
        align-to-human/aligned-file
      output_name:
        source: rename_reads1_trimmed/renamed
        valueFrom: >
          ${
              return self.nameroot + '.human.bam'
          }
      threads:
        valueFrom: $( 10 )

    out: [output]

  #
  # sort and compress human
  #
  sort-human:
    run: ../tools/src/tools/samtools-sort.cwl
    requirements:
      ResourceRequirement:
        coresMin: 10
        ramMin: 32000

    in:
      input:
        source: convert-human/output
      output_name:
        source: rename_reads1_trimmed/renamed
        valueFrom: >
          ${
              return self.nameroot + '.sorted.human.bam'
          }
      threads:
        valueFrom: $( 10 )

    out: [sorted]

  #
  # index human bam
  #
  index-human:
    run: ../tools/src/tools/samtools-index.cwl
    requirements:
      ResourceRequirement:
        coresMin: 10
        ramMin: 32000

    in:
      input:
        source: sort-human/sorted

    out: [index]

  # #
  # # human pileup file
  # #
  # mpileup-human:
  #   run: ../tools/src/tools/samtools-mpileup.cwl

  #   in:
  #     bamFiles:
  #       source: sort-human/sorted
  #       valueFrom: >
  #         ${
  #             if ( self == null ) {
  #               return null;
  #             } else {
  #               return [self];
  #             }
  #           }

  #     output_fn:
  #       source: sort-human/sorted
  #       valueFrom: >
  #         ${
  #           return self.nameroot + '.pileup'
  #         }

  #   out: [output]

  # #
  # # varscan human
  # #
  # varscan-human:
  #   run: ../tools/src/tools/varscan-mpileup2snp.cwl

  #   in:
  #     input:
  #       source: mpileup-human/output

  #     output-vcf:
  #       valueFrom: >
  #         ${
  #           return true;
  #         }

  #   out: [output]

  #
  # GRIDSS that human
  #
  gridss-human:
    run: ../tools/src/tools/gridss-callvariants.cwl
    requirements:
      ResourceRequirement:
        coresMin: 25
        ramMin: 64000

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

    out: [vcf, bam, vcf_working, bam_working]

  #
  # Compress and index vcf output
  #
  gridss-bgzip:
    run: ../tools/src/tools/bgzip.cwl
    requirements:
      ResourceRequirement:
        coresMin: 2
        ramMin: 8000

    in:
      inputFile: gridss-human/vcf

    out: [bgzip]

  gridss-tabix:
    run: ../tools/src/tools/tabix.cwl
    requirements:
      ResourceRequirement:
        coresMin: 2
        ramMin: 8000

    in:
      inputFile: gridss-bgzip/bgzip
      preset:
        valueFrom: $( 'vcf' )

    out: [tabix]

  #
  # xenomapper
  #
  xenomapping:
    run: ../tools/src/tools/xenomapper.cwl
    requirements:
      ResourceRequirement:
        coresMin: 2
        ramMin: 32000

    in:
      primary_sam:
        source: align-to-human/aligned-file
      secondary_sam:
        source: align-to-mouse/aligned-file
      primary_specific_fn:
        source: rename_reads1_trimmed/renamed
        valueFrom: >
          ${
            return self.nameroot + '.human_specific.sam'
          }
      secondary_specific_fn:
        source: rename_reads1_trimmed/renamed
        valueFrom: >
          ${
            return self.nameroot + '.mouse_specific.sam'
          }
      primary_multi_fn:
        source: rename_reads1_trimmed/renamed
        valueFrom: >
          ${
            return self.nameroot + '.human_multi.sam'
          }
      secondary_multi_fn:
        source: rename_reads1_trimmed/renamed
        valueFrom: >
          ${
            return self.nameroot + '.mouse_multi.sam'
          }
      unassigned_fn:
        source: rename_reads1_trimmed/renamed
        valueFrom: >
          ${
            return self.nameroot + '.unassigned.sam'
          }
      unresolved_fn:
        source: rename_reads1_trimmed/renamed
        valueFrom: >
          ${
            return self.nameroot + '.unresolved.sam'
          }

    out: [primary_specific, secondary_specific, primary_multi, secondary_multi, unassigned, unresolved]

  #
  # Call with platypus
  #
  platypus:
    run: ../tools/src/tools/platypus.cwl
    requirements:
      ResourceRequirement:
        coresMin: 2
        ramMin: 16000

    in:
      bamFiles:
        source: index-human/index
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
        valueFrom: ${ return 0; }

    out: [output]

  #
  # Compress and index vcf output
  #
  platypus-bgzip:
    run: ../tools/src/tools/bgzip.cwl
    requirements:
      ResourceRequirement:
        coresMin: 2
        ramMin: 8000

    in:
      inputFile: platypus/output

    out: [bgzip]

  platypus-tabix:
    run: ../tools/src/tools/tabix.cwl
    requirements:
      ResourceRequirement:
        coresMin: 2

    in:
      inputFile: platypus-bgzip/bgzip
      preset:
        valueFrom: $( 'vcf' )

    out: [tabix]

  # #
  # # Variant Effect predictor
  # #
  # vep-human:
  #   run: ../tools/src/tools/vep.cwl

  #   in:
  #     input_file:
  #       source: platypus/output

  #     output_file:
  #       source: platypus/output
  #       valueFrom: >
  #         ${
  #             return self.nameroot + '.vep.txt'
  #         }

  #     fasta:
  #       default: /wehisan/bioinf/bioinf-data/Papenfuss_lab/projects/reference_genomes/human_new/no_alt/hg38_no_alt.fa

  #     cache:
  #       valueFrom: ${ return true; }
  #     everything:
  #       valueFrom: ${ return true; }
  #     fork:
  #       valueFrom: ${ return num_threads(); }
  #     dir_cache:
  #       default: '/stornext/HPCScratch/cache/.vep'

  #   out: [text, html]
