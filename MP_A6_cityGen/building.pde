// building class, contains shape grammar properties
class Building
{
    Genotype m_geno;
    Phenotype m_pheno;
    Footprint m_footprint;
    ArrayList<int[]> m_al_adjacents;
    int[] m_pos_xy;

    int m_index;
    float[] m_pos_centre;
    // for mouse select
    boolean m_mouse_over;
    boolean m_selected;
    boolean m_show_as_parent;
    boolean m_alive;
    // fitness
    float m_fitness;
    float m_fitness_scaled;
    float m_fitness_pow;
    // scale factors for fitness
    float m_theta_pos = 2.0;
    float m_theta_neg = -1.0;
    float m_scale_a = 0.02;
    float m_scale_b = 0;
    // power coefficient for chance to die; increase number to kill more buildings; set with slider
    float m_chance_pow = 8.0;
    // influence area; uses world coordinates
    float m_influence_area = 100.0f;
    // HashMap to store distance to other buildings within influence area with index
    Map<Building, Float> m_nearby_buildings = new HashMap<Building, Float>();
    // parents
    Building m_father_bldg;
    Building m_mother_bldg;

    // constructor for initial buildings with genotype passed in
    Building(int index, int[] pos_xy, Footprint footprint, Genotype geno) {
        initBuilding(index, pos_xy, footprint, geno);
    }
    // constructor for additional buildings
    Building(int index, int[] pos_xy, Footprint footprint) {
        Genotype t_geno = new Genotype(footprint.m_shape_code);
        initBuilding(index, pos_xy, footprint, t_geno);
    }
    // common part of constructors
    void initBuilding(int index, int[] pos_xy, Footprint footprint, Genotype geno) {
        m_fitness = 0.0;
        m_pos_xy = pos_xy;
        m_footprint = footprint;
        m_geno = geno;
        m_pheno = new Phenotype(geno, index, pos_xy, footprint);
        m_index = m_pheno.m_index;
        m_pos_centre = m_pheno.m_pos_centre;
        m_alive = true;
        // output position and shape for debugging
        // println("index = " + m_pheno.m_index + ", pos_x,y = {" + m_pos_xy[0] + ", " + m_pos_xy[1] + "}, size_xy = " + m_footprint.m_size_xy[0] +
                // " x " + m_footprint.m_size_xy[1] + ", shape_code = " + m_footprint.m_shape_code);
    }
    // Building with fitness closer to -1 or 1 has a larger chance to die
    boolean buildingDies() {
        if (random(0, 1) < m_fitness_pow) {
            return true;
        } else {
            return false;
        }
    }
    // checks distance from this building to other building, stores buildings within influence area
    void evalDistToBuilding(Building bldg) {
        float t_bldg_dist = dist(m_pos_centre[0], m_pos_centre[1], bldg.m_pos_centre[0], bldg.m_pos_centre[1]);
        // dist = 0 if own building
        if (t_bldg_dist < m_influence_area && t_bldg_dist != 0.0) {
            m_nearby_buildings.put(bldg, t_bldg_dist);
            // println("My index " + m_index + ", other building index: " + bldg.m_index + ", distance: " + t_bldg_dist);
        }
    }
    // evaluate fitness
    void evalFitness() {
        m_fitness = 0.0;
        // iterate over Map of buildings + distance and update fitness
        for (Map.Entry<Building, Float> entry : m_nearby_buildings.entrySet()) {
            Building t_building = entry.getKey();
            float t_bldg_dist = entry.getValue();
            float t_theta = 0.0;
            if (t_building.getUsageGene() == this.getUsageGene()) {
                t_theta = m_theta_pos;
            } else {
                t_theta = m_theta_neg;
            }
            // closer distance has larger effect on fitness.
            m_fitness += t_theta * (m_influence_area / t_bldg_dist);
        }
        m_fitness_scaled = scaleFitness(m_fitness);
        m_fitness_pow = powFitness(m_fitness_scaled, m_chance_pow);
        // println("My index = " + m_index + ", fitness = " + m_fitness);
    }
    void inheritGenes(Building father_bldg, Building mother_bldg) {
        m_father_bldg = father_bldg;
        m_mother_bldg = mother_bldg;
        m_geno = m_geno.crossover(father_bldg.m_geno, mother_bldg.m_geno);
        m_geno.mutate();
    }
    // scale fitness to -1 and 1
    float scaleFitness(float fitness) {
        float t_fitness = (fitness * m_scale_a) + m_scale_b;
        return t_fitness;
    }
    // apply power to scaled fitness
    float powFitness(float fitness_scaled, float pow) {
        float t_fitness = pow(abs(fitness_scaled), pow);
        return t_fitness;
    }
    // gets usage from
    int getUsageGene() {
        return m_geno.m_genes[1];
    }
    // called every frame
    void update() {
        // set death coefficient based on slider
        m_chance_pow = g_slider_1.m_value_scaled;
        // set bias based on slider
        float t_slider_value = g_slider_2.m_value_scaled;
        // varies from 0.01 to 0.02 to 0.01
        m_scale_a = 0.02 - (abs(t_slider_value) * 0.01);
        m_scale_b = t_slider_value * 0.5;
        m_pheno.update();
    }

    int[][] getGridLoc() {
        return m_pheno.m_grid_loc;
    }

    void set_not_new() {
        m_pheno.setNotNew();
    }
}
