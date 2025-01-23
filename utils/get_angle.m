function angle = get_angle(l1,l2)
    angle = rad2deg(acos(abs(l1(1)*l2(1) + l1(2)*l2(2))));
end