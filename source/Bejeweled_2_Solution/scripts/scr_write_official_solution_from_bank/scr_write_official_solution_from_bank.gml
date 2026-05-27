function scr_write_official_solution_from_bank(bpz_path, sol_path) {
    var sol_name = filename_name(bpz_path) + ".sol";

    show_debug_message("Trying official solution bank fallback v9 STRICT BANK...");
    show_debug_message("Target SOL name: " + sol_name);

    var candidates = [];

    var bpz_dir = filename_dir(bpz_path);
    var parent_dir = filename_dir(bpz_dir);
    var user_profile = environment_get_variable("USERPROFILE");

    array_push(candidates, scr_bank_join_path(bpz_dir, "official_solutions/" + sol_name));
    array_push(candidates, scr_bank_join_path(parent_dir, "official_solutions/" + sol_name));
    array_push(candidates, scr_bank_join_path(bpz_dir, "datafiles/official_solutions/" + sol_name));
    array_push(candidates, scr_bank_join_path(parent_dir, "datafiles/official_solutions/" + sol_name));

    array_push(candidates, scr_bank_join_path(working_directory, "official_solutions/" + sol_name));
    array_push(candidates, scr_bank_join_path(working_directory, "datafiles/official_solutions/" + sol_name));
    array_push(candidates, scr_bank_join_path(program_directory, "official_solutions/" + sol_name));
    array_push(candidates, scr_bank_join_path(program_directory, "datafiles/official_solutions/" + sol_name));

    array_push(candidates, "official_solutions/" + sol_name);
    array_push(candidates, "datafiles/official_solutions/" + sol_name);

    if (string_length(user_profile) > 0) {
        var gmroot = user_profile + "/GameMakerProjects";

        array_push(candidates, gmroot + "/Bejeweled_2_Puzzle_RAM_SAFE_v9_strict_bank/official_solutions/" + sol_name);
        array_push(candidates, gmroot + "/Bejeweled_2_Puzzle_RAM_SAFE_v9_strict_bank/datafiles/official_solutions/" + sol_name);

        array_push(candidates, gmroot + "/Bejeweled_2_Puzzle_RAM_SAFE_v8_bank_first/official_solutions/" + sol_name);
        array_push(candidates, gmroot + "/Bejeweled_2_Puzzle_RAM_SAFE_v8_bank_first/datafiles/official_solutions/" + sol_name);

        array_push(candidates, gmroot + "/Bejeweled_2_Puzzle_RAM_SAFE_v7_rules/official_solutions/" + sol_name);
        array_push(candidates, gmroot + "/Bejeweled_2_Puzzle_RAM_SAFE_v7_rules/datafiles/official_solutions/" + sol_name);
    }

    for (var i = 0; i < array_length(candidates); i++) {
        var src_path = candidates[i];

        if (!file_exists(src_path)) {
            continue;
        }

        if (src_path == sol_path) {
            continue;
        }

        show_debug_message("V9 strict official bank source found:");
        show_debug_message(src_path);

        var backup_path = sol_path + ".v9_before_replace";

        if (file_exists(sol_path) && !file_exists(backup_path)) {
            file_copy(sol_path, backup_path);
            show_debug_message("V9 backup created before strict bank replace:");
            show_debug_message(backup_path);
        }

        if (file_exists(sol_path)) {
            file_delete(sol_path);
        }

        file_copy(src_path, sol_path);

        if (file_exists(sol_path)) {
            show_debug_message("V9 STRICT OFFICIAL SOLUTION SAVED:");
            show_debug_message(sol_path);
            return true;
        }
    }

    show_debug_message("V9 strict official solution bank failed: no matching bundled SOL found.");
    show_debug_message("IMPORTANT: do not use .auto_backup/.safe_backup as source because they may contain old wrong solver output.");
    show_debug_message("Extract project to C:/Users/<user>/GameMakerProjects/Bejeweled_2_Puzzle_RAM_SAFE_v9_strict_bank or copy official_solutions beside the .bpz folder.");
    return false;
}
