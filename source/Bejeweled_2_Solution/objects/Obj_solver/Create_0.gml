var path = get_open_filename_ext(".bpz Puzzle file|*.bpz", "", "", "Select puzzle file");

if (path != "") {
    scr_solve_file(path);
} else {
    show_debug_message("No file selected.");
}