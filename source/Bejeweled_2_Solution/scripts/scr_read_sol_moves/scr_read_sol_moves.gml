function scr_read_sol_moves(bpz_path) {
    var sol_path = scr_replace_extension(bpz_path, ".sol");

    if (!file_exists(sol_path)) {
        return undefined;
    }

    var moves = [];

    var f = file_bin_open(sol_path, 0);
    var size = file_bin_size(f);

    
    var pos = 15;

    while (pos + 4 < size) {
        file_bin_seek(f, pos);

        var hint_count = file_bin_read_byte(f);
        var arrow = file_bin_read_byte(f);
        var goto_state = file_bin_read_byte(f);
        var pad1 = file_bin_read_byte(f);
        var pad2 = file_bin_read_byte(f);

        if (hint_count <= 0) {
            break;
        }

        var mv = scr_arrow_to_move(arrow);

        if (!is_undefined(mv)) {
            array_push(moves, mv);
        }

        pos += 5;
    }

    file_bin_close(f);

    if (array_length(moves) == 0) {
        return undefined;
    }

    return moves;
}