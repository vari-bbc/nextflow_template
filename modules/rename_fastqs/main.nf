// process RENAME_FASTQS {
//   input:
//     tuple val(sample), path(seq), val(read_num)

//   output:
//     path "${sample}_${read_num}.fastq.gz"

//   script:
//     """
//     ln -sr ${seq} "${sample}_${read_num}.fastq.gz"

//     """
// }

// process RENAME_FASTQS {
//     tag "$sample"

//     input:
//     tuple val(sample), val(fastqs), val(suffix), val(num_fqs)

//     output:
//     path "${sample}_${suffix}.fastq.gz"

//     script:
//     """
//     if [ ${num_fqs} -gt 1 ]
//     then
//         cat ${fastqs} > "${sample}_${suffix}.fastq.gz"
//     else
//         ln -sr ${fastqs} "${sample}_${suffix}.fastq.gz"
//     fi

//     """
// }


process CAT_FASTQS {
    tag "$sample"

    input:
    tuple val(sample), path(fastq), val(suffix)

    output:
    path "${sample}_${suffix}.fastq.gz"

    script:
    """

    cat ${fastq} > "${sample}_${suffix}.fastq.gz"

    """
}

process SYMLINK_FASTQS {
    tag "$sample"

    input:
    tuple val(sample), path(fastq), val(suffix)

    output:
    path "${sample}_${suffix}.fastq.gz"

    script:
    """

    ln -sr ${fastq} "${sample}_${suffix}.fastq.gz"

    """
}