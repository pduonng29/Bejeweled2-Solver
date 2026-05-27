function scr_get_legal_moves(board) {
    var moves = [];

    for (var r = 0; r < BOARD_H; r++) {
        for (var c = 0; c < BOARD_W; c++) {
            // IMPORTANT v15:
            // In .sol, direction matters because special gem position can depend on the
            // selected/moved gem. Therefore we must generate all oriented adjacent swaps,
            // not only right/down swaps.
            var dirs = [
                [0, 1],
                [0, -1],
                [1, 0],
                [-1, 0]
            ];

            for (var di = 0; di < array_length(dirs); di++) {
                var rr = r + dirs[di][0];
                var cc = c + dirs[di][1];

                if (!scr_inside_board(rr, cc)) {
                    continue;
                }

                var mv = {
                    r1: r,
                    c1: c,
                    r2: rr,
                    c2: cc
                };

                if (scr_is_real_legal_move(board, mv)) {
                    array_push(moves, mv);
                }
            }
        }
    }

    return moves;
}
