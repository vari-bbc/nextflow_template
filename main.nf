#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FASTQC } from './modules/fastqc'
include { CAT_FASTQS } from './modules/rename_fastqs'
include { SYMLINK_FASTQS } from './modules/rename_fastqs'


nextflow.preview.output = true

// Count letters for each word
process count_letters {
  input:
    val word

  output:
    path "${word}.txt"

  script:
    """
    printf "${word}" | wc -c > ${word}.txt
    """
}

// Sum all counts into one file
process sum_letter_counts {
  input:
    path(count_files)

  output:
    path "summed.txt"

  script:
    """
    cat ${count_files} | awk '{sum += \$1} END {print "Total:", sum}' > summed.txt
    """
}

/*

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    main:

    Channel.fromPath('assets/samplesheet.csv')
    .splitCsv(header: true)
    .map { row -> 
        tuple(row.sample, file("raw_data/" + row.fq1), file("raw_data/" + row.fq2))
    }
    .groupTuple()
    .set { grouped_samples }

    grouped_samples
    .filter(row -> row[1].size() > 1)
    .multiMap { row -> 
        R1: [sample:row[0], fq:row[1], suff:"R1"]
        R2: [sample:row[0], fq:row[2], suff:"R2"]
    }
    .set { cat_fastqs }

    CAT_FASTQS(cat_fastqs.R1.concat(cat_fastqs.R2))

    grouped_samples
    .filter(row -> row[1].size() == 1)
    .multiMap { row -> 
        R1: [sample:row[0], fq:row[1][0], suff:"R1"]
        R2: [sample:row[0], fq:row[2][0], suff:"R2"]
    }
    .set { symlink_fastqs }

    SYMLINK_FASTQS(symlink_fastqs.R1.concat(symlink_fastqs.R2))



    //CAT_FASTQS(cat_fastqs)
    //SYMLINK_FASTQS(symlink_fastqs)
    //.view()

    // RENAME_FASTQS(concated)

    // grouped_samples
    // .map { sample, entries ->
    //     def fq1_group = entries.collect { tuple(sample, it[1], 'R1') }
    //     tuple(sample, fq1_group)
    // }
    // .view()
    // .set { fq1_grouped }

    // grouped_samples
    // .map { sample, entries ->
    //     def fq2_group = entries.collect { tuple(sample, it[2], 'R2') }
    //     tuple(sample, fq2_group)
    // }
    // .view()
    // .set { fq2_grouped }

    // samples_ch = Channel
    //           .fromPath('assets/samplesheet.csv')
    //           .splitCsv(header: true)

    // //samples_ch.view()
    // Channel.fromPath('assets/samplesheet.csv')
    // .splitCsv(header: true)
    // .map { row -> 
    //     tuple(row.sample, row.fq1, row.fq2)
    // }
    // .set { sample_data }

    // sample_data
    // .map { sample, fq1, fq2 -> tuple(sample, "raw_data/" + fq1, "R1") }
    // .groupTuple()
    // .set { fq1_ch }

    // sample_data
    // .map { sample, fq1, fq2 -> tuple(sample, "raw_data/" + fq2, "R2") }
    // .groupTuple(by:0,2)
    // .view()
    // .set { fq2_ch }



    // samples_ch
    // .map { row ->
    //     set(sample:"${row.sample}", fq1:file("raw_data/${row.fq1}"), fq2:file("raw_data/${row.fq2}"))
    // }
    // .view()
    // .multiMap { row ->
    //       R1: tuple(row['sample'], row['fq1'], "R1")
    //       R2: tuple(row['sample'], row['fq2'], "R2")
    //  }
    // .set{ input }

    //input.R1.view()
    // .multiMap { row ->
    //     R1: tuple(row['sample'], file("./raw_data/" + row['fq1']), "R1")
    //     R2: tuple(row['sample'], file("./raw_data/" + row['fq2']), "R2")
    // }
    // .set{ input }
    
    //RENAME_FASTQS(input.R1.concat(input.R2))

    // .map { row -> 
    //     def fq_path = "raw_data/${row.fq1}"
    //     tuple(row.sample_id, row.fq1, fq_path)
    // }
    // .view()

    // .map { row -> tuple(row.sample, row.fq1, row.fq2) }
    // .groupTuple()
    // .multiMap { row ->
    //     R1: tuple(row[0], row[1], "R1")
    //     R2: tuple(row[0], row[2], "R2")
    // }


    /*.set{ input }

    input.view() */

    /*.map { sample, rows ->
        def fq1 = rows.collect { it.fq1 }
        def fq2 = rows.collect { it.fq2 }
        tuple(sample_id, fq1, fq2)
    }
    .set { sample_fastqs } */

    // sample_fastqs.view()

    words_ch = Channel
              .fromPath('words.csv')
              .splitCsv(header: true)
              .map { item -> item['word'] }

    count_ch = count_letters(words_ch)
    sum_ch = sum_letter_counts(count_letters.out.collect())
/* 
    samples_ch = Channel
              .fromPath('assets/samplesheet.csv')
              .splitCsv(header: true)

    //samples_ch.view()

    samples_ch
        .multiMap { row ->
        R1: tuple(row['sample'], file("./raw_data/" + row['fq1']), "R1")
        R2: tuple(row['sample'], file("./raw_data/" + row['fq2']), "R2")
    }
    .set { input } */

    

    //samples_ch['new_fq1'] = samples_ch.collectEntries{key, value -> [key, value.sample]}
    //samples_ch
    //    .view()

    //RENAME_FASTQS(input.R1.concat(input.R2))

    //FASTQC(samples_ch.map { item -> item['fq1'] })
    //          .map { item -> item['word'] }


    workflow.onComplete = {
        log.info(
            workflow.success
                ? "\nDone!\n"
                : "Oops .. something went wrong"
        )
    }

    publish:
    count_out = count_ch
    sum_out = sum_ch

}

output {
    count_out {
        path 'step1'
    }
    sum_out {
        path 'step2'
    }
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
