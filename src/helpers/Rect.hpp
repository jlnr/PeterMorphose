#pragma once

struct Rect {
    int left = 0;
    int top = 0;
    int width = 0;
    int height = 0;

    int right() const { return left + width; }
    int bottom() const { return top + height; }

    bool collide_with(const Rect& other) const
    {
        return left < other.right() && right() > other.left && top < other.bottom()
            && bottom() > other.top;
    }

    bool contains(int x, int y) const
    {
        return x >= left && y >= top && x < right() && y < bottom();
    }
};
