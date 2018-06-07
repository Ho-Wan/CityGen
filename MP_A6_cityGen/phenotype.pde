// phenotype for building
class Phenotype
{
    Footprint m_footprint;
    Genotype m_geno;

    int m_index;
    int[] m_pos_xy;
    // width, depth corresponds to x, z axis respectively
    float m_width;
    float m_depth;
    // center of building in world coordinates
    float[] m_pos_centre;
    // height
    float m_height;
    float[] m_offset;
    // colour modifier
    int m_colour_mod;

    // array containing grid positions occupied
    int[][] m_grid_loc;
    int[] m_size_xy;

    // keep track of new buildings
    boolean m_is_new;

    // gene 2; theta for setting building height based on usage: {gene value, min height, add height}
    float[][] m_theta = {
        {0,  5,  5},    // resi
        {1,  4,  1},    // retail
        {2, 20, 10},    // office
        {3,  8,0.5},    // industrial
        {4, 20,  1},    // leisure
        {5,  1,0.5},    // park
    };

    // offset coefficients for gene 3: {gene value, x1 inset, x2 inset, y1 inset, y2 inset}
    float[][] m_offset_coeff = {
        {0, 0.1, 0.1, 0.1, 0.1},
        {1, 0.2, 0.2, 0.2, 0.2},
        {2, 0.3, 0.3, 0.3, 0.3},
        {3, 0.4, 0.4, 0.4, 0.4},
        {4, 0.1, 0.4, 0.1, 0.1},
        {5, 0.4, 0.1, 0.1, 0.1},
        {6, 0.1, 0.1, 0.1, 0.4},
        {7, 0.1, 0.1, 0.4, 0.1},
    };

