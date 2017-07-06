#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
#- $import: envvar-global.yml
- class: InlineJavascriptRequirement
- class: ShellCommandRequirement
# - class: DockerRequirement
#   #dockerImageId: scidap/bowtie:v1.1.2 #not yet ready
#   dockerPull: scidap/bowtie:v1.1.2
#   dockerFile: >
#     $import: bowtie-Dockerfile

inputs:
  bt2-idx:
    type: string
    inputBinding:
      prefix: -x
    doc: |
      -x <bt2-idx> The basename of the index for the reference genome. The basename is the name of
      any of the index files up to but not including the final .1.bt2 / .rev.1.bt2 / etc. bowtie2
      looks for the specified index first in the current directory, then in the directory specified
      in the BOWTIE2_INDEXES environment variable.

  one:
    type: File[]
    inputBinding:
      prefix: '-1'
      itemSeparator: ','
    doc: |
      -1 <m1> Comma-separated list of files containing mate 1s (filename usually includes _1),
      e.g. -1 flyA_1.fq,flyB_1.fq. Sequences specified with this option must correspond file-for-file
      and read-for-read with those specified in <m2>. Reads may be a mix of different lengths.
      If - is specified, bowtie2 will read the mate 1s from the "standard in" or "stdin" filehandle.

  two:
    type: File[]?
    inputBinding:
      prefix: '-2'
      itemSeparator: ','
    doc: |
      -2 <m2> Comma-separated list of files containing mate 2s (filename usually includes _2),
      e.g. -2 flyA_2.fq,flyB_2.fq. Sequences specified with this option must correspond file-for-file
      and read-for-read with those specified in <m1>. Reads may be a mix of different lengths.
      If - is specified, bowtie2 will read the mate 2s from the "standard in" or "stdin" filehandle.

  unpaired:
    type: File[]?
    inputBinding:
      prefix: -U
      itemSeparator: ','
    doc: |
      -U <r> Comma-separated list of files containing unpaired reads to be aligned,
      e.g. lane1.fq,lane2.fq,lane3.fq,lane4.fq. Reads may be a mix of different lengths.
      If - is specified, bowtie2 gets the reads from the "standard in" or "stdin" filehandle.

  samout:
    type: File?
    inputBinding:
      prefix: -S
    doc: |
      -S <hit> File to write SAM alignments to. By default, alignments are written to the
      "standard out" or "stdout" filehandle (i.e. the console).

  fastq:
    type: boolean?
    inputBinding:
      prefix: -q
    doc: |
      -q Reads (specified with <m1>, <m2>, <s>) are FASTQ files. FASTQ files usually have
      extension .fq or .fastq. FASTQ is the default format. See also: --solexa-quals and --int-quals.

  interleaved:
    type: boolean?
    inputBinding:
      prefix: --interleaved
    doc: |
      --interleaved Reads interleaved FASTQ files where the first two records (8 lines) represent a mate pair.

  tab5:
    type: boolean?
    inputBinding:
      prefix: --tab5
    doc: |
      --tab5 Each read or pair is on a single line. An unpaired read line is [name]\t[seq]\t[qual]\n.
      A paired-end read line is [name]\t[seq1]\t[qual1]\t[seq2]\t[qual2]\n. An input file can be a mix
      of unpaired and paired-end reads and Bowtie 2 recognizes each according to the number of fields,
      handling each as it should.

  tab6:
    type: boolean?
    inputBinding:
      prefix: --tab6
    doc: |
      --tab6 Similar to --tab5 except, for paired-end reads, the second end can have a different
      name from the first: [name1]\t[seq1]\t[qual1]\t[name2]\t[seq2]\t[qual2]\n

  qseq:
    type: boolean?
    inputBinding:
      prefix: --qseq
    doc: |
      --qseq Reads (specified with <m1>, <m2>, <s>) are QSEQ files. QSEQ files usually end in _qseq.txt.
      See also: --solexa-quals and --int-quals.

  fasta:
    type: boolean?
    inputBinding:
      prefix: -f
    doc: |
      -f Reads (specified with <m1>, <m2>, <s>) are FASTA files. FASTA files usually have extension .fa,
       .fasta, .mfa, .fna or similar. FASTA files do not have a way of specifying quality values, so when -f
       is set, the result is as if --ignore-quals is also set.

  reads:
    type: boolean?
    inputBinding:
      prefix: -r
    doc: |
      -r Reads (specified with <m1>, <m2>, <s>) are files with one input sequence per line, without any other
      information (no read names, no qualities). When -r is set, the result is as if --ignore-quals is also set.

  commandline:
    type: boolean?
    inputBinding:
      prefix: -c
    doc: |
      -c The read sequences are given on command line. I.e. <m1>, <m2> and <singles> are comma-separated
      lists of reads rather than lists of read files. There is no way to specify read names or qualities, so -c
      also implies --ignore-quals.

  skip:
    type: int?
    inputBinding:
      prefix: --skip
    doc: |
      -s/--skip <int> Skip (i.e. do not align) the first <int> reads or pairs in the input.

  qupto:
    type: int?
    inputBinding:
      prefix: --qupto
    doc: |
      -u/--qupto <int> Align the first <int> reads or read pairs from the input (after the -s/--skip
      reads or pairs have been skipped), then stop. Default: no limit.

  trim5:
    type: int?
    inputBinding:
      prefix: --trim5
    doc: |
      -5/--trim5 <int> Trim <int> bases from 5' (left) end of each read before alignment (default: 0).

  trim3:
    type: int?
    inputBinding:
      prefix: --trim3
    doc: |
      -3/--trim3 <int> Trim <int> bases from 3' (left) end of each read before alignment (default: 0).

  phred33:
    type: boolean?
    inputBinding:
      prefix: --phred33
    doc: |
      --phred33 Input qualities are ASCII chars equal to the Phred quality plus 33. This is also called
      the "Phred+33" encoding, which is used by the very latest Illumina pipelines.

  phred64:
    type: boolean?
    inputBinding:
      prefix: --phred33
    doc: |
      --phred64 IInput qualities are ASCII chars equal to the Phred quality plus 64. This is also called
      the "Phred+64" encoding.

  solexa-quals:
    type: boolean?
    inputBinding:
      prefix: --solexa-quals
    doc: |
      --solexa-quals Convert input qualities from Solexa (which can be negative) to Phred (which can't).
      This scheme was used in older Illumina GA Pipeline versions (prior to 1.3). Default: off.

  int-quals:
    type: boolean?
    inputBinding:
      prefix: --int-quals
    doc: |
      --int-quals Quality values are represented in the read input file as space-separated ASCII integers,
      e.g., 40 40 30 40..., rather than ASCII characters, e.g., II?I.... Integers are treated as being on
      the Phred quality scale unless --solexa-quals is also specified. Default: off.

  local:
    type: boolean?
    inputBinding:
      prefix: --local
    doc: |
      --local In this mode, Bowtie 2 does not require that the entire read align from one end to the other. Rather,
      some characters may be omitted ("soft clipped") from the ends in order to achieve the greatest
      possible alignment score. The match bonus --ma is used in this mode, and the best possible alignment
      score is equal to the match bonus (--ma) times the length of the read. Specifying --local and one of the presets
      (e.g. --local --very-fast) is equivalent to specifying the local version of the preset (--very-fast-local

  threads:
    type: int?
    inputBinding:
      prefix: --threads
    doc: |
      -p/--threads NTHREADS Launch NTHREADS parallel search threads (default: 1). Threads will run on separate
      processors/cores and synchronize when parsing reads and outputting alignments. Searching for alignments is
      highly parallel, and speedup is close to linear. Increasing -p increases Bowtie 2's memory footprint. E.g.
      when aligning to a human genome index, increasing -p from 1 to 8 increases the memory footprint by a few
      hundred megabytes. This option is only available if bowtie is linked with the pthreads library (i.e. if
      BOWTIE_PTHREADS=0 is not specified at build time).

  reorder:
    type: boolean?
    inputBinding:
      prefix: --reorder
    doc: |
      --reorder Guarantees that output SAM records are printed in an order corresponding to the order of the
      reads in the original input file, even when -p is set greater than 1. Specifying --reorder and setting
      -p greater than 1 causes Bowtie 2 to run somewhat slower and use somewhat more memory then if --reorder
      were not specified. Has no effect if -p is set to 1, since output order will naturally correspond to input
      order in that case.

stdout: $(inputs.one[0].nameroot + '.sam')

outputs:
  aligned-file:
    type: stdout

  # bowtie2-log:
  #   type: File
  #   outputBinding:
  #     glob: $(inputs.one + '.log')

baseCommand:
- bowtie2

# arguments:
# - valueFrom: $('2> ' + inputs.filename + '.log')
#   position: 100000
#   shellQuote: false

$namespaces:
  schema: http://schema.org/

$schemas:
- http://schema.org/docs/schema_org_rdfa.html

schema:mainEntity:
#  $import: https://scidap.com/description/tools/bowtie.yaml
  class: schema:SoftwareSourceCode
  schema:name: bowtie
  schema:about: 'Bowtie 2 is an ultrafast and memory-efficient tool for aligning sequencing reads
   to long reference sequences. It is particularly good at aligning reads of about 50 up to 100s
   or 1,000s of characters, and particularly good at aligning to relatively long (e.g. mammalian)
   genomes. Bowtie 2 indexes the genome with an FM Index to keep its memory footprint small: for
   the human genome, its memory footprint is typically around 3.2 GB. Bowtie 2 supports gapped,
   local, and paired-end alignment modes.'

  schema:url: http://bowtie-bio.sourceforge.net/bowtie2
  schema:codeRepository: https://github.com/BenLangmead/bowtie2.git

  schema:license:
  - https://opensource.org/licenses/GPL-3.0

  schema:targetProduct:
    class: schema:SoftwareApplication
    schema:softwareVersion: 2.3.2
    schema:applicationCategory: commandline tool
  schema:programmingLanguage: C++
  schema:publication:
  - class: schema:ScholarlyArticle
    id: http://dx.doi.org/10.1186/gb-2009-10-3-r25

# schema:isPartOf:
#   class: schema:CreativeWork
#   schema:name: Common Workflow Language
#   schema:url: http://commonwl.org/

# schema:author:
#   class: schema:Person
#   schema:name: Andrey Kartashov
#   schema:email: mailto:Andrey.Kartashov@cchmc.org
#   schema:sameAs:
#   - id: http://orcid.org/0000-0001-9102-5681
#   schema:worksFor:
#   - class: schema:Organization
#     schema:name: Cincinnati Children's Hospital Medical Center
#     schema:location: 3333 Burnet Ave, Cincinnati, OH 45229-3026
#     schema:department:
#     - class: schema:Organization
#       schema:name: Barski Lab
doc: "bowtie2.cwl is developed for CWL consortium"
