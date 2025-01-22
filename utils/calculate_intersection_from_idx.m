function res = calculate_intersection_from_idx(idx1, idx2, lines)
    intersection = cross(lines(idx1).line, lines(idx2).line);
    res = intersection/intersection(3);
end