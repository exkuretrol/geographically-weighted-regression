library(ggplot2)

save_ggplot2_plot <- function(plot = last_plot(), filename, width = 8, height = 6) {
    path_to_plot_dir <- file.path(getwd(), "plots")
    
    ggsave(
        filename = file.path(path_to_plot_dir, filename),
        plot = plot,
        width = width,
        height = height,
        dpi = 300
    )
}
