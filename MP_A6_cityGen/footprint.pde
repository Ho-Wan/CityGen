// generates footprint of building
class Footprint
{
    // possible footprint sizes stored in array
    int[][] m_list_sizes = {
        {1, 2}, // 0 (shape_code)
        {2, 1}, // 1
        {2, 2}, // 2
        {2, 3}, // 3
        {2, 4}, // 4
        {3, 2}, // 5
        {3, 3}, // 6
        {3, 4}, // 7
        {4, 2}, // 8
        {4, 3}, // 9
        {4, 4}, // 10
        {5, 5}  // 11
    };

    int m_shape_code;
    int[] m_size_xy;
    // empty constructor, defaults to shape code 2
    Footprint() {
        m_shape_code = 2;
    }
    // constructor for initial buildings with given shape code
    Footprint(int shape_code) {
        m_shape_code = shape_code;
        m_size_xy = genFootprint(m_shape_code);
    }
    // sets shape_code and returns size
    int[] newFootprint() {
        m_shape_code = genShapeCode();
        m_size_xy = genFootprint(m_shape_code);
        // println("shape_code = " + m_shape_code + ", size_xy = " + m_size_xy[0] + ", " + m_size_xy[1]);
        return m_size_xy;
    }

    int genShapeCode() {
        int t_shape_code = (int)random(0, m_list_sizes.length);
        return t_shape_code;
    }

    int[] genFootprint(int shape_code) {
        int[] t_size_xy = new int [2];
        if (shape_code < m_list_sizes.length && m_list_sizes[shape_code] != null) {
            t_size_xy = m_list_sizes[shape_code];
        }
        return t_size_xy;
    }

    int getShapeCode() {
        return m_shape_code;
    }

    int[] getSizeXY() {
        return m_size_xy;
    }
}