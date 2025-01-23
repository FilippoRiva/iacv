function line = get_line_by_name(name, lines)
    line = [];
    for idx=1:length(lines)
        if strcmp(lines(idx).name, name)
            line = lines(idx).line;
            break
        end
    end
end