// Cell

class Cell
{
    boolean m_state;
    boolean m_is_adjacent;

    Cell() {
        m_state = false;
        m_is_adjacent = false;
    }

    boolean getState() {
        return m_state;
    }

    void setState(boolean state) {
        m_state = state;
    }

    boolean getAdjacent() {
        return m_is_adjacent;
    }

    void setAdjacent(boolean is_adjacent) {
        m_is_adjacent = is_adjacent;
    }

}

