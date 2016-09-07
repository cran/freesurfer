#' @title Create command declaring FREESURFER_HOME
#' @description Finds the Freesurfer from system environment or \code{getOption("freesurfer.path")}
#' for location of Freesurfer functions
#' @param add_bin Should \code{bin} be added to the freesurfer path? 
#' All executables are assumed to be in \code{FREESURFER_HOME/}.  If not, and 
#' \code{add_bin = FALSE}, they will be assumed to be in \code{FreesurferDIR/}.
#' @note This will use \code{Sys.getenv("FREESURFER_HOME")} before \code{getOption("freesurfer.path")}.
#' If the directory is not found for Freesurfer in \code{Sys.getenv("FreesurferDIR")} and 
#' \code{getOption("freesurfer.path")}, it will try the default directory \code{/usr/local/freesurfer}.
#' @return NULL if Freesurfer in path, or bash code for setting up Freesurfer DIR
#' @export
#' @examples
#' if (have_fs()) {
#' get_fs()
#' }
get_fs = function(add_bin = TRUE){
  cmd = NULL

   
  freesurferdir = Sys.getenv("FREESURFER_HOME")
  if (freesurferdir == "") {
    freesurferdir = getOption("freesurfer.path")
    ## Will try a default directory (/usr/local/freesurfer) if nothing else
    if (is.null(freesurferdir)) {
      #### adding in "/usr/share/freesurfer/5.0" for NeuroDeb
      def_paths = c("/usr/local/freesurfer", "/Applications/freesurfer")
      for (def_path in def_paths) {
        if (file.exists(def_path)) {
          warning(paste0("Setting freesurfer.path to ", def_path))
          options(freesurfer.path = def_path)
          freesurferdir = def_path
          break;
        }
      }
    }
    bin = "bin"
    bin_app = paste0(bin, "/")
    if (!add_bin) {
      bin_app = bin = ""
    }
    # FSF_OUTPUT_FORMAT
    freesurferout = get_fs_output()
    shfile = file.path(freesurferdir, "SetUpFreeSurfer.sh")
    cmd <- paste0("FREESURFER_HOME=", shQuote(freesurferdir), "; ", 
                  ifelse(file.exists(shfile), 
                         paste0('sh ', shQuote(shfile)), ";"),
                  "FSF_OUTPUT_FORMAT=", freesurferout, "; export FSF_OUTPUT_FORMAT; ", 
                  paste0("${FREESURFER_HOME}/", bin_app)
                  )
  } 
  if (is.null(freesurferdir)) stop("Can't find Freesurfer")
  if (freesurferdir %in% "") stop("Can't find Freesurfer")
  return(cmd)
}


#' @title Get Freesurfer's Directory 
#' @description Finds the FreesurferDIR from system environment or \code{getOption("freesurfer.path")}
#' for location of Freesurfer fuctions and returns it
#' @return Character path
#' @aliases freesurfer_dir
#' @export
#' @examples
#' if (have_fs()) {
#'  freesurferdir()
#'  freesurfer_dir()
#'  fs_dir()
#' }
freesurferdir = function(){
  freesurferdir = Sys.getenv("FreesurferDIR")
  if (freesurferdir == "") {
    x = get_fs()
    freesurferdir = getOption("freesurfer.path")
  }
  return(freesurferdir)
}

#' @rdname freesurferdir
#' @export
freesurfer_dir = function(){
  freesurferdir()
}

#' @rdname freesurferdir
#' @export
fs_dir = function(){
  freesurferdir()
}


#' @title Logical check if Freesurfer is accessible
#' @description Uses \code{get_fs} to check if FreesurferDIR is accessible or the option
#' \code{freesurfer.path} is set and returns logical
#' @param ... options to pass to \code{\link{get_fs}}
#' @return Logical TRUE is Freesurfer is accessible, FALSE if not
#' @export
#' @examples
#' have_fs()
have_fs = function(...){
  x = suppressWarnings(try(get_fs(...), silent = TRUE))
  return(!inherits(x, "try-error"))
}


#' @title Determine Freesurfer output type
#' @description Finds the FSF_OUTPUT_FORMAT from system environment or 
#' \code{getOption("fs.outputtype")} for output type (nii.gz, nii, ANALYZE,etc) 
#' @return FSF_OUTPUT_FORMAT, such as nii.gz  If none found, uses nii.gz as default
#' 
#' @export
#' @examples
#' get_fs_output()
get_fs_output = function(){
  fs_out = Sys.getenv("FSF_OUTPUT_FORMAT")
  if (fs_out == "") {
    fs_out = getOption("fs.outputtype")
  } 
  if (is.null(fs_out)) {
    warning("Can't find FSF_OUTPUT_FORMAT, setting to nii.gz")
    fs_out = "nii.gz"
    options(fs.outputtype = fs_out)
  }
  if (fs_out == "") {
    warning("Can't find FSF_OUTPUT_FORMAT, setting to nii.gz")
    fs_out = "nii.gz"
    options(fs.outputtype = "nii.gz")
  } 
  return(fs_out)
}

#' @title Determine extension of image based on FSLOUTPUTTYPE
#' @description Runs \code{get_fs_output()} to extract FSLOUTPUTTYPE and then 
#' gets corresponding extension (such as .nii.gz)
#' @return Extension for output type
#' @export
#' @examples
#' fs_imgext()
fs_imgext = function(){
  fs_out = get_fs_output()
  ext = switch(fs_out, 
               "hdr" = ".hdr", 
               "nii.gz" = ".nii.gz", 
               "nii" = ".nii")
  return(ext)
}