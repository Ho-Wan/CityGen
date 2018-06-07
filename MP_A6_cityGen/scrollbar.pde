// scrollbar; based on https://processing.org/examples/scrollbar.html

class Scrollbar {
    int m_width, m_height;    // width and height of bar
    float m_pos_x, m_pos_y;       // x and y position of bar
    float m_slider_pos, m_slider_pos_new;    // x position of slider
    float m_pos_min, m_pos_max; // max and min values of slider
    float m_stiffness;              // m_stiffness
    boolean m_mouse_over;           // is the mouse m_mouse_over the slider?
    boolean m_is_locked;
    float m_ratio;
    float m_value;
    float m_value_min, m_value_max;
    float m_value_scaled;

    String m_name;

    Scrollbar (float pos_x, float pos_y, int s_width, int s_height, int stiffness) {
        m_width = s_width;
        m_height = s_height;
        int width_to_height = s_width - s_height;
        m_ratio = (float)s_width / (float)width_to_height;
        m_pos_x = pos_x;
        m_pos_y = pos_y - m_height/2;
        m_slider_pos = m_pos_x + m_width/2 - m_height/2;
        m_slider_pos_new = m_slider_pos;
        m_pos_min = m_pos_x;
        m_pos_max = m_pos_x + m_width - m_height;
        m_stiffness = stiffness;
        setMinMax(0, 1);
        setName("Value: ");
    }

    void update() {
        if (overEvent()) {
            m_mouse_over = true;
        } else {
            m_mouse_over = false;
        }
        if (mousePressed && m_mouse_over) {
            m_is_locked = true;
        }
        if (!mousePressed) {
            m_is_locked = false;
        }
        if (m_is_locked) {
            m_slider_pos_new = constrain(mouseX-m_height/2, m_pos_min, m_pos_max);
        }
        if (abs(m_slider_pos_new - m_slider_pos) > 1) {
            m_slider_pos = m_slider_pos + (m_slider_pos_new-m_slider_pos)/m_stiffness;
        }
        m_value = getPos();
        m_value_scaled = m_value * (m_value_max - m_value_min) + m_value_min;
        display();
    }

    float getValue() {
        return m_value_scaled;
    }

    void setName(String name) {
        m_name = name;
    }

    void setMinMax(float value_min, float value_max) {
        m_value_min = value_min;
        m_value_max = value_max;
    }

    float constrain(float val, float minv, float maxv) {
        return min(max(val, minv), maxv);
    }

    boolean overEvent() {
        if (mouseX > m_pos_x && mouseX < m_pos_x+m_width && mouseY > m_pos_y && mouseY < m_pos_y+m_height) {
            return true;
        } else {
            return false;
        }
    }

    void display() {
        pushStyle();
            noStroke();
            fill(204);
            rect(m_pos_x, m_pos_y, m_width, m_height);
            if (m_mouse_over || m_is_locked) {
                fill(0, 0, 0);
            } else {
                fill(102, 102, 102);
            }
            rectMode(CENTER);
            rect(m_slider_pos + m_height/2, m_pos_y + m_height/2, m_height * 0.9, m_height * 0.9);
            textAbove();
        popStyle();
    }

    float getPos() {
        // Convert m_slider_pos to be values between
        // 0 and the total width of the scrollbar
        float t_value = (m_slider_pos - m_pos_min) / (m_pos_max - m_pos_min);
        return t_value;
    }

    void textAbove() {
        String text0 = String.format("%s %.2f", m_name, m_value_scaled);
        pushMatrix();
            pushStyle();
            fill(255);
            textAlign(LEFT, CENTER);
            textSize(16);
            translate(m_pos_x, m_pos_y - m_height);
            text(text0, 0, 0);
            popStyle();
        popMatrix();
    }
}
