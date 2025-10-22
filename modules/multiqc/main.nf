process MULTIQC {
    module 'bbc2/multiqc/multiqc-1.28'
  input:
    path 'analysis_dirs'

  output:
    path "multiqc_report.html"

  script:
    """
    multiqc -f -n multiqc_report.html $analysis_dirs
    """
}