    // Phenotype constructor
    Phenotype(Genotype geno, int index, int[] pos_xy, Footprint footprint) {
        m_geno = geno;
        m_index = index;
        m_pos_xy = pos_xy;

        m_footprint = footprint;
        m_size_xy = m_footprint.getSizeXY();
        setGridLoc(m_size_xy);

        m_width = m_size_xy[0] * g_grid_size;
        m_depth = m_size_xy[1] * g_grid_size;

        m_pos_centre = getCentre();

        m_is_new = true;
        // set properties based on gene value
        m_height = setHeight(geno);
        m_offset = setOffsets(geno);
        m_colour_mod = 0;
    }
    // called every frame
    void update() {
        float t_x_offset = (m_offset[0] - m_offset[1]) * 0.5;
        float t_y_offset = (m_offset[2] - m_offset[3]) * 0.5;
        float t_x_mult = (1 - (m_offset[0] + m_offset[1]) * 0.5);
        float t_y_mult = (1 - (m_offset[2] + m_offset[3]) * 0.5);
        pushStyle();
            pushMatrix();
                translate(m_pos_centre[0], m_height * 0.5, m_pos_centre[1]);
                // offset
                translate(g_grid_size * t_x_offset, 0, g_grid_size * t_y_offset);
                setColour(m_geno, m_is_new);
                drawBuilding(m_width * t_x_mult, m_height, m_depth * t_y_mult, m_geno.getGene(4));
            popMatrix();
        popStyle();
    }
    // draws building based on gene 4
    void drawBuilding(float x, float y, float z, int gene4) {
        float min_xz = min(x, z);
        switch (gene4) {
            case 0: // Cuboid
                box(x, y, z);
                break;
            case 1: // Hexagon
                drawCylinder(6, min_xz * 0.5, min_xz * 0.5, y);
                break;
            case 2: // cylinder
                drawCylinder(18, min_xz * 0.5, min_xz * 0.5, y);
                break;
            case 3: // Extruded ellipse
                drawCylinder(32, x * 0.5, z * 0.5, y);
                break;
            case 4: // Split level box
                drawSplitBox(x, y, z);
                break;
            default:
                box(x, y, z);
                break;
        }
    }
    // draws split level Box
    void drawSplitBox(float x, float y, float z) {
        float min_xz = min(x, z);
        float max_xz = max(x, z);
        // minimum storey height is 10m and no less than y
        float y_bot = max(0.2 * y, min(10, y));
        float y_top = y - y_bot;
        translate(0, -(y * 0.5) + (y_bot * 0.5), 0);
        box(x, y_bot, z);
        translate(0, (y_bot + y_top) * 0.5, 0);
        if (x > z) {
            translate((max_xz - min_xz) * 0.5, 0, 0);
        } else {
            translate(0, 0, (max_xz - min_xz) * 0.5);
        }
        box(min_xz, y_top, min_xz);
    }
    // draws cyclinder; source http://vormplus.be/blog/article/drawing-a-cylinder-with-processing
    void drawCylinder(int sides, float rx, float rz, float h) {
        pushStyle();
        float angle = 360 / sides;
        float halfHeight = h / 2;
        // top
        beginShape();
        for (int i = 0; i < sides; ++i) {
            float x = cos( radians( i * angle ) ) * rx;
            float z = sin( radians( i * angle ) ) * rz;
            vertex(x, -halfHeight, z);
        }
        endShape(CLOSE);
        // bottom
        beginShape();
        for (int i = 0; i < sides; ++i) {
            float x = cos( radians( i * angle ) ) * rx;
            float z = sin( radians( i * angle ) ) * rz;
            vertex(x, halfHeight, z);
        }
        endShape(CLOSE);
        // draw body
        beginShape(QUAD_STRIP);
        stroke(0, 32);
        for (int i = 0; i < sides + 1; i++) {
            float x1 = cos( radians( i * angle ) ) * rx;
            float z1 = sin( radians( i * angle ) ) * rz;
            float x2 = cos( radians( i * angle ) ) * rx;
            float z2 = sin( radians( i * angle ) ) * rz;
            vertex( x1, -halfHeight, z1);
            vertex( x2, halfHeight, z2);
        }
        endShape(CLOSE);
        popStyle();
    }
    // get theta for height
    float[] getTheta(int gene_1) {
        float[] t_theta = new float [2];
        if (gene_1 < m_theta.length) {
            t_theta[0] = m_theta[gene_1][1];
            t_theta[1] = m_theta[gene_1][2];
            return t_theta;
        } else {
            println("invalid theta");
            return null;
        }
    }
    // get centre of building
    float[] getCentre() {
        float[] t_pos_centre = new float [2];
        t_pos_centre[0] = (m_pos_xy[0] * g_grid_size) + (m_width * 0.5);
        t_pos_centre[1] = (m_pos_xy[1] * g_grid_size) + (m_depth * 0.5);
        return t_pos_centre;
    }
    // set colour of building
    void setColour(Genotype geno, boolean is_new) {
        int t_alpha = 192;
        // set colour mod based on gene 5;
        m_colour_mod = geno.m_genes[5] * 12;
        // colours range based on gene 5
        int c_lo = m_colour_mod;
        int c_hi = 255 - m_colour_mod;
        // fill colour based on gene 1 (usage)
        switch (geno.getGene(1)) {
            case 0 :
                fill(c_hi, c_lo, c_lo, t_alpha); // resi = red
                break;
            case 1 :
                fill(c_hi, c_hi, c_lo, t_alpha); //retail = yellow
                break;
            case 2 :
                fill(c_lo, c_lo, c_hi, t_alpha); // office = blue
                break;
            case 3 :
                fill(c_hi, c_lo, c_hi, t_alpha); // industrial = purple
                break;
            case 4 :
                fill(c_lo, c_hi, c_hi, t_alpha); // leisure = cyan
                break;
            case 5 :
                fill(c_lo, c_hi, c_lo, t_alpha); // park = green
                break;
            default :
                fill(c_hi, t_alpha); // white
                break;
        }
        // outline color
        if (is_new) {
            strokeWeight(4);
            stroke(255);
        } else {
            strokeWeight(2);
            stroke(0);
        }
    }
    // store grid locations in array
    void setGridLoc(int[] size_xy) {
        int t_size_x = size_xy[0];
        int t_size_y = size_xy[1];
        int t_num_blocks = t_size_x * t_size_y;
        m_grid_loc = new int [t_num_blocks][2];
        for (int i = 0; i < t_size_x; ++i) {
            for (int j = 0; j < t_size_y; ++j) {
                int t_index = (i * t_size_y) + j;
                m_grid_loc[t_index][0] = m_pos_xy[0] + i;
                m_grid_loc[t_index][1] = m_pos_xy[1] + j;
            }
        }
    }
    // set height of building based on gene 1 (Usage) and gene 2 (Height);
    float setHeight(Genotype geno) {
        float t_height;
        int t_g0 = geno.getGene(0);
        int t_g1 = geno.getGene(1);
        int t_g2 = geno.getGene(2);
        {
            float[] theta = getTheta(t_g1);
            // theta[0] = min height, theta[1] = height multiplier for gene 2.
            t_height = theta[0] + (t_g2 * theta[1]);
            // println("gene 0 = " + t_g0 + ", gene 1 = " + t_g1 + ", gene 2 = " + t_g2 +  ", height = " + t_height);
        }
        return t_height;
    }
    // set offsets of building based on gene 3
    float[] setOffsets(Genotype geno) {
        int t_g3 = geno.getGene(3);
        float[] t_offset = new float [4];
        for (int i = 0; i < 4; ++i) {
            t_offset[i] = m_offset_coeff[t_g3][i+1];
        }
        return t_offset;
    }

    void setNotNew() {
        m_is_new = false;
    }
}
