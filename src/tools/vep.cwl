#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
- $import: envvar-global.yml
#- $import: samtools-docker.yml
- class: InlineJavascriptRequirement

baseCommand: vep

inputs:
  quiet:
    type: boolean?
    inputBinding:
      prefix: --quiet
    doc: |
      --quiet, -q Suppress warning messages. Not used by default

  config:
    type: string?
    inputBinding:
      prefix: --config
    doc: |
      --config [filename] Load configuration options from a config file. The config file should consist of
      whitespace-separated pairs of option names and settings e.g.:
        output_file   my_output.txt
        species       mus_musculus
        format        vcf
        host          useastdb.ensembl.org
      A config file can also be implicitly read; save the file as $HOME/.vep/vep.ini (or equivalent directory
      if using --dir). Any options in this file will be overridden by those specified in a config file using
      --config, and in turn by any options manually specified on the command line. You can create a quick
      version file of this by setting the flags as normal and running the script in verbose (-v) mode. This
      will output lines that can be copied to a config file that can be loaded in on the next run using --config.
      Not used by default

  everything:
    type: boolean?
    inputBinding:
      prefix: --everything
    doc: |
      --everything  Shortcut flag to switch on all of the following:
           --sift b, --polyphen b, --ccds, --uniprot, --hgvs, --symbol, --numbers, --domains, --regulatory,
            --canonical, --protein, --biotype, --uniprot, --tsl, --appris, --gene_phenotype --af, --af_1kg,
            --af_esp, --af_exac, --max_af, --pubmed, --variant_class

  fork:
    type: int?
    inputBinding:
      prefix: --fork
    doc: |
      --fork [num_forks]  Enable forking, using the specified number of forks. Forking can dramatically improve
      the runtime of the script. Not used by default

  species:
    type: string?
    inputBinding:
      prefix: --species
    doc: |
      --species [species] Species for your data. This can be the latin name e.g. "homo_sapiens" or any Ensembl
      alias e.g. "mouse". Specifying the latin name can speed up initial database connection as the registry
      does not have to load all available database aliases on the server. Default = "homo_sapiens"

  assembly:
    type: string?
    inputBinding:
      prefix: --assembly
    doc: |
      --assembly [name] -i Select the assembly version to use if more than one available. If using the cache,
      you must have the appropriate assembly's cache file installed. If not specified and you have only 1
      assembly version installed, this will be chosen by default. Default = use found assembly version

  input_file:
    type: File?
    inputBinding:
      prefix: --input_file
    doc: |
      --input_file [filename] -i Input file name. If not specified, the script will attempt to read from STDIN.

  format:
    type:
    - "null"
    - type: enum
      symbols: ["ensembl", "vcf", "hgvs", "id"]
    inputBinding:
      prefix: --format
    doc: |
      --format [format] Input file format - one of "ensembl", "vcf", "hgvs", "id". By default, the script
      auto-detects the input file format. Using this option you can force the script to read the input
      file as Ensembl, VCF, IDs or HGVS. Auto-detects format by default

  output_file:
    type: string?
    inputBinding:
      prefix: --output_file
    doc: |
      --output_file [filename] -o Output file name. The script can write to STDOUT by specifying STDOUT as
      the output file name - this will force quiet mode. Default = "variant_effect_output.txt"

  force_overwrite:
    type: boolean?
    inputBinding:
      prefix: --force_overwrite
    doc: |
      --force_overwrite --force By default, the script will fail with an error if the output file already
      exists. You can force the overwrite of the existing file by using this flag. Not used by default

  no_stats:
    type: boolean?
    inputBinding:
      prefix: --no_stats
    doc: |
      --no_stats Don't generate a stats file. Provides marginal gains in run time.


  stats_text:
    type: string?
    inputBinding:
      prefix: --stats_text
    doc: |
      --stats_text  Generate a plain text stats file in place of the HTML.

  cache:
    type: boolean?
    inputBinding:
      prefix: --cache
    doc: |
      --cache  Enables use of the cache. Add --refseq or --merged to use the refseq or merged cache, (if installed).

  dir:
    type: string?
    inputBinding:
      prefix: --dir
    doc: |
      --dir [directory] Specify the base cache/plugin directory to use. Default = "$HOME/.vep/"

  dir_cache:
    type: string?
    inputBinding:
      prefix: --dir_cache
    doc: |
      --dir_cache [directory] Specify the cache directory to use. Default = "$HOME/.vep/"

  dir_plugins:
    type: Directory?
    inputBinding:
      prefix: --dir_plugins
    doc: |
      --dir_plugins [directory] Specify the plugin directory to use. Default = "$HOME/.vep/"

  offline:
    type: boolean?
    inputBinding:
      prefix: --offline
    doc: |
      --offline  Enable offline mode. No database connections will be made, and a cache file or GFF/GTF file
      is required for annotation. Add --refseq to use the refseq cache (if installed). Not used by default

  fasta:
    type: string
    inputBinding:
      prefix: --fasta
    doc: |
      --fasta [file|dir] Specify a FASTA file or a directory containing FASTA files to use to look up reference
      sequence. The first time you run the script with this parameter an index will be built which can take a few
      minutes. This is required if fetching HGVS annotations (--hgvs) or checking reference sequences (--check_ref)
      in offline mode (--offline), and optional with some performance increase in cache mode (--cache). See
      documentation for more details. Not used by default

  refseq:
    type: boolean?
    inputBinding:
      prefix: --refseq
    doc: |
      --refseq Specify this option if you have installed the RefSeq cache in order for VEP to pick up the
      alternate cache directory. This cache contains transcript objects corresponding to RefSeq transcripts
      (to include CCDS and Ensembl ESTs also, use --all_refseq). Consequence output will be given relative
      to these transcripts in place of the default Ensembl transcripts (see documentation)

  merged:
    type: boolean?
    inputBinding:
      prefix: --merged
    doc: |
      --merged Use the merged Ensembl and RefSeq cache. Consequences are flagged with the SOURCE of each
      transcript used.

  cache_version:
    type: string?
    inputBinding:
      prefix: --cache_version
    doc: |
      --cache_version Use a different cache version than the assumed default (the VEP version). This should be
      used with Ensembl Genomes caches since their version numbers do not match Ensembl versions. For example,
      the VEP/Ensembl version may be 88 and the Ensembl Genomes version 35. Not used by default

  show_cache_info:
    type: boolean?
    inputBinding:
      prefix: --show_cache_info
    doc: |
      --show_cache_info Show source version information for selected cache and quit

  buffer_size:
    type: int?
    inputBinding:
      prefix: buffer_size
    doc: |
      --buffer_size [number] Sets the internal buffer size, corresponding to the number of variants that are
      read in to memory simultaneously. Set this lower to use less memory at the expense of longer run time,
      and higher to use more memory with a faster run time. Default = 5000

  plugin:
    type: string?
    inputBinding:
      prefix: --plugin
    doc: |
      --plugin [plugin name] Use named plugin. Plugin modules should be installed in the Plugins subdirectory
      of the VEP cache directory (defaults to $HOME/.vep/). Multiple plugins can be used by supplying the
      --plugin flag multiple times. See plugin documentation. Not used by default

  custom:
    type: File?
    inputBinding:
      prefix: --custom
    doc: |
      --custom [filename] Add custom annotation to the output. Files must be tabix indexed or in the bigWig
      format. Multiple files can be specified by supplying the --custom flag multiple times. See here for
      full details. Not used by default

  gff:
    type: File?
    inputBinding:
      prefix: --gff
    doc: |
      --gff [filename] Use GFF transcript annotations in [filename] as an annotation source. Requires a FASTA
      file of genomic sequence.Not used by default

  gtf:
    type: File?
    inputBinding:
      prefix: --gtd
    doc: |
      --gtf [filename] Use GTF transcript annotations in [filename] as an annotation source. Requires a
      FASTA file of genomic sequence.Not used by default

  bam:
    type: File?
    inputBinding:
      prefix: --bam
    doc: |
      --bam [filename] ADVANCED Use BAM file of sequence alignments to correct transcript models not
      derived from reference genome sequence. Used to correct RefSeq transcript models Not used by default

  variant_class:
    type: boolean?
    inputBinding:
      prefix: --variant_class
    doc: |
      --variant_class Output the Sequence Ontology variant class. Not used by default

  sift:
    type:
    - "null"
    - type: enum
      symbols: ['p', 's', 'b']
    inputBinding:
      prefix: --sift
    doc: |
      --sift [p|s|b]  Species limited SIFT predicts whether an amino acid substitution affects protein
      function based on sequence homology and the physical properties of amino acids. VEP can output the
      prediction term, score or both. Not used by default

  polyphen:
    type:
    - "null"
    - type: enum
      symbols: ['p', 's', 'b']
    inputBinding:
      prefix: --polyphen
    doc: |
      --polyphen [p|s|b] --poly Human only PolyPhen is a tool which predicts possible impact of an amino
      acid substitution on the structure and function of a human protein using straightforward physical
      and comparative considerations. VEP can output the prediction term, score or both. VEP uses the
      humVar score by default - use --humdiv to retrieve the humDiv score. Not used by default

  nearest:
    type:
    - "null"
    - type: enum
      symbols: ['transcript', 'gene', 'symbol']
    inputBinding:
      prefix: --nearest
    doc: |
      --nearest [transcript|gene|symbol] Retrieve the transcript or gene with the nearest protein-coding
      transcription start site (TSS) to each input variant. Use "transcript" to retrieve the transcript
      stable ID, "gene" to retrieve the gene stable ID, or "symbol" to retrieve the gene symbol. Note
      that the nearest TSS may not belong to a transcript that overlaps the input variant, and more than
      one may be reported in the case where two are equidistant from the input coordinates.

      Currently only available when using a cache annotation source, and requires the Set::IntervalTree
      perl module.

      Not used by default

  humdiv:
    type: boolean?
    inputBinding:
      prefix: --humdiv
    doc: |
      --humdiv  Human only Retrieve the humDiv PolyPhen prediction instead of the default humVar. Not
      used by default

  gene_phenotype:
    type: boolean?
    inputBinding:
      prefix: --gene_phenotype
    doc: |
      --gene_phenotype Indicates if the overlapped gene is associated with a phenotype, disease or trait.
      See list of phenotype sources. Not used by default

  regulatory:
    type: boolean?
    inputBinding:
      prefix: --regulatory
    doc: |
      --regulatory Look for overlaps with regulatory regions. The script can also call if a variant falls
      in a high information position within a transcription factor binding site. Output lines have a Feature
      type of RegulatoryFeature or MotifFeature. Not used by default

  cell_type:
    type: boolean?
    inputBinding:
      prefix: --cell_type
    doc: |
      --cell_type Report only regulatory regions that are found in the given cell type(s). Can be a single
      cell type or a comma-separated list. The functional type in each cell type is reported under CELL_TYPE
      in the output. To retrieve a list of cell types, use --cell_type list. Not used by default

  individual:
    type:
    - "null"
    - type: enum
      symbols: [all', 'ind list']
    inputBinding:
      prefix: --individual
    doc: |
      --individual [all|ind list] Consider only alternate alleles present in the genotypes of the specified
      individual(s). May be a single individual, a comma-separated list or "all" to assess all individuals separately. Individual variant combinations homozygous for the given reference allele will not be reported. Each individual and variant combination is given on a separate line of output. Only works with VCF files containing individual genotype data; individual IDs are taken from column headers. Not used by default

  phased:
    type: boolean?
    inputBinding:
      prefix: --phased
    doc: |
      --phased  Force VCF genotypes to be interpreted as phased. For use with plugins that depend on phased
      data. Not used by default

  allele_number:
    type: int?
    inputBinding:
      prefix: --allele_number
    doc: |
      --allele_number  Identify allele number from VCF input, where 1 = first ALT allele, 2 = second ALT
      allele etc. Useful when using --minimal Not used by default

  total_length:
    type: int?
    inputBinding:
      prefix: --total_length
    doc: |
      --total_length  Give cDNA, CDS and protein positions as Position/Length. Not used by default

  numbers:
    type: boolean?
    inputBinding:
      prefix: --numbers
    doc: |
      --numbers  Adds affected exon and intron numbering to to output. Format is Number/Total. Not used by default

  domains:
    type: boolean?
    inputBinding:
      prefix: --domains
    doc: |
      --domains  Adds names of overlapping protein domains to output. Not used by default

  no_escape:
    type: boolean?
    inputBinding:
      prefix: --no_escape
    doc: |
      --no_escape  Don't URI escape HGVS strings. Default = escape

  keep_csq:
    type: boolean?
    inputBinding:
      prefix: --keep_csq
    doc: |
      --keep_csq Don't overwrite existing CSQ entry in VCF INFO field. Overwrites by default

  vcf_info_field:
    type: string?
    inputBinding:
      prefix: --vcf_info_field
    doc: |
      --vcf_info_field [CSQ|ANN|(other)] Change the name of the INFO key that VEP write the consequences to
      in its VCF output. Use "ANN" for compatibility with other tools such as snpEff. Default: CSQ

  terms:
    type:
    - "null"
    - type: enum
      symbols: ['ensembl', 'so']
    inputBinding:
      prefix: -terms
    doc: |
      --terms [ensembl|so] -t The type of consequence terms to output. The Ensembl terms are described here.
      The Sequence Ontology is a joint effort by genome annotation centres to standardise descriptions of
      biological sequences. Default = "SO"

  hgvs:
    type: boolean?
    inputBinding:
      prefix: --hgvs
    doc: |
      --hgvs  Add HGVS nomenclature based on Ensembl stable identifiers to the output. Both coding and protein
      sequence names are added where appropriate. To generate HGVS identifiers when using --cache or --offline
      you must use a FASTA file and --fasta. HGVS notations given on Ensembl identifiers are versioned. Not used
      by default

  hgvsg:
    type: boolean?
    inputBinding:
      prefix:
    doc: |
      --hgvsg  Add genomic HGVS nomenclature based on the input chromosome name. To generate HGVS identifiers
      when using --cache or --offline you must use a FASTA file and --fasta. Not used by default

  shift_hgvs:
    type:
    - "null"
    - type: enum
      symbols: ['0', '1']
    inputBinding:
      prefix: --shift_hgvs
    doc: |
      --shift_hgvs [0|1]  Enable or disable 3' shifting of HGVS notations. When enabled, this causes ambiguous
      insertions or deletions (typically in repetetive sequence tracts) to be "shifted" to their most 3'
      possible coordinates (relative to the transcript sequence and strand) before the HGVS notations are
      calculated; the flag HGVS_OFFSET is set to the number of bases by which the variant has shifted,
      relative to the input genomic coordinates. Disabling retains the original input coordinates of the
      variant. Default: 1 (shift)

  protein:
    type: boolean?
    inputBinding:
      prefix: --protein
    doc:
      --protein  Add the Ensembl protein identifier to the output where appropriate. Not used by default

  symbol:
    type: boolean?
    inputBinding:
      prefix: --symbol
    doc: |
      --symbol  Adds the gene symbol (e.g. HGNC) (where available) to the output. Not used by default

  ccds:
    type: boolean?
    inputBinding:
      prefix: --ccds
    doc: |
      --ccds  Adds the CCDS transcript identifer (where available) to the output. Not used by default

  uniprot:
    type: boolean?
    inputBinding:
      prefix: --uniprot
    doc: |
      --uniprot  Adds best match accessions for translated protein products from three UniProt-related
      databases (SWISSPROT, TREMBL and UniParc) to the output. Not used by default

  tsl:
    type: boolean?
    inputBinding:
      prefix: --tsl
    doc: |
      --tsl  Adds the transcript support level for this transcript to the output. NB: not available for
      GRCh37.Not used by default

  appris:
    type: boolean?
    inputBinding:
      prefix:
    doc: |
      --appris  Adds the APPRIS isoform annotation for this transcript to the output. NB: not available for
      GRCh37.Not used by default

  canonical:
    type: boolean?
    inputBinding:
      prefix: --canonical
    doc: |
      --canonical  Adds a flag indicating if the transcript is the canonical transcript for the gene. Not used
      by default

  biotype:
    type: boolean?
    inputBinding:
      prefix: --biotype
    doc: |
      --biotype  Adds the biotype of the transcript or regulatory feature. Not used by default

  xref_refseq:
    type: boolean?
    inputBinding:
      prefix: --xref_refseq
    doc: |
      --xref_refseq  Output aligned RefSeq mRNA identifier for transcript. NB: theRefSeq and Ensembl transcripts a
      ligned in this way MAY NOT, AND FREQUENTLY WILL NOT, match exactly in sequence, exon structure and protein product. Not used by default

  synonyms:
    type: File?
    inputBinding:
      prefix: --synonyms
    doc: |
      --synonyms [file]  Load a file of chromosome synonyms. File should be tab-delimited with the primary
      identifier in column 1 and the synonym in column 2. Synonyms are used bi-directionally so columns may
      be switched. Synoyms allow different chromosome identifiers to be used in the input file and any annotation
      source (cache, database, GFF, custom file, FASTA file). Not used by default

  check_existing:
    type: boolean?
    inputBinding:
      prefix: --check_existing
    doc: |
      --check_existing Checks for the existence of known variants that are co-located with your input. By default the
      alleles are compared - to compare only coordinates, use --no_check_alleles.

      Some databases may contain variants with unknown (null) alleles and these are included by default; to exclude
      them use --exclude_null_alleles.

      Not used by default

  exclude_null_alleles:
    type: boolean?
    inputBinding:
      prefix: --exclude_null_alleles
    doc: |
      --exclude_null_alleles  Do not include variants with unknown alleles when checking for co-located variants.
      The human variation database contains variants from HGMD and COSMIC for which the alleles are not publically
      available; by default these are included when using --check_existing, use this flag to exclude them. Not used
      by default

  no_check_alleles:
    type: boolean?
    inputBinding:
      prefix: --no_check_alleles
    doc: |
      --no_check_alleles  When checking for existing variants, by default VEP only reports a co-located variant if
      none of the input alleles are novel. For example, if the user input has alleles A/G, and an existing
      co-located variant has alleles A/C, the co-located variant will not be reported.

      Strand is also taken into account - in the same example, if the user input has alleles T/G but on the negative
      strand, then the co-located variant will be reported since its alleles match the reverse complement of user input.

      Use this flag to disable this behaviour and compare using coordinates alone. Not used by default

  af:
    type: boolean?
    inputBinding:
      prefix: --af
    doc: |
      --af  Add the global allele frequency (AF) from 1000 Genomes Phase 3 data for any known co-located variant
      to the output. For this and all --af_* flags, the frequency reported is for the input allele only, not
      necessarily the non-reference or derived allele Not used by default

  max_af:
    type: boolean?
    inputBinding:
      prefix: --max_af
    doc: |
      --max_af  Report the highest allele frequency observed in any population from 1000 genomes, ESP or ExAC.
      Not used by default

  af_1kg:
    type: boolean?
    inputBinding:
      prefix: --af_1kg
    doc: |
      --af_1kg  Add allele frequency from continental populations (AFR,AMR,EAS,EUR,SAS) of 1000 Genomes Phase 3
      to the output. Must be used with --cache Not used by default

  af_esp:
    type: boolean?
    inputBinding:
      prefix: --af_esp
    doc: |
      --af_esp  Include allele frequency from NHLBI-ESP populations. Must be used with --cache Not used by default

  af_exac:
    type: boolean?
    inputBinding:
      prefix: --af_exac
    doc: |
      --af_exac Include allele frequency from ExAC project populations. Must be used with --cache Not used by default

  pubmed:
    type: boolean?
    inputBinding:
      prefix: --pubmed
    doc: |
      --pubmed  Report Pubmed IDs for publications that cite existing variant. Must be used with --cache.
      Not used by default

  failed:
    type:
    - "null"
    - type: enum
      symbols: ['0', '1']
    inputBinding:
      prefix: --failed
    doc: |
      --failed [0|1]  When checking for co-located variants, by default the script will exclude variants that
      have been flagged as failed. Set this flag to include such variants. Default: 0 (exclude)

  vcf:
    type: boolean?
    inputBinding:
      prefix: --vcf
    doc: |
      --vcf  Writes output in VCF format. Consequences are added in the INFO field of the VCF file, using the
      key "CSQ". Data fields are encoded separated by "|"; the order of fields is written in the VCF header.
      Output fields can be selected by using --fields.

      If the input format was VCF, the file will remain unchanged save for the addition of the CSQ field
      (unless using any filtering).

      Custom data added with --custom are added as separate fields, using the key specified for each data file.

      Commas in fields are replaced with ampersands (&) to preserve VCF format.

      Not used by default

  tab:
    type: boolean?
    inputBinding:
      prefix: --tab
    doc: |
      --tab Writes output in tab-delimited format. Not used by default

  json:
    type: boolean?
    inputBinding:
      prefix: --json
    doc: |
      --json  Writes output in JSON format. Not used by default

  compress_output:
    type:
    - "null"
    - type: enum
      symbols: [gzip, bgzip]
    inputBinding:
      prefix: --compress_output
    doc: |
      --compress_output [gzip|bgzip]  Writes output compressed using either gzip or bgzip. Not used by default

  fields:
    type: string?
    inputBinding:
      prefix: --fields
    doc: |
      --fields [list]  Configure the output format using a comma separated list of fields. Fields may be those
      present in the default output columns, or any of those that appear in the Extra column (including those
      added by plugins or custom annotations). Output remains tab-delimited. Can only be used with tab or VCF
      format output. Not used by default

  minimal:
    type: boolean?
    inputBinding:
      prefix: --minimal
    doc: |
      --minimal  Convert alleles to their most minimal representation before consequence calculation i.e.
      sequence that is identical between each pair of reference and alternate alleles is trimmed off from
      both ends, with coordinates adjusted accordingly. Note this may lead to discrepancies between input
      coordinates and coordinates reported by VEP relative to transcript sequences; to avoid issues, use
      --allele_number and/or ensure that your input variants have unique identifiers. The MINIMISED flag
      is set in the VEP output where relevant. Not used by defaut

  gencode_basic:
    type: boolean?
    inputBinding:
      prefix: --gencode_basic
    doc: |
      --gencode_basic  Limit your analysis to transcripts belonging to the GENCODE basic set. This set has
      fragmented or problematic transcripts removed. Not used by default

  all_refseq:
    type: boolean?
    inputBinding:
      prefix: --all_refseq
    doc: |
      --all_refseq  When using the RefSeq or merged cache, include e.g. CCDS and Ensembl EST transcripts
      in addition to those from RefSeq (see documentation). Only works when using --refseq or --merged

  exclude_predicted:
    type: boolean?
    inputBinding:
      prefix: --exclude_predicted
    doc: |
      --exclude_predicted  When using the RefSeq or merged cache, exclude predicted transcripts (i.e.
      those with identifiers beginning with "XM_" or "XR_").

  transcript_filter:
    type: string?
    inputBinding:
      prefix: --transcript_filter
    doc: |
      --transcript_filter ADVANCED Filter transcripts according to any arbitrary set of rules. Uses similar
      notation to filter_vep.

      You may filter on any key defined in the root of the transcript object; most commonly this will be
      "stable_id":

      --transcript_filter "stable_id match N[MR]_"

  check_ref:
    type: boolean?
    inputBinding:
      prefix: --check_ref
    doc: |
      --check_ref  Force the script to check the supplied reference allele against the sequence stored in
      the Ensembl Core database or supplied FASTA file. Lines that do not match are skipped. Not used by default

  dont_skip:
    type: boolean?
    inputBinding:
      prefix: --dont_skip
    doc: |
      --dont_skip  Don't skip input variants that fail validation, e.g. those that fall on unrecognised sequences

  allow_non_variant:
    type: boolean?
    inputBinding:
      prefix: allow_non_variant
    doc: |
      --allow_non_variant  When using VCF format as input and output, by default VEP will skip non-variant
      lines of input (where the ALT allele is null). Enabling this option the lines will be printed in the
      VCF output with no consequence data added.

  chr:
    type: string?
    inputBinding:
      prefix: --chr
    doc: |
      --chr [list]  Select a subset of chromosomes to analyse from your file. Any data not on this chromosome
      in the input will be skipped. The list can be comma separated, with "-" characters representing an
      interval. For example, to include chromosomes 1, 2, 3, 10 and X you could use --chr 1-3,10,X Not
      used by default

  coding_only:
    type: boolean?
    inputBinding:
      prefix: --coding_only
    doc: |
      --coding_only  Only return consequences that fall in the coding regions of transcripts. Not used by default

  no_intergenic:
    type: boolean?
    inputBinding:
      prefix: --no_intergenic
    doc: |
      --no_intergenic  Do not include intergenic consequences in the output. Not used by default

  pick:
    type: boolean?
    inputBinding:
      prefix: --pick
    doc: |
      --pick  Pick once line or block of consequence data per variant, including transcript-specific columns.
      Consequences are chosen according to the criteria described here, and the order the criteria are applied
      may be customised with --pick_order. This is the best method to use if you are interested only in one
      consequence per variant. Not used by default

  pick_allele:
    type: boolean?
    inputBinding:
      prefix: --pick_allele
    doc: |
      --pick_allele  Like --pick, but chooses one line or block of consequence data per variant allele. Will
      only differ in behaviour from --pick when the input variant has multiple alternate alleles. Not used
      by default

  per_gene:
    type: boolean?
    inputBinding:
      prefix: --per_gene
    doc: |
      --per_gene  Output only the most severe consequence per gene. The transcript selected is arbitrary if
      more than one has the same predicted consequence. Uses the same ranking system as --pick. Not used by default

  pick_allele_gene:
    type: boolean?
    inputBinding:
      prefix: --pick_allele_gene
    doc: |
      --pick_allele_gene  Like --pick_allele, but chooses one line or block of consequence data per variant
      allele and gene combination. Not used by default

  flag_pick:
    type: string?
    inputBinding:
      prefix: --flag_pick
    doc: |
      --flag_pick  As per --pick, but adds the PICK flag to the chosen block of consequence data and retains
      others. Not used by default

  flag_pick_allele:
    type: string?
    inputBinding:
      prefix: --flag_pick_allele
    doc: |
      --flag_pick_allele  As per --pick_allele, but adds the PICK flag to the chosen block of consequence data
      and retains others. Not used by default

  flag_pick_allele_gene:
    type: string?
    inputBinding:
      prefix: --flag_pick_allele_gene
    doc: |
      --flag_pick_allele_gene  As per --pick_allele_gene, but adds the PICK flag to the chosen block of
      consequence data and retains others. Not used by default

  pick_order:
    type: string?
    inputBinding:
      prefix: --pick_order
    doc: |
      --pick_order [c1,c2,...,cN] Customise the order of criteria applied when choosing a block of annotation
      data with e.g. --pick. See this page for the default order.
      Valid criteria are: canonical,appris,tsl,biotype,ccds,rank,length

  most_severe:
    type: boolean?
    inputBinding:
      prefix: --most_severe
    doc: |
      --most_severe  Output only the most severe consequence per variant. Transcript-specific columns
      will be left blank. Consequence ranks are given in this table. Not used by default

  summary:
    type: boolean?
    inputBinding:
      prefix: --summary
    doc: |
      --summary  Output only a comma-separated list of all observed consequences per variant.
      Transcript-specific columns will be left blank. Not used by default

  filter_common:
    type: boolean?
    inputBinding:
      prefix: --filter_common
    doc: |
      --filter_common  Shortcut flag for the filters below - this will exclude variants that have a
      co-located existing variant with global AF > 0.01 (1%). May be modified using any of the following
      freq_* filters. Not used by default

  check_frequency:
    type: boolean?
    inputBinding:
      prefix: --check_frequency
    doc: |
      --check_frequency  Turns on frequency filtering. Use this to include or exclude variants based
      on the frequency of co-located existing variants in the Ensembl Variation database. You must
      also specify all of the --freq_* flags below. Frequencies used in filtering are added to the
      output under the FREQS key in the Extra field. Not used by default

  freq_pop:
    type:
    - "null"
    - type: enum
      symbols: ['1KG_ALL','1KG_AFR','1KG_AMR','1KG_EAS','1KG_EUR','1KG_SAS','ESP_AA','ESP_EA','ExAC','ExAC_Adj','ExAC_AFR','ExAC_AMR','ExAC_EAS','ExAC_FIN','ExAC_NFE','ExAC_SAS','ExAC_OTH']
    inputBinding:
      prefix: --freq_pop
    doc: |
      --freq_pop [pop] Name of the population to use in frequency filter. This must be one of the following:
            name      Description
            1KG_ALL   1000 genomes combined population (global)
            1KG_AFR   1000 genomes combined African population
            1KG_AMR   1000 genomes combined American population
            1KG_EAS   1000 genomes combined East Asian population
            1KG_EUR   1000 genomes combined European population
            1KG_SAS   1000 genomes combined South Asian population
            ESP_AA    NHLBI-ESP African American
            ESP_EA    NHLBI-ESP European American
            ExAC      ExAC combined population
            ExAC_Adj  ExAC combined adjusted population
            ExAC_AFR  ExAC African
            ExAC_AMR  ExAC American
            ExAC_EAS  ExAC East Asian
            ExAC_FIN  ExAC Finnish
            ExAC_NFE  ExAC non-Finnish European
            ExAC_SAS  ExAC South Asian
            ExAC_OTH  ExAC other

  freq_freq:
    type: float?
    inputBinding:
      prefix: --freq_freq
    doc: |
      --freq_freq [freq]  Allele frequency to use for filtering. Must be a float value between 0 and 1

  freq_gt_lt:
    type:
    - "null"
    - type: enum
      symbols: ['gt', 'lt']
    inputBinding:
      prefix: --freq_gt_lt
    doc: |
      --freq_gt_lt [gt|lt]  Specify whether the frequency of the co-located variant must be greater than
      (gt) or less than (lt) the value specified with --freq_freq

  freq_filter:
    type:
    - "null"
    - type: enum
      symbols: ['exclude', 'include']
    inputBinding:
      prefix: --freq_filter
    doc: |
      --freq_filter [exclude|include]  Specify whether to exclude or include only variants that pass the
      frequency filter

  database:
    type: boolean?
    inputBinding:
      prefix: --database
    doc: |
      --database  Enable VEP to use local or remote databases.

  host:
    type: string?
    inputBinding:
      prefix: --host
    doc: |
      --host [hostname]  Manually define the database host to connect to. Users in the US may find connection
      and transfer speeds quicker using our East coast mirror, useastdb.ensembl.org. Default = "ensembldb.ensembl.org"

  user:
    type: string?
    inputBinding:
      prefix: --user
    doc: |
      --user [username] -u Manually define the database username. Default = "anonymous"

  password:
    type: string?
    inputBinding:
      prefix: --password
    doc: |
      --password [password] --pass Manually define the database password. Not used by default

  port:
    type: int?
    inputBinding:
      prefix: --port
    doc: |
      --port [number] Manually define the database port. Default = 5306

  genomes:
    type: string?
    inputBinding:
      prefix: --genomes
    doc: |
      --genomes  Override the default connection settings with those for the Ensembl Genomes public MySQL server.
      Required when using any of the Ensembl Genomes species. Not used by default

  lrg:
    type: boolean?
    inputBinding:
      prefix: --lrg
    doc: |
      --lrg  Map input variants to LRG coordinates (or to chromosome coordinates if given in LRG coordinates),
      and provide consequences on both LRG and chromosomal transcripts. Not compatible with --offline

  check_svs:
    type: boolean?
    inputBinding:
      prefix: --check_svs
    doc: |
      --check_svs  Checks for the existence of structural variants that overlap your input. Currently requires
      database access (i.e. not compatible with --offline). Not used by default

  db_version:
    type: string?
    inputBinding:
      prefix: --db_version
    doc: |
      --db_version [number] --db Force the script to connect to a specific version of the Ensembl databases.
      Not recommended as there may be conflicts between software and database versions. Not used by default

  registry:
    type: File?
    inputBinding:
      prefix: --registry
    doc: |
      --registry [filename]  Defining a registry file overwrites other connection settings and uses those
      found in the specified registry file to connect. Not used by default

outputs:
  text:
    type: File
    outputBinding:
      glob: $(inputs.output_file)
  html:
    type: File
    outputBinding:
      glob: $(inputs.output_file+'_summary.html')

