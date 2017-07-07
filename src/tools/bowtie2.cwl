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
    type: string
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

  very-fast:
    type: boolean?
    inputBinding:
      prefix: --very-fast
    doc: |
      --very-fast Same as: -D 5 -R 1 -N 0 -L 22 -i S,0,2.50

  fast:
    type: boolean?
    inputBinding:
      prefix: -fast
    doc: |
      --fast Same as: -D 10 -R 2 -N 0 -L 22 -i S,0,2.50

  sensitive:
    type: boolean?
    inputBinding:
      prefix: --sensitive
    doc: |
      --sensitive Same as: -D 15 -R 2 -L 22 -i S,1,1.15 (default in --end-to-end mode)

  very-sensitive:
    type: boolean?
    inputBinding:
      prefix: --very-sensitive
    doc: |
      --very-sensitive Same as: -D 20 -R 3 -N 0 -L 20 -i S,1,0.50

  very-fast-local:
    type: boolean?
    inputBinding:
      prefix: --very-fast-local
    doc: |
      --very-fast-local Same as: -D 5 -R 1 -N 0 -L 25 -i S,1,2.00

  fast-local:
    type: boolean?
    inputBinding:
      prefix: --fast-local
    doc: |
      --fast-local Same as: -D 10 -R 2 -N 0 -L 22 -i S,1,1.75

  sensitive-local:
    type: boolean?
    inputBinding:
      prefix: --sensitive-local
    doc: |
      --sensitive-local Same as: -D 15 -R 2 -N 0 -L 20 -i S,1,0.75 (default in --local mode)

  very-sensitive-local:
    type: boolean?
    inputBinding:
      prefix: --very-sensitive-local
    doc: |
      --very-sensitive-local Same as: -D 20 -R 3 -N 0 -L 20 -i S,1,0.50

  N:
    type: int?
    inputBinding:
      prefix: N
    doc: |
      -N <int> Sets the number of mismatches to allowed in a seed alignment during multiseed alignment.
      Can be set to 0 or 1. Setting this higher makes alignment slower (often much slower) but increases sensitivity.
      Default: 0.

  L:
    type: int?
    inputBinding:
      prefix: -L
    doc: |
      -L <int> Sets the length of the seed substrings to align during multiseed alignment. Smaller values make
      alignment slower but more sensitive. Default: the --sensitive preset is used by default, which sets
      -L to 20 both in --end-to-end mode and in --local mode.

  i:
    type: string?
    inputBinding:
      prefix: -i
    doc: |
      -i <func> Sets a function governing the interval between seed substrings to use during multiseed alignment. For
      instance, if the read has 30 characters, and seed length is 10, and the seed interval is 6, the seeds
      extracted will be:

        Read:      TAGCTACGCTCTACGCTATCATGCATAAAC
        Seed 1 fw: TAGCTACGCT
        Seed 1 rc: AGCGTAGCTA
        Seed 2 fw:       CGCTCTACGC
        Seed 2 rc:       GCGTAGAGCG
        Seed 3 fw:             ACGCTATCAT
        Seed 3 rc:             ATGATAGCGT
        Seed 4 fw:                   TCATGCATAA
        Seed 4 rc:                   TTATGCATGA

      Since it's best to use longer intervals for longer reads, this parameter sets the interval as a function of
      the read length, rather than a single one-size-fits-all number. For instance, specifying -i S,1,2.5 sets
      the interval function f to f(x) = 1 + 2.5 * sqrt(x), where x is the read length. See also: setting
      function options. If the function returns a result less than 1, it is rounded up to 1. Default: the
      --sensitive preset is used by default, which sets -i to S,1,1.15 in --end-to-end mode to -i S,1,0.75
      in --local mode.

  n-ceil:
    type: string?
    inputBinding:
      prefix: --n-ceil
    doc: |
      --n-ceil <func> Sets a function governing the maximum number of ambiguous characters (usually Ns and/or .s)
      allowed in a read as a function of read length. For instance, specifying -L,0,0.15 sets the N-ceiling
      function f to f(x) = 0 + 0.15 * x, where x is the read length. See also: setting function options.
      Reads exceeding this ceiling are filtered out. Default: L,0,0.15.

  dpad:
    type: int?
    inputBinding:
      prefix: --dpad
    doc: |
      --dpad <int> "Pads" dynamic programming problems by <int> columns on either side to allow gaps. Default: 15.

  gbar:
    type: int?
    inputBinding:
      prefix: --gbar
    doc: |
      --gbar <int> Disallow gaps within <int> positions of the beginning or end of the read. Default: 4.

  ignore-quals:
    type: boolean?
    inputBinding:
      prefix: --ignore-quals
    doc: |
      --ignore-quals When calculating a mismatch penalty, always consider the quality value at the mismatched position to
      be the highest possible, regardless of the actual value. I.e. input is treated as though all quality values
      are high. This is also the default behavior when the input doesn't specify quality values (e.g. in -f, -r,
      or -c modes).

  nofw:
    type: boolean?
    inputBinding:
      prefix: --nofw
    doc: |
      --nofw/--norc If --nofw is specified, bowtie2 will not attempt to align unpaired reads to the forward (Watson)
      reference strand. If --norc is specified, bowtie2 will not attempt to align unpaired reads against
      the reverse-complement (Crick) reference strand. In paired-end mode, --nofw and --norc pertain to the
      fragments; i.e. specifying --nofw causes bowtie2 to explore only those paired-end configurations
      corresponding to fragments from the reverse-complement (Crick) strand. Default: both strands enabled.

  norc:
    type: boolean?
    inputBinding:
      prefix: --norc
    doc: |
      --nofw/--norc If --nofw is specified, bowtie2 will not attempt to align unpaired reads to the forward (Watson)
      reference strand. If --norc is specified, bowtie2 will not attempt to align unpaired reads against
      the reverse-complement (Crick) reference strand. In paired-end mode, --nofw and --norc pertain to the
      fragments; i.e. specifying --nofw causes bowtie2 to explore only those paired-end configurations
      corresponding to fragments from the reverse-complement (Crick) strand. Default: both strands enabled.

  no-1mm-upfront:
    type: boolean?
    inputBinding:
      prefix: no-1mm-upfront
    doc: |
      --no-1mm-upfront By default, Bowtie 2 will attempt to find either an exact or a 1-mismatch end-to-end alignment for the
      read before trying the multiseed heuristic. Such alignments can be found very quickly, and many short
      read alignments have exact or near-exact end-to-end alignments. However, this can lead to
      unexpected alignments when the user also sets options governing the multiseed heuristic, like -L and
      -N. For instance, if the user specifies -N 0 and -L equal to the length of the read, the user will be
      surprised to find 1-mismatch alignments reported. This option prevents Bowtie 2 from searching for
      1-mismatch end-to-end alignments before using the multiseed heuristic, which leads to the expected
      behavior when combined with options such as -L and -N. This comes at the expense of speed.

  end-to-end:
    type: boolean?
    inputBinding:
      prefix: --end-to-end
    doc: |
      --end-to-end In this mode, Bowtie 2 requires that the entire read align from one end to the other, without any
      trimming (or "soft clipping") of characters from either end. The match bonus --ma always equals 0
      n this mode, so all alignment scores are less than or equal to 0, and the greatest possible alignment
      score is 0. This is mutually exclusive with --local. --end-to-end is the default mode.

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

  ma:
    type: int?
    inputBinding:
      prefix: -ma
    doc: |
      --ma <int> Sets the match bonus. In --local mode <int> is added to the alignment score for each position
      where a read character aligns to a reference character and the characters match. Not used in
      --end-to-end mode. Default: 2.

  mp:
    type:
      - "null"
      - type: record
        name: mp
        fields:
          min:
            type: int
          max:
            type: int
    inputBinding:
      valueFrom: --mp $(inputs.mp.min),$(inputs.mp.max)
    doc: |
      --mp MX,MN Sets the maximum (MX) and minimum (MN) mismatch penalties, both integers. A number less than
      or equal to MX and greater than or equal to MN is subtracted from the alignment score for each
      position where a read character aligns to a reference character, the characters do not match, and
      neither is an N. If --ignore-quals is specified, the number subtracted quals MX. Otherwise, the
      number subtracted is MN + floor( (MX-MN)(MIN(Q, 40.0)/40.0) ) where Q is the Phred quality
      value. Default: MX = 6, MN = 2.

  np:
    type: int?
    inputBinding:
      prefix: --np
    doc: |
      --np <int> Sets penalty for positions where the read, reference, or both, contain an ambiguous character such
      as N. Default: 1.

  rdg:
    type:
      - "null"
      - type: record
        name: rdg
        fields:
          gap-open:
            type: int
          extend:
            type: int
    inputBinding:
      valueFrom: --rdg $(inputs.rdg.gap-open),$(inputs.rdg.extend)
    doc: |
      --rdg <int1>,<int2> Sets the read gap open (<int1>) and extend (<int2>) penalties. A read gap of length N gets
      a penalty of <int1> + N * <int2>. Default: 5, 3.

  rfg:
    type:
      - "null"
      - type: record
        name: rfg
        fields:
          gap-open:
            type: int
          extend:
            type: int
    inputBinding:
      valueFrom: --rfg $(inputs.rfg.gap-open),$(inputs.rfg.extend)
    doc: |
      --rfg <int1>,<int2> Sets the reference gap open (<int1>) and extend (<int2>) penalties. A reference gap of length N
      gets a penalty of <int1> + N * <int2>. Default: 5, 3.

  score-min:
    type: string?
    inputBinding:
      prefix: --score-min
    doc: |
      --score-min <func> Sets a function governing the minimum alignment score needed for an alignment to be considered
      "valid" (i.e. good enough to report). This is a function of read length. For instance, specifying
      L,0,-0.6 sets the minimum-score function f to f(x) = 0 + -0.6 * x, where x is the read length.
      See also: setting function options. The default in --end-to-end mode is L,-0.6,-0.6 and the
      default in --local mode is G,20,8.

  k:
    type: int?
    inputBinding:
      prefix: -k
    doc: |
      -k <int> By default, bowtie2 searches for distinct, valid alignments for each read. When it finds a valid alignment, it
      continues looking for alignments that are nearly as good or better. The best alignment found is reported
      (randomly selected from among best if tied). Information about the best alignments is used to estimate
      mapping quality and to set SAM optional fields, such as AS:i and XS:i.

      When -k is specified, however, bowtie2 behaves differently. Instead, it searches for at most <int> distinct,
      valid alignments for each read. The search terminates when it can't find more distinct valid alignments, or when
      it finds <int>, whichever happens first. All alignments found are reported in descending order by alignment
      score. The alignment score for a paired-end alignment equals the sum of the alignment scores of the individual
      mates. Each reported read or pair alignment beyond the first has the SAM 'secondary' bit (which equals 256) set
      in its FLAGS field. For reads that have more than <int> distinct, valid alignments, bowtie2 does not guarantee
      that the <int> alignments reported are the best possible in terms of alignment score. -k is mutually exclusive
      with -a.

      Note: Bowtie 2 is not designed with large values for -k in mind, and when aligning reads to long, repetitive
      genomes large -k can be very, very slow.

  a:
    type: boolean?
    inputBinding:
      prefix: -a
    doc: |
      -a Like -k but with no upper limit on number of alignments to search for. -a is mutually exclusive with -k.

      Note: Bowtie 2 is not designed with -a mode in mind, and when aligning reads to long, repetitive genomes this
      mode can be very, very slow.

  D:
    type: int?
    inputBinding:
      prefix: -D
    doc: |
      -D <int> Up to <int> consecutive seed extension attempts can "fail" before Bowtie 2 moves on, using the alignments
      found so far. A seed extension "fails" if it does not yield a new best or a new second-best alignment. This limit is
      automatically adjusted up when -k or -a are specified. Default: 15.

  R:
    type: int?
    inputBinding:
      prefix: -R
    doc: |
      -R <int> <int> is the maximum number of times Bowtie 2 will "re-seed" reads with repetitive seeds. When "re-seeding,"
      Bowtie 2 simply chooses a new set of reads (same length, same number of mismatches allowed) at different
      offsets and searches for more alignments. A read is considered to have repetitive seeds if the total number of
      seed hits divided by the number of seeds that aligned at least once is greater than 300. Default: 2.

  minins:
    type: int?
    inputBinding:
      prefix: --minins
    doc: |
      -I/--minins <int> The minimum fragment length for valid paired-end alignments. E.g. if -I 60 is specified and a
      paired-end alignment consists of two 20-bp alignments in the appropriate orientation with a 20-bp gap
      between them, that alignment is considered valid (as long as -X is also satisfied). A 19-bp gap would
      not be valid in that case. If trimming options -3 or -5 are also used, the -I constraint is applied with
      respect to the untrimmed mates.

      The larger the difference between -I and -X, the slower Bowtie 2 will run. This is because larger
      differences between -I and -X require that Bowtie 2 scan a larger window to determine if a
      concordant alignment exists. For typical fragment length ranges (200 to 400 nucleotides), Bowtie 2 is
      very efficient.

      Default: 0 (essentially imposing no minimum)

  maxins:
    type: int?
    inputBinding:
      prefix: --maxins
    doc: |
      -X/--maxins <int> The maximum fragment length for valid paired-end alignments. E.g. if -X 100 is specified and a
      paired-end alignment consists of two 20-bp alignments in the proper orientation with a 60-bp gap
      between them, that alignment is considered valid (as long as -I is also satisfied). A 61-bp gap would
      not be valid in that case. If trimming options -3 or -5 are also used, the -X constraint is applied with
      espect to the untrimmed mates, not the trimmed mates.

      The larger the difference between -I and -X, the slower Bowtie 2 will run. This is because larger
      differences between -I and -X require that Bowtie 2 scan a larger window to determine if a
      oncordant alignment exists. For typical fragment length ranges (200 to 400 nucleotides), Bowtie 2 is
      very efficient.

      Default: 500.

  fr:
    type: boolean?
    inputBinding:
      prefix: --fr
    doc: |
      --fr/--rf/--ff The upstream/downstream mate orientations for a valid paired-end alignment against the forward
      reference strand. E.g., if --fr is specified and there is a candidate paired-end alignment where mate
      1 appears upstream of the reverse complement of mate 2 and the fragment length constraints (-I
      and -X) are met, that alignment is valid. Also, if mate 2 appears upstream of the reverse complement
      of mate 1 and all other constraints are met, that too is valid. --rf likewise requires that an upstream
      mate1 be reverse-complemented and a downstream mate2 be forward-oriented. --ff requires both
      an upstream mate 1 and a downstream mate 2 to be forward-oriented. Default: --fr (appropriate for
      Illumina's Paired-end Sequencing Assay).

  rf:
    type: boolean?
    inputBinding:
      prefix: --rf
    doc: |
      --fr/--rf/--ff The upstream/downstream mate orientations for a valid paired-end alignment against the forward
      reference strand. E.g., if --fr is specified and there is a candidate paired-end alignment where mate
      1 appears upstream of the reverse complement of mate 2 and the fragment length constraints (-I
      and -X) are met, that alignment is valid. Also, if mate 2 appears upstream of the reverse complement
      of mate 1 and all other constraints are met, that too is valid. --rf likewise requires that an upstream
      mate1 be reverse-complemented and a downstream mate2 be forward-oriented. --ff requires both
      an upstream mate 1 and a downstream mate 2 to be forward-oriented. Default: --fr (appropriate for
      Illumina's Paired-end Sequencing Assay).

  ff:
    type: boolean?
    inputBinding:
      prefix: --ff
    doc: |
      --fr/--rf/--ff The upstream/downstream mate orientations for a valid paired-end alignment against the forward
      reference strand. E.g., if --fr is specified and there is a candidate paired-end alignment where mate
      1 appears upstream of the reverse complement of mate 2 and the fragment length constraints (-I
      and -X) are met, that alignment is valid. Also, if mate 2 appears upstream of the reverse complement
      of mate 1 and all other constraints are met, that too is valid. --rf likewise requires that an upstream
      mate1 be reverse-complemented and a downstream mate2 be forward-oriented. --ff requires both
      an upstream mate 1 and a downstream mate 2 to be forward-oriented. Default: --fr (appropriate for
      Illumina's Paired-end Sequencing Assay).

  no-mixed:
    type: boolean?
    inputBinding:
      prefix: --no-mixed
    doc: |
      --no-mixed By default, when bowtie2 cannot find a concordant or discordant alignment for a pair, it then tries to
      find alignments for the individual mates. This option disables that behavior.

  no-discordant:
    type: boolean?
    inputBinding:
      prefix: no-mixed
    doc: |
      --no-discordant By default, bowtie2 looks for discordant alignments if it cannot find any concordant alignments.
      A discordant alignment is an alignment where both mates align uniquely, but that does not satisfy the
      paired-end constraints (--fr/--rf/--ff, -I, -X). This option disables that behavior.

  dovetail:
    type: boolean?
    inputBinding:
      prefix: --dovetail
    doc: |
      --dovetail If the mates "dovetail", that is if one mate alignment extends past the beginning of the other such
      that the wrong mate begins upstream, consider that to be concordant. See also: Mates can overlap,
      contain or dovetail each other. Default: mates cannot dovetail in a concordant alignment.

  no-contain:
    type: boolean?
    inputBinding:
      prefix: --dovetail
    doc: |
      --no-contain If one mate alignment contains the other, consider that to be non-concordant. See also: Mates can
      overlap, contain or dovetail each other. Default: a mate can contain the other in a concordant alignment.

  no-overlap:
    type: boolean?
    inputBinding:
      prefix: --no-overlap
    doc: |
      --no-overlap If one mate alignment overlaps the other at all, consider that to be non-concordant. See also: Mates
      can overlap, contain or dovetail each other. Default: mates can overlap in a concordant alignment.

  time:
    type: boolean?
    inputBinding:
      prefix: --time
    doc: |
      -t/--time Print the wall-clock time required to load the index files and align the reads. This is printed to the
      "standard error" ("stderr") filehandle. Default: off.

  un:
    type: string?
    inputBinding:
      prefix: --un
    doc: |
      --un/--un-gz/--un-bz2/--un-lz4 Write unpaired reads that fail to align to file at <path>. These reads
      correspond to the SAM records with the FLAGS 0x4 bit set and neither the 0x40 nor 0x80 bits set. If
      --un-gz is specified, output will be gzip compressed. If --un-bz2 or --un-lz4 is specified, output
      will be bzip2 or lz4 compressed. Reads written in this way will appear exactly as they did in the
      input file, without any modification (same sequence, same name, same quality string, same quality
      encoding). Reads will not necessarily appear in the same order as they did in the input.

  un-gz:
    type: string?
    inputBinding:
      prefix: --un-gz
    doc: |
      --un/--un-gz/--un-bz2/--un-lz4 Write unpaired reads that fail to align to file at <path>. These reads
      correspond to the SAM records with the FLAGS 0x4 bit set and neither the 0x40 nor 0x80 bits set. If
      --un-gz is specified, output will be gzip compressed. If --un-bz2 or --un-lz4 is specified, output
      will be bzip2 or lz4 compressed. Reads written in this way will appear exactly as they did in the
      input file, without any modification (same sequence, same name, same quality string, same quality
      encoding). Reads will not necessarily appear in the same order as they did in the input.

  un-bz2:
    type: string?
    inputBinding:
      prefix: --un-bz2
    doc: |
      --un/--un-gz/--un-bz2/--un-lz4 Write unpaired reads that fail to align to file at <path>. These reads
      correspond to the SAM records with the FLAGS 0x4 bit set and neither the 0x40 nor 0x80 bits set. If
      --un-gz is specified, output will be gzip compressed. If --un-bz2 or --un-lz4 is specified, output
      will be bzip2 or lz4 compressed. Reads written in this way will appear exactly as they did in the
      input file, without any modification (same sequence, same name, same quality string, same quality
      encoding). Reads will not necessarily appear in the same order as they did in the input.

  un-lz4:
    type: string?
    inputBinding:
      prefix: --un-lz4
    doc: |
      --un/--un-gz/--un-bz2/--un-lz4 Write unpaired reads that fail to align to file at <path>. These reads
      correspond to the SAM records with the FLAGS 0x4 bit set and neither the 0x40 nor 0x80 bits set. If
      --un-gz is specified, output will be gzip compressed. If --un-bz2 or --un-lz4 is specified, output
      will be bzip2 or lz4 compressed. Reads written in this way will appear exactly as they did in the
      input file, without any modification (same sequence, same name, same quality string, same quality
      encoding). Reads will not necessarily appear in the same order as they did in the input.

  al:
    type: string?
    inputBinding:
      prefix: --al
    doc: |
      --al/--al-gz/--al-bz2/--al-lz4 Write unpaired reads that align at least once to file at <path>.
      These reads correspond to the SAM records with the FLAGS 0x4, 0x40, and 0x80 bits unset. If --al-gz
      is specified, output will be gzip compressed. If --al-bz2 is specified, output will be bzip2 compressed.
      Similarly if --al-lz4 is specified, output will be lz4 compressed. Reads written in this way will appear
      exactly as they did in the input file, without any modification (same sequence, same name, same quality
      string, same quality encoding). Reads will not necessarily appear in the same order as they did in the input.

  al-gz:
    type: boolean?
    inputBinding:
      prefix: --al-gz
    doc: |
      --al/--al-gz/--al-bz2/--al-lz4 Write unpaired reads that align at least once to file at <path>.
      These reads correspond to the SAM records with the FLAGS 0x4, 0x40, and 0x80 bits unset. If --al-gz
      is specified, output will be gzip compressed. If --al-bz2 is specified, output will be bzip2 compressed.
      Similarly if --al-lz4 is specified, output will be lz4 compressed. Reads written in this way will appear
      exactly as they did in the input file, without any modification (same sequence, same name, same quality
      string, same quality encoding). Reads will not necessarily appear in the same order as they did in the input.

  al-bz2:
    type: string?
    inputBinding:
      prefix: --al-bz2
    doc: |
      --al/--al-gz/--al-bz2/--al-lz4 Write unpaired reads that align at least once to file at <path>.
      These reads correspond to the SAM records with the FLAGS 0x4, 0x40, and 0x80 bits unset. If --al-gz
      is specified, output will be gzip compressed. If --al-bz2 is specified, output will be bzip2 compressed.
      Similarly if --al-lz4 is specified, output will be lz4 compressed. Reads written in this way will appear
      exactly as they did in the input file, without any modification (same sequence, same name, same quality
      string, same quality encoding). Reads will not necessarily appear in the same order as they did in the input.

  al-lz4:
    type: string?
    inputBinding:
      prefix: --al-lz4
    doc: |
      --al/--al-gz/--al-bz2/--al-lz4 Write unpaired reads that align at least once to file at <path>.
      These reads correspond to the SAM records with the FLAGS 0x4, 0x40, and 0x80 bits unset. If --al-gz
      is specified, output will be gzip compressed. If --al-bz2 is specified, output will be bzip2 compressed.
      Similarly if --al-lz4 is specified, output will be lz4 compressed. Reads written in this way will appear
      exactly as they did in the input file, without any modification (same sequence, same name, same quality
      string, same quality encoding). Reads will not necessarily appear in the same order as they did in the input.

  un-conc:
    type: string?
    inputBinding:
      prefix: --un-conc
    doc: |
      --un-conc/--un-conc-gz/--un-conc-bz2/--un-conc-lz4 Write paired-end reads that fail to align concordantly
      to file(s) at <path>. These reads correspond to the SAM records with the FLAGS 0x4 bit set and either
      the 0x40 or 0x80 bit set (depending on whether it's mate #1 or #2). .1 and .2 strings are added to the
      filename to distinguish which file contains mate #1 and mate #2. If a percent symbol, %, is used in <path>,
      the percent symbol is replaced with 1 or 2 to make the per-mate filenames. Otherwise, .1 or .2 are added
      before the final dot in <path> to make the per-mate filenames. Reads written in this way will appear exactly
      as they did in the input files, without any modification (same sequence, same name, same quality string,
      same quality encoding). Reads will not necessarily appear in the same order as they did in the inputs.

  un-conc-gz:
    type: string?
    inputBinding:
      prefix: --un-conc-gz
    doc: |
      --un-conc/--un-conc-gz/--un-conc-bz2/--un-conc-lz4 Write paired-end reads that fail to align concordantly
      to file(s) at <path>. These reads correspond to the SAM records with the FLAGS 0x4 bit set and either
      the 0x40 or 0x80 bit set (depending on whether it's mate #1 or #2). .1 and .2 strings are added to the
      filename to distinguish which file contains mate #1 and mate #2. If a percent symbol, %, is used in <path>,
      the percent symbol is replaced with 1 or 2 to make the per-mate filenames. Otherwise, .1 or .2 are added
      before the final dot in <path> to make the per-mate filenames. Reads written in this way will appear exactly
      as they did in the input files, without any modification (same sequence, same name, same quality string,
      same quality encoding). Reads will not necessarily appear in the same order as they did in the inputs.

  un-conc-bz2:
    type: string?
    inputBinding:
      prefix: --un-conc-bz2
    doc: |
      --un-conc/--un-conc-gz/--un-conc-bz2/--un-conc-lz4 Write paired-end reads that fail to align concordantly
      to file(s) at <path>. These reads correspond to the SAM records with the FLAGS 0x4 bit set and either
      the 0x40 or 0x80 bit set (depending on whether it's mate #1 or #2). .1 and .2 strings are added to the
      filename to distinguish which file contains mate #1 and mate #2. If a percent symbol, %, is used in <path>,
      the percent symbol is replaced with 1 or 2 to make the per-mate filenames. Otherwise, .1 or .2 are added
      before the final dot in <path> to make the per-mate filenames. Reads written in this way will appear exactly
      as they did in the input files, without any modification (same sequence, same name, same quality string,
      same quality encoding). Reads will not necessarily appear in the same order as they did in the inputs.

  un-conc-lz4:
    type: string?
    inputBinding:
      prefix: --un-conc-lz4
    doc: |
      --un-conc/--un-conc-gz/--un-conc-bz2/--un-conc-lz4 Write paired-end reads that fail to align concordantly
      to file(s) at <path>. These reads correspond to the SAM records with the FLAGS 0x4 bit set and either
      the 0x40 or 0x80 bit set (depending on whether it's mate #1 or #2). .1 and .2 strings are added to the
      filename to distinguish which file contains mate #1 and mate #2. If a percent symbol, %, is used in <path>,
      the percent symbol is replaced with 1 or 2 to make the per-mate filenames. Otherwise, .1 or .2 are added
      before the final dot in <path> to make the per-mate filenames. Reads written in this way will appear exactly
      as they did in the input files, without any modification (same sequence, same name, same quality string,
      same quality encoding). Reads will not necessarily appear in the same order as they did in the inputs.

  al-conc:
    type: string?
    inputBinding:
      prefix: --al-conc
    doc: |
      --al-conc/--al-conc-gz/--al-conc-bz2/--al-conc-lz4 Write paired-end reads that align concordantly at least
      once to file(s) at <path>. These reads correspond to the SAM records with the FLAGS 0x4 bit unset and either
      the 0x40 or 0x80 bit set (depending on whether it's mate #1 or #2). .1 and .2 strings are added to the
      filename to distinguish which file contains mate #1 and mate #2. If a percent symbol, %, is used in <path>,
      the percent symbol is replaced with 1 or 2 to make the per-mate filenames. Otherwise, .1 or .2 are added
      before the final dot in <path> to make the per-mate filenames. Reads written in this way will appear exactly
      as they did in the input files, without any modification (same sequence, same name, same quality string, same
      quality encoding). Reads will not necessarily appear in the same order as they did in the inputs.

  al-conc-gz:
    type: string?
    inputBinding:
      prefix: --al-conc-gz
    doc: |
      --al-conc/--al-conc-gz/--al-conc-bz2/--al-conc-lz4 Write paired-end reads that align concordantly at least
      once to file(s) at <path>. These reads correspond to the SAM records with the FLAGS 0x4 bit unset and either
      the 0x40 or 0x80 bit set (depending on whether it's mate #1 or #2). .1 and .2 strings are added to the
      filename to distinguish which file contains mate #1 and mate #2. If a percent symbol, %, is used in <path>,
      the percent symbol is replaced with 1 or 2 to make the per-mate filenames. Otherwise, .1 or .2 are added
      before the final dot in <path> to make the per-mate filenames. Reads written in this way will appear exactly
      as they did in the input files, without any modification (same sequence, same name, same quality string, same
      quality encoding). Reads will not necessarily appear in the same order as they did in the inputs.

  al-conc-bz2:
    type: string?
    inputBinding:
      prefix: --al-conc-bz2
    doc: |
      --al-conc/--al-conc-gz/--al-conc-bz2/--al-conc-lz4 Write paired-end reads that align concordantly at least
      once to file(s) at <path>. These reads correspond to the SAM records with the FLAGS 0x4 bit unset and either
      the 0x40 or 0x80 bit set (depending on whether it's mate #1 or #2). .1 and .2 strings are added to the
      filename to distinguish which file contains mate #1 and mate #2. If a percent symbol, %, is used in <path>,
      the percent symbol is replaced with 1 or 2 to make the per-mate filenames. Otherwise, .1 or .2 are added
      before the final dot in <path> to make the per-mate filenames. Reads written in this way will appear exactly
      as they did in the input files, without any modification (same sequence, same name, same quality string, same
      quality encoding). Reads will not necessarily appear in the same order as they did in the inputs.

  al-conc-lz4:
    type: string?
    inputBinding:
      prefix: --al-conc-lz4
    doc: |
      --al-conc/--al-conc-gz/--al-conc-bz2/--al-conc-lz4 Write paired-end reads that align concordantly at least
      once to file(s) at <path>. These reads correspond to the SAM records with the FLAGS 0x4 bit unset and either
      the 0x40 or 0x80 bit set (depending on whether it's mate #1 or #2). .1 and .2 strings are added to the
      filename to distinguish which file contains mate #1 and mate #2. If a percent symbol, %, is used in <path>,
      the percent symbol is replaced with 1 or 2 to make the per-mate filenames. Otherwise, .1 or .2 are added
      before the final dot in <path> to make the per-mate filenames. Reads written in this way will appear exactly
      as they did in the input files, without any modification (same sequence, same name, same quality string, same
      quality encoding). Reads will not necessarily appear in the same order as they did in the inputs.

  quiet:
    type: boolean?
    inputBinding:
      prefix: --quiet
    doc: |
      --quiet Print nothing besides alignments and serious errors.

  met-file:
    type: string?
    inputBinding:
      prefix: --met-file
    doc: |
      --met-file <path> Write bowtie2 metrics to file <path>. Having alignment metric can be useful for debugging
      certain problems, especially performance issues. See also: --met. Default: metrics disabled.

  met-stderr:
    type: string?
    inputBinding:
      prefix: --met-stderr
    doc: |
      --met-stderr <path> Write bowtie2 metrics to the "standard error" ("stderr") filehandle. This is not mutually
      exclusive with --met-file. Having alignment metric can be useful for debugging certain problems, especially
      performance issues. See also: --met. Default: metrics disabled.

  met:
    type: int?
    inputBinding:
      prefix: --met
    doc: |
      --met <int> Write a new bowtie2 metrics record every <int> seconds. Only matters if either --met-stderr
      or --met-file are specified. Default: 1.

  no-qual:
    type: boolean?
    inputBinding:
      prefix: --no-qual
    doc: |
      --no-unal Suppress SAM records for reads that failed to align.

  no-hd:
    type: boolean?
    inputBinding:
      prefix: --no-hd
    doc: |
      --no-hd Suppress SAM header lines (starting with @).

  no-sq:
    type: boolean?
    inputBinding:
      prefix: --no-sq
    doc: |
      --no-sq Suppress @SQ SAM header lines.

  rg-id:
    type: string?
    inputBinding:
      prefix: --rg-id
    doc: |
      --rg-id <text> Set the read group ID to <text>. This causes the SAM @RG header line to be printed, with
      <text> as the value associated with the ID: tag. It also causes the RG:Z: extra field to be attached to
      each SAM output record, with value set to <text>.

  rg:
    type: string?
    inputBinding:
      prefix: --rg
    doc: |
      --rg <text> Add <text> (usually of the form TAG:VAL, e.g. SM:Pool1) as a field on the @RG header line.
      Note: in order for the @RG line to appear, --rg-id must also be specified. This is because the ID tag
      is required by the SAM Spec. Specify --rg multiple times to set multiple fields. See the SAM Spec for
      details about what fields are legal.

  omit-sec-seq:
    type: boolean?
    inputBinding:
      prefix: --omit-sec-seq
    doc: |
      --omit-sec-seq When printing secondary alignments, Bowtie 2 by default will write out the SEQ and QUAL
      strings. Specifying this option causes Bowtie 2 to print an asterisk in those fields instead.

  offrate:
    type: int?
    inputBinding:
      prefix: --offrate
    doc: |
      -o/--offrate <int> Override the offrate of the index with <int>. If <int> is greater than the offrate used
      to build the index, then some row markings are discarded when the index is read into memory. This reduces
      the memory footprint of the aligner but requires more time to calculate text offsets. <int> must be greater
      than the value used to build the index.

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

  mm:
    type: boolean?
    inputBinding:
      prefix: --mm
    doc: |
      --mm Use memory-mapped I/O to load the index, rather than typical file I/O. Memory-mapping allows
      many concurrent bowtie processes on the same computer to share the same memory image of
      the index (i.e. you pay the memory overhead just once). This facilitates memory-efficient
      parallelization of bowtie in situations where using -p is not possible or not preferable.

  qc-filter:
    type: boolean?
    inputBinding:
      prefix: --qc-filter
    doc: |
      --qc-filter Filter out reads for which the QSEQ filter field is non-zero. Only has an effect when read format
      is --qseq. Default: off.

  seed:
    type: int?
    inputBinding:
      prefix: --seed
    doc: |
      --seed <int> Use <int> as the seed for pseudo-random number generator. Default: 0.

  non-deterministic:
    type: boolean?
    inputBinding:
      prefix: --non-deterministic
    doc: |
      --non-deterministic Normally, Bowtie 2 re-initializes its pseudo-random generator for each read. It seeds
      the generator with a number derived from (a) the read name, (b) the nucleotide sequence, (c) the quality
      sequence, (d) the value of the --seed option. This means that if two reads are identical (same name, same
      nucleotides, same qualities) Bowtie 2 will find and report the same alignment(s) for both, even if there
      was ambiguity. When --non-deterministic is specified, Bowtie 2 re-initializes its pseudo-random generator
      for each read using the current time. This means that Bowtie 2 will not necessarily report the same alignment
      for two identical reads. This is counter-intuitive for some users, but might be more appropriate in situations
      where the input consists of many identical reads.

# stdout: $(inputs.one[0].nameroot + '.sam')

outputs:
  aligned-file:
    type: File
    outputBinding:
      glob: $(inputs.samout)

baseCommand:
- bowtie2

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
