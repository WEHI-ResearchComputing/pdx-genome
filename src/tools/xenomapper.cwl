#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
- $import: envvar-global.yml
- class: InlineJavascriptRequirement

baseCommand: xenomapper

inputs:
  primary_sam:
    type: File?
    inputBinding:
      prefix: --primary_sam
    doc: |
      --primary_sam PRIMARY_SAM a SAM format Bowtie2 mapping output file corresponding to the
      primary species of interest

  secondary_sam:
    type: File?
    inputBinding:
      prefix: --secondary_sam
    doc: |
      --secondary_sam SECONDARY_SAM a SAM format Bowtie2 mapping output file corresponding to the
      secondary or contaminating species


  primary_bam:
    type: File?
    inputBinding:
      prefix: --primary_bam
    doc: |
      --primary_bam PRIMARY_BAM a BAM format Bowtie2 mapping output file corresponding to the
      primary species of interest

  secondary_bam:
    type: File?
    inputBinding:
      prefix: --secondary_bam
    doc: |
      --secondary_bam SECONDARY_BAM a BAM format Bowtie2 mapping output file corresponding to
      the secondary or contaminating species

  primary_specific_fn:
    type: string?
    inputBinding:
      prefix: --primary_specific
    doc: |
      --primary_specific PRIMARY_SPECIFIC name for SAM format output file for reads mapping to
      a specific location in the primary species

  secondary_specific_fn:
    type: string?
    inputBinding:
      prefix: --secondary_specific
    doc: |
      --secondary_specific SECONDARY_SPECIFIC name for SAM format output file for reads mapping to a
      specific location in the secondary species

  primary_multi_fn:
    type: string?
    inputBinding:
      prefix: --primary_multi
    doc: |
      --primary_multi PRIMARY_MULTI name for SAM format output file for reads multi
      mapping in the primary species

  secondary_multi_fn:
    type: string?
    inputBinding:
      prefix: --secondary_multi
    doc: |
      --secondary_multi SECONDARY_MULTI name for SAM format output file for reads multi
      mapping in the secondary species

  unassigned_fn:
    type: string?
    inputBinding:
      prefix: --unassigned
    doc: |
      --unassigned UNASSIGNED name for SAM format output file for unassigned (non-mapping) reads

  unresolved_fn:
    type: string?
    inputBinding:
      prefix: --unresolved
    doc: |
      --unresolved UNRESOLVED name for SAM format output file for unresolved (maps
      qually well in both species) reads

  paired:
    type: boolean?
    inputBinding:
      prefix: --paired
    doc: |
      --paired the SAM files consist of paired reads with forward and reverse reads occuring once and interlaced

  conservative:
    type: boolean?
    inputBinding:
      prefix: --conservative
    doc: |
      --conservative conservatively allocate paired end reads with discordant category allocations. Only pairs that are
      both specific, or specific and multi will be allocated as specific. Pairs that are discordant for species
      will be deemed unresolved. Pairs where any read is unassigned will be deemed unassigned.

  min_score:
    type: int?
    inputBinding:
      prefix: --min_score
    doc: |
      --min_score MIN_SCORE the minimum mapping score.  Reads with scores less than or equal to min_score will be
      considered unassigned. Values should be chosen based on the mapping program and read length

  cigar_scores:
    type: boolean?
    inputBinding:
      prefix: --cigar_scores
    doc: |
      --cigar_scores Use the cigar line and the NM tag to calculate a score. For aligners that do not
      support the AS tag. No determination of multimapping state will be done. Reads that are unique
      in one species and multimap in the other species may be misassigned as no score can be calculated
      in the multimapping species. Score is -6 * mismatches + -5 * indel open + -3 * indel extend + -2
      * softclip.

  use_zs:
    type: boolean?
    inputBinding:
      prefix: --use_zs
    doc: |
      --use_zs Use the value of the ZS tag in place of XS for determining the mapping score of the next
      best alignment. Used with HISAT as the XS:A tag is conventionally used for strand in spliced mappers.

outputs:
  primary_specific:
    type: File?
    outputBinding:
      glob: $(inputs.primary_specific_fn)

  secondary_specific:
    type: File?
    outputBinding:
      glob: $(inputs.secondary_specific_fn)

  primary_multi:
    type: File?
    outputBinding:
      glob: $(inputs.primary_multi_fn)

  secondary_multi:
    type: File?
    outputBinding:
      glob: $(inputs.secondary_multi_fn)

  unassigned:
    type: File?
    outputBinding:
      glob: $(inputs.unassigned_fn)

  unresolved:
    type: File?
    outputBinding:
      glob: $(inputs.unresolved_fn)
