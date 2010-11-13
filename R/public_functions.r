

# What I want: A list with an entry for each record
# - ident
# - type (Single, multiple, character, quantity, logical)
# - name
# - label
# - position start
# - position finish
# - list of value codes
# - list of value descriptions

#' Reads a triple-s XML (.sss) metadata file, as specified by the triple-s XML standard  
#'
#' This function reads and parses a .sss XML metadata file.
#' The .sss standard defines a standard survey structure
#'
#' @param sss_filename Name of .sss file containing the survey metadata
#' @keywords XML
#' @export 
#' @seealso read_sss, read_sss_data
#' @examples
#' # Not executed
#' # read_sss_metadata("sample.sss")
read_sss_metadata <- function(sss_filename){
	doc <- xmlTreeParse(sss_filename, getDTD = F)
	r <- xmlRoot(doc)[["survey"]][["record"]]
	variables <- ldply(xmlChildren(r), get_sss_record)
	codes <- ldply(xmlChildren(r), get_sss_codes)
	list(variables=variables, codes=codes)
}

#' Reads a triple-s XML (.asc) data file, as specified by the triple-s XML standard  
#'
#' This function reads and parses a .asc XML data file.
#' The .sss standard defines a standard survey structure
#'
#' @param asc_filename Name of .asc file containing the survey metadata
#' @keywords XML
#' @export 
#' @seealso read_sss, read_sss_metadata
#' @examples
#' # Not executed
#' # read_sss_data("sample.asc")
read_sss_data <- function(asc_filename){
	scan(asc_filename, sep="\n", what="character")
}



#' Reads and processes a triple-s .sss and .asc file  
#'
#' This function reads and parses a .sss XML metadata file as well as its
#' associated .asc data file. 
#' The .sss standard defines a standard survey structure
#'
#' @param sss_filename Name of .sss file containing the survey metadata
#' @param asc_filename Name of .asc file containing survey data
#' @keywords triple-s
#' @export 
#' @examples
#' # Not executed
#' # read_sss("sample.sss, sample.asc")
read_sss <- function(sss_filename, asc_filename){
	sss <- read_sss_metadata(paste(path, filename_sss, sep=""))
	asc <- read_sss_data(paste(path, filename_asc, sep=""))
	n <- nrow(sss$variables)
	
	df <- list_to_df(llply(1:n, function(x)get_variable_position(sss, asc, x)), sss$variables$name)
	df <- llply_colwise(sss, df, change_values)
	df <- llply_colwise(sss, df, change_type)
	df
}

