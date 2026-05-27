function scr_bank_join_path(dir_path, file_name) {
    if (string_length(dir_path) <= 0) {
        return file_name;
    }

    var last_char = string_char_at(dir_path, string_length(dir_path));

    if (last_char == "/" || last_char == "\\") {
        return dir_path + file_name;
    }

    return dir_path + "/" + file_name;
}
