#' @title Convert MNC to NIfTI
#' @description This function calls \code{mnc2nii}
#' to convert MNC files to NIfTI
#' @param file (character) input filename
#' @param outfile (character) output filename
#' @param ... Additional arguments to pass to \code{\link{fs_cmd}}
#' @return Character filename of output
#' @importFrom tools file_ext
#' @importFrom R.utils gzip
#' @export
#' @examples
#' if (have_fs() && requireNamespace("oro.nifti", quietly = TRUE)) {
#'    img = oro.nifti::nifti(array(rnorm(5*5*5), dim = c(5,5,5)))
#'    mnc = nii2mnc(img)
#'    img_file = mnc2nii(mnc, outfile = tempfile(fileext = ".nii"))
#'    neurobase::readnii(img_file, verbose = TRUE)
#' }
mnc2nii = function(file, outfile = NULL, ...) {
  if (is.null(outfile)) {
    outfile = tempfile(fileext = ".nii.gz")
  }
  out_ext = file_ext(tolower(outfile))
  outfile = paste0(nii.stub(outfile), ".nii")

  # copy for bs stuff
  stopifnot(all(file.exists(file)))
  tfile = tempfile()
  dir.create(tfile, showWarnings = FALSE)
  infile = file.path(tfile, basename(file))
  file.copy(from = file, to = infile, overwrite = TRUE)

  fs_cmd(
    func = "mnc2nii",
    file = file,
    outfile = outfile,
    retimg = FALSE,
    frontopts = "-float",
    samefile = FALSE,
    add_ext = FALSE,
    bin_app = "mni/bin",
    ...
  )
  if (!file.exists(outfile)) {
    real_outfile = outfile
    outfile = paste0(outfile, ".nii")
    if (!file.exists(outfile)) {
      stop("mnc2nii did not produce outfile specified")
    }
    file.copy(outfile, real_outfile, overwrite = TRUE)
    outfile = real_outfile
  }
  if (out_ext %in% "gz") {
    outfile = gzip(outfile, remove = TRUE, temporary = FALSE, overwrite = TRUE)
  }
  return(outfile)
}


#' @title MNC to NIfTI Help
#' @description This calls Freesurfer's \code{mnc2nii} help
#'
#' @return Result of \code{fs_help}
#' @export
mnc2nii.help = function() {
  fs_help(func_name = "mnc2nii", help.arg = "", bin_app = "mni/bin")
}
