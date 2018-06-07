// buttons for gui
class Button
{
    boolean m_mouse_over;
    boolean m_btn_state;
    // position of button
    int m_pos_x, m_pos_y;
    // size of button
    int m_btn_width;
    int m_btn_height;
    float m_corner_radius;
    // button text
    String m_btn_txt;
    String m_state_txt;

    Button(int pos_x, int pos_y, int btn_width, int btn_height, boolean btn_state) {
        m_mouse_over = false;
        m_btn_state = btn_state;
        m_pos_x = pos_x;
        m_pos_y = pos_y;
        m_btn_width = btn_width;
        m_btn_height = btn_height;
        m_corner_radius = m_btn_height / 4;
        m_btn_txt = "";
        m_state_txt = "";
    }

    void update() {
        mouseOver();
        drawButton();
    }

    void posOverride(int pos_x) {
        m_pos_x = pos_x;
    }
    boolean getButtonState() {
        return m_btn_state;
    }

    void setButtonText(String btn_text) {
        m_btn_txt = btn_text;
    }

    void drawButton() {
        colorMode(RGB, 255);
        fill(255);
        strokeWeight(2);
        if (m_mouse_over) {
            stroke(0, 255, 0);
        } else {
            stroke(0);
        }
        pushMatrix();
            translate(m_pos_x, m_pos_y);
            // ellipse(0, 0, m_btn_width, m_btn_width);
            // add button text
            if (m_btn_state) {
                fill(96); // button on
                m_state_txt = "On";
            } else {
                fill(192); // button off
                m_state_txt = "Off";
            }
            rect(0, 0, m_btn_width, m_btn_height, m_corner_radius);
            textAlign(LEFT, CENTER);
            translate(10, m_btn_height / 2);
            textSize(24);
            fill(0);
            text(m_btn_txt + m_state_txt, 0, 0);
        popMatrix();
    }

    void mouseOver() {
        // if (dist(mouseX, mouseY, m_pos_x, m_pos_y) < m_btn_width * 0.5) {
        if ((m_pos_x < mouseX) && (mouseX < (m_pos_x + m_btn_width)) && (m_pos_y < mouseY) && (mouseY < (m_pos_y + m_btn_height))) {
            m_mouse_over = true;
        } else {
            m_mouse_over = false;
        }
    }

    void onClick() {
        if (m_mouse_over) {
            m_btn_state = !m_btn_state;
        }
    }
}
