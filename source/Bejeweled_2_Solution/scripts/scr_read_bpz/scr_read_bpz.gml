function scr_read_bpz(path) {
    var board = scr_create_empty_board();

    if (!file_exists(path)) {
        show_debug_message("BPZ file does not exist or is not allowed:");
        show_debug_message(path);
        return board;
    }

    var f = file_bin_open(path, 0);
    var file_size = file_bin_size(f);

    // Byte 0x04 decides how the values 07 and 08 should be interpreted.
    // In some BPZ files: 07 = bomb, 08 = rock.
    // In other BPZ files: 08 = bomb, 07 = rock.
    file_bin_seek(f, 4);
    var mode = file_bin_read_byte(f);

    var bomb_code;
    var rock_code;

    if (mode == 1) {
        bomb_code = 7;
        rock_code = 8;
    } else {
        bomb_code = 8;
        rock_code = 7;
    }

    // ------------------------------------------------------------------
    // v16 GENERAL BPZ PARSER
    // ------------------------------------------------------------------
    // BPZ is NOT always a fixed 64-byte board.
    // Correct format used by the guide:
    //   header: 10 bytes
    //   3 strings: each string = 2-byte little-endian length + data bytes
    //   board: variable-length cells until exactly 64 cells are decoded
    //     FF             -> empty, 1 byte
    //     color + pwr    -> normal/power gem, 2 bytes
    //     rock_code + x  -> rock, 2 bytes
    //     bomb_code+x+v  -> bomb, 3 bytes
    // The old parser used file_bin_seek(f, 40), which only works when all
    // three metadata strings have length 8. It fails for generated levels
    // such as AutoLv01/Auto puzzle/Solution, where board starts at 43.
    // ------------------------------------------------------------------

    var board_start = 40; // fallback for old/simple files
    var meta_ok = true;
    var pos = 10;

    for (var s = 0; s < 3; s++) {
        if (pos + 2 > file_size) {
            meta_ok = false;
            break;
        }

        file_bin_seek(f, pos);
        var len_lo = file_bin_read_byte(f);
        var len_hi = file_bin_read_byte(f);
        var str_len = len_lo + (len_hi * 256);
        pos += 2;

        // Guard against corrupted/unknown files.
        if (str_len < 0 || str_len > 512 || pos + str_len > file_size) {
            meta_ok = false;
            break;
        }

        pos += str_len;
    }

    if (meta_ok && pos < file_size) {
        board_start = pos;
    }

    global.__bpz_last_board_start = board_start;
    global.__bpz_last_file_size = file_size;

    var read_pos = board_start;

    for (var i = 0; i < 64; i++) {
        var r = i div 8;
        var c = i mod 8;

        if (read_pos >= file_size) {
            board[r][c] = scr_make_cell(GEM_EMPTY, 0, 0);
            continue;
        }

        file_bin_seek(f, read_pos);
        var gem = file_bin_read_byte(f);
        read_pos += 1;

        if (gem == 255) {
            board[r][c] = scr_make_cell(GEM_EMPTY, 0, 0);
        } else {
            var pwr = 0;

            if (read_pos < file_size) {
                file_bin_seek(f, read_pos);
                pwr = file_bin_read_byte(f);
                read_pos += 1;
            }

            if (gem == bomb_code) {
                var bomb_value = 0;

                if (read_pos < file_size) {
                    file_bin_seek(f, read_pos);
                    bomb_value = file_bin_read_byte(f);
                    read_pos += 1;
                }

                board[r][c] = scr_make_cell(GEM_BOMB, pwr, bomb_value);
            } else if (gem == rock_code) {
                board[r][c] = scr_make_cell(GEM_ROCK, pwr, 0);
            } else if (gem == 9) {
                board[r][c] = scr_make_cell(GEM_HYPER, pwr, 0);
            } else {
                board[r][c] = scr_make_cell(gem, pwr, 0);
            }
        }
    }

    global.__bpz_last_read_end = read_pos;

    file_bin_close(f);
    return board;
}
