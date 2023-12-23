#' group_stats
#'
#' @description
#' Calculate the list of objects shared in a coordinated manner and the total
#' number of unique accounts sharing them.
#'
#' @param coord_graph A result `igraph` generated by \link{generate_coordinated_network}
#' @param network The level of the network for which to calculate the statistic.
#' It can be either "full" or "fast". The latter is applicable only if the data
#' includes information on a faster network, as calculated with the \link{flag_fast_share}
#' function.

#' @return a `data.table` with summary statistics
#'
#' @import data.table
#' @import igraph
#' @export
#'
#'

group_stats <- function(coord_graph, network = c("full", "fast")) {
    object_id_list <- from <- to <- object_id <- num_accounts <- object_ids_fast <- NULL

    x <- data.table::as.data.table(igraph::as_data_frame(coord_graph))

    if (network == "full") {
        # Identify the column name that starts with 'object_ids'
        object_ids_column <- names(x)[startsWith(names(x), "object_ids")]

        # Ensure that the column exists
        if (length(object_ids_column) == 0) {
            stop("Column starting with 'object_ids' not found in the data.table")
        }

        # Use the identified column in the subsequent code
        x[, object_id_list := strsplit(get(object_ids_column), split = ",", fixed = TRUE)]

        unnested <- x[, .(object_id = unlist(object_id_list)), by = .(from, to)]

        object_id_summary <- unnested[, .(num_accounts = uniqueN(from)), by = .(object_id)]

        # Filter out NA values in 'object_id'
        object_id_summary <- object_id_summary[!is.na(object_id)]

        # Order by 'num_accounts' in descending order
        setorder(object_id_summary, -num_accounts)

        # Return the summary table
        return(object_id_summary)
    } else {
        x[, object_id_list := strsplit(object_ids_fast, split = ",", fixed = TRUE)]

        unnested <- x[, .(object_id = unlist(object_id_list)), by = .(from, to)]

        object_id_summary <- unnested[, .(num_accounts = uniqueN(from)), by = .(object_id)]

        object_id_summary <- object_id_summary[!is.na(object_id)]

        setorder(object_id_summary, -num_accounts)

        return(object_id_summary)
    }
}
