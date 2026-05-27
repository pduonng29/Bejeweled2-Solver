function scr_has_dead_island(board) {
    var visited = [];

    for (var r = 0; r < BOARD_H; r++) {
        visited[r] = [];
        for (var c = 0; c < BOARD_W; c++) {
            visited[r][c] = false;
        }
    }

    for (var sr = 0; sr < BOARD_H; sr++) {
        for (var sc = 0; sc < BOARD_W; sc++) {
            if (visited[sr][sc]) {
                continue;
            }

            if (board[sr][sc].gem == GEM_EMPTY) {
                visited[sr][sc] = true;
                continue;
            }

            var queue = [];
            var qh = 0;

            array_push(queue, [sr, sc]);
            visited[sr][sc] = true;

            var comp_size = 0;
            var has_hyper = false;

            while (qh < array_length(queue)) {
                var p = queue[qh];
                qh += 1;

                var r = p[0];
                var c = p[1];

                comp_size += 1;

                if (board[r][c].gem == GEM_HYPER) {
                    has_hyper = true;
                }

                var dirs = [
                    [1, 0],
                    [-1, 0],
                    [0, 1],
                    [0, -1]
                ];

                for (var d = 0; d < 4; d++) {
                    var nr = r + dirs[d][0];
                    var nc = c + dirs[d][1];

                    if (!scr_inside_board(nr, nc)) {
                        continue;
                    }

                    if (visited[nr][nc]) {
                        continue;
                    }

                    if (board[nr][nc].gem == GEM_EMPTY) {
                        visited[nr][nc] = true;
                        continue;
                    }

                    visited[nr][nc] = true;
                    array_push(queue, [nr, nc]);
                }
            }

            if (comp_size > 0 && comp_size < 3 && !has_hyper) {
                return true;
            }
        }
    }

    return false;
}