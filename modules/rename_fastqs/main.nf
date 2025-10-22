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

process RENAME_FASTQS {
    tag "$sample"

    input:
    tuple val(sample), path(fastq), val(suffix)

    output:
    path "${sample}_${suffix}.fastq.gz"

    script:
    if (fastq.size() == 1) {
        """
        ln -s ${fastq[0]} "${sample}_${suffix}.fastq.gz"

        """
    } else {
        """
        cat ${fastq.join(' ')} > "${sample}_${suffix}.fastq.gz"

        """
    }
}


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