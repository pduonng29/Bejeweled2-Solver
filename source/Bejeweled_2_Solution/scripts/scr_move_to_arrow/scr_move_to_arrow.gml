function scr_move_to_arrow(move) {
    if (move.r1 == move.r2) {
        var r = move.r1;

        if (move.c2 == move.c1 - 1) {
            var right_c = move.c1;

            if (right_c <= 0 || right_c >= BOARD_W) {
                return -1;
            }

            return r * BOARD_W + right_c;
        }

        if (move.c2 == move.c1 + 1) {
            var left_c = move.c1;

            if (left_c < 0 || left_c >= BOARD_W - 1) {
                return -1;
            }

            return 128 + r * BOARD_W + left_c;
        }
    }

    if (move.c1 == move.c2) {
        var c = move.c1;

        if (move.r2 == move.r1 - 1) {
            var bottom_r = move.r1;

            if (bottom_r <= 0 || bottom_r >= BOARD_H) {
                return -1;
            }

            return 72 + (bottom_r - 1) * BOARD_W + c;
        }

        if (move.r2 == move.r1 + 1) {
            var top_r = move.r1;

            if (top_r < 0 || top_r >= BOARD_H - 1) {
                return -1;
            }

            return 192 + top_r * BOARD_W + c;
        }
    }

    return -1;
}