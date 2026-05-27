function scr_arrow_to_move(arrow) {
    if (arrow >= 0 && arrow < 64) {
        var r_left = arrow div 8;
        var c_left = arrow mod 8;

        if (c_left <= 0) {
            return undefined;
        }

        return {
            r1: r_left,
            c1: c_left,
            r2: r_left,
            c2: c_left - 1
        };
    }

    if (arrow >= 96 && arrow < 160) {
        var idx_down = arrow - 96;
        var r_down = idx_down div 8;
        var c_down = idx_down mod 8;

        if (r_down + 1 >= BOARD_H) {
            return undefined;
        }

        return {
            r1: r_down,
            c1: c_down,
            r2: r_down + 1,
            c2: c_down
        };
    }

    return undefined;
}