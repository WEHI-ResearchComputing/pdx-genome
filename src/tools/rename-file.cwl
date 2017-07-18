#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: [mv]

inputs:
  infile:
    type: File?
    inputBinding:
      position: 1
  outfile:
    type: string
    inputBinding:
      position: 2

outputs:
  renamed:
    type: File
    outputBinding:
      glob: $(inputs.outfile)

