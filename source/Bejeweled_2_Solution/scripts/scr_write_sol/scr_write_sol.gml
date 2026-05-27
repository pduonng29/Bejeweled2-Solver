function scr_write_sol(sol_path, moves) {

    var move_count = array_length(moves);

    if (move_count <= 0) {
        show_debug_message("WRITE SOL FAILED: empty move list.");
        return false;
    }

    if (file_exists(sol_path)) {
        file_delete(sol_path);
    } else {
    }

    var f = file_bin_open(sol_path, 1);

    if (f < 0) {
        show_debug_message("WRITE SOL FAILED: cannot open .sol for writing.");
        return false;
    }

    file_bin_write_byte(f, 0x02);
    file_bin_write_byte(f, 0xB0);
    file_bin_write_byte(f, 0x37);
    file_bin_write_byte(f, 0x13);
    file_bin_write_byte(f, 0x02);

    file_bin_write_byte(f, 0x00);
    file_bin_write_byte(f, 0x65);
    file_bin_write_byte(f, 0x46);
    file_bin_write_byte(f, 0xB8);
    file_bin_write_byte(f, 0xD6);

    file_bin_write_byte(f, 1);
    file_bin_write_byte(f, 0);

    file_bin_write_byte(f, move_count + 1);
    file_bin_write_byte(f, 0);
    file_bin_write_byte(f, 0);

    for (var i = 0; i < move_count; i++) {
        var m = moves[i];
        var arrow = scr_move_to_arrow(m);

        if (arrow < 0) {
            show_debug_message("WRITE SOL FAILED: invalid arrow at step " + string(i + 1));
            file_bin_close(f);

            if (file_exists(sol_path)) {
                file_delete(sol_path);
            }

            return false;
        }

        var goto_state;

        if (i < move_count - 1) {
            goto_state = i + 2;
        } else {
            goto_state = 0;
        }

        show_debug_message(
            "Write state " + string(i + 1)
            + " | step " + string(i + 1)
            + " | move = (" + string(m.r1) + "," + string(m.c1)
            + ") -> (" + string(m.r2) + "," + string(m.c2) + ")"
            + " | arrow = " + string(arrow)
            + " | goto_state = " + string(goto_state)
        );

        file_bin_write_byte(f, 1);
        file_bin_write_byte(f, arrow);
        file_bin_write_byte(f, goto_state);
        file_bin_write_byte(f, 0);
        file_bin_write_byte(f, 0);
    }

    file_bin_close(f);

    if (!file_exists(sol_path)) {
        show_debug_message("WRITE SOL FAILED: file was not created.");
        return false;
    }


    return true;
}
