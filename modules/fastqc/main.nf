process FASTQC {
    module 'bbc2/fastqc/fastqc-0.12.1'
  input:
    val fq_pref
    path "${fq_pref}.fastq.gz"

  output:
    path "${fq_pref}_fastqc.html"
    path "${fq_pref}_fastqc.zip"

  script:
    """
    fastqc $fastq
    """
}