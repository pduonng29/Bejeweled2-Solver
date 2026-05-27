function scr_path_append(path, move) {
    var new_path = [];

    for (var i = 0; i < array_length(path); i++) {
        array_push(new_path, path[i]);
    }

    array_push(new_path, move);

    return new_path;
}