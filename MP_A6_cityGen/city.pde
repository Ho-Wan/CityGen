// city class, acts as population of buildings
class City
{
    int m_generation = 0;
    int m_building_index = 0;
    int m_death_count = 0;

    // count buildings
    int m_num_buildings = 0;
    int[] m_num_gene1 = new int [g_num_genes];
    int[] m_num_gene4 = new int [g_num_genes];

    // array containing initial buildings
    Building[] m_init_buildings;
    // list of all additional buildings including initial buildings
    ArrayList<Building> m_buildings = new ArrayList<Building>();
    // list of new buildings at latest generation
    ArrayList<Building> m_new_buildings = new ArrayList<Building>();
    // list of all cells next to buildings
    ArrayList<int[]> m_all_adjacents = new ArrayList<int[]>();
    // list of cell positions that are valid for new building with a given size
    ArrayList<int[]> m_valid_groups = new ArrayList<int[]>();
    // store size of next building
    int[] m_size_xy = new int [2];

    // initial global properties passed in
    float m_grid_size;
    int m_grid_x;
    int m_grid_y;
    int[][] m_init_pos;
    int m_init_num;

    // cell class to track properties associated with each cell
    Cell[][] m_cell;
    // city constructor; pass in grid properties, positions and genes for initial buildings
    City(float grid_size, int grid_x, int grid_y, int[][] init_pos, int[][] init_genes) {
        m_grid_size = grid_size;
        m_grid_x = grid_x;
        m_grid_y = grid_y;
        m_init_pos = init_pos;
        m_init_num = init_pos.length;
        // instantiate cell and set state to false
        m_cell = new Cell [m_grid_x][m_grid_y];
        for (int i = 0; i < m_grid_x; ++i) {
            for (int j = 0; j < m_grid_y; ++j) {
                m_cell[i][j] = new Cell();
            }
        }
        // create initial Buildings
        m_init_buildings = new Building[m_init_num];
        Genotype[] t_init_geno = initGeno(init_genes);
        for (int i = 0; i < m_init_buildings.length; ++i) {
            Footprint t_init_footprint = new Footprint(init_genes[i][0]);
            m_init_buildings[i] = new Building(m_building_index, m_init_pos[i], t_init_footprint, t_init_geno[i]);
            m_buildings.add(m_init_buildings[i]);
            updateCellState(m_init_buildings[i], true);
            m_new_buildings.add(m_init_buildings[i]);

            m_building_index++;
        }
        genUpdate();
    }
    // create initialize genotypes using init_genes
    Genotype[] initGeno(int[][] init_genes) {
        if (init_genes.length != g_init_pos.length) {
            println("Error: number of initial Genotypes does not match number of buildings.");
        }
        if (init_genes[0].length != g_num_genes) {
            println("Error: length of genes does not match gene requirements.");
        }

        Genotype[] t_init_geno = new Genotype [init_genes.length];
        for (int i = 0; i < init_genes.length; ++i) {
            t_init_geno[i] = new Genotype(init_genes[i]);
        }
        return t_init_geno;
    }
    // called every frame
    void update() {
        for (int i = 0; i < m_buildings.size(); ++i) {
            m_buildings.get(i).update();
        }
        drawGrid(m_grid_size, m_grid_x, m_grid_y);
        checkMouseOver();
        // show info related to building positions; TODO make UI to toggle display
        // showAdjacentPos();
        // showBuildingPos();
        // showValidPos(2, 2);
    }
    // called at end of every generation
    void genUpdate() {
        m_all_adjacents = findAdjacentCells();
        m_num_buildings = countBuildings();
        m_num_gene1 = countGenes(1);
        m_num_gene4 = countGenes(4);
    }
    // create next generation of buildings
    void nextGen() {
        if (m_new_buildings.size() > 0 && m_new_buildings != null) {
            for (int i = 0; i < m_new_buildings.size(); ++i) {
                m_new_buildings.get(i).set_not_new();
            }
        }
        m_new_buildings.clear();
        m_generation++;
        // println("Generation " + m_generation);
        int num_new = 3;
        // generate new buildings
        for (int i = 0; i < num_new; ++i) {
            // create footprint and generate footprint size
            Footprint t_gen_footprint = new Footprint();
            int[] t_size_xy = t_gen_footprint.newFootprint();
            m_size_xy = t_size_xy;
            // get list of valid cell groups positions (bottom left cell)
            m_valid_groups = getValidPosList(m_all_adjacents, m_size_xy);

            if (m_valid_groups.size() > 0 && m_valid_groups != null) {
                // returns x,y vector at random index from list of valid positions
                int[] t_pos_xy = getPos(m_valid_groups);
                // create new building and add to list of buildings
                Building t_building = new Building(m_building_index, t_pos_xy, t_gen_footprint);
                // Building[] t_parent_bldgs = findParents();
                // m_buildings.add(t_building);
                updateCellState(t_building, true);
                m_new_buildings.add(t_building);
                m_building_index++;

                findNearbyBuildings();
                Building father_bldg = selectCloseParent(t_building);
                Building mother_bldg = selectCloseParent(t_building);
                t_building.inheritGenes(father_bldg, mother_bldg);
                // println("Father = " + father_bldg.m_index + ", Mother = " + mother_bldg.m_index);
            } else {
                println("No valid position found for size " + m_size_xy[0] + " x " + m_size_xy[1]);
            }
        }
        // updates list of nearby buildings for all existing and new buildings
        findNearbyBuildings();

        for (Building bldg: m_new_buildings) {
            m_buildings.add(bldg);
        }

        // list constains buildings that will die
        ArrayList<Building> buildingsToDie = new ArrayList<Building>();

        // evaluate fitness of building and check if building dies
        for (Building bldg: m_buildings) {
            bldg.evalFitness();
            boolean t_building_dies = bldg.buildingDies();
            if (t_building_dies) {
                buildingsToDie.add(bldg);
            }
        }
        // remove dead buildings
        for (Building bldg: buildingsToDie) {
            destroyBuilding(bldg);
        }
        genUpdate();
    }
    // on checks if mouse is over building, using screen distance to centre of building
    void checkMouseOver() {
        float t_sel_radius = 20.0;
        int t_building_moused_over = -1;
        boolean t_mouse_over_any = false;
        for (int i = 0; i < m_buildings.size(); ++i) {
            Building bldg = m_buildings.get(i);
            float scr_x = screenX(bldg.m_pheno.m_pos_centre[0], 0, bldg.m_pheno.m_pos_centre[1]);
            float scr_y = screenY(bldg.m_pheno.m_pos_centre[0], 0, bldg.m_pheno.m_pos_centre[1]);
            bldg.m_mouse_over = false;
            if (dist(mouseX, mouseY, scr_x, scr_y) < t_sel_radius) {
                t_mouse_over_any = true;
                t_building_moused_over = i;
                // println("Building " + bldg.m_index + " mouse over");
            }
        }
        // only allows one building to be moused over at any time
        if (t_mouse_over_any) {
            Building bldg = m_buildings.get(t_building_moused_over);
            bldg.m_mouse_over = true;
            g_building_mouse_over = bldg;
        } else {
            g_building_mouse_over = null;
        }
        pushStyle();
        noFill();
        for (Building bldg : m_buildings) {
            int[] t_size = bldg.m_pheno.m_size_xy;
            strokeWeight(2);
            drawGridBox(bldg.m_pos_xy[0], bldg.m_pos_xy[1], color(192), m_grid_size, 0.05f, t_size[0], t_size[1]);
            if (bldg.m_mouse_over || bldg.m_selected || bldg.m_show_as_parent) {
                color color_select = color(255); // white is default, should not be used
                if (bldg.m_mouse_over) {
                    color_select = color(0, 255, 0);
                }
                else if (bldg.m_selected) {
                    color_select = color(255, 0, 0);
                }
                else if (bldg.m_show_as_parent) {
                    color_select = color(0, 255, 255);

                }
                // disable z buffer depth check so box shows up through buildings
                hint(DISABLE_DEPTH_TEST);
                strokeWeight(5);
                drawGridBox(bldg.m_pos_xy[0], bldg.m_pos_xy[1], color_select, m_grid_size, 0.05f, t_size[0], t_size[1]);
                hint(ENABLE_DEPTH_TEST);
            }
        }
        popStyle();
    }
    // count total number of buildings
    int countBuildings() {
        int t_building_count;
        t_building_count = m_buildings.size();
        return t_building_count;
    }
    // count number of buildings with each gene
    int[] countGenes(int gene_index) {
        int t_gene_max = m_buildings.get(0).m_geno.m_gene_max[gene_index];
        int[] t_gene_count = new int [t_gene_max];
        for (Building bldg : m_buildings) {
            for (int i = 0; i < t_gene_max; ++i) {
                if (bldg.m_geno.m_genes[gene_index] == i) {
                    t_gene_count[i]++;
                }
            }
        }
        return t_gene_count;
    }
    // removes building
    void destroyBuilding(Building building) {
        building.m_alive = false;
        updateCellState(building, false);
        m_buildings.remove(building);
        for (Building bldg : m_buildings) {
            bldg.m_nearby_buildings.remove(building);
        }
        m_death_count++;
        // println("Building index = " + building.m_pheno.m_index + " has died; scaled fitness = " + building.m_fitness_scaled + ", death count = " + m_death_count);
    }
    // draws gridlines
    void drawGrid(float grid_size, int grid_x, int grid_y) {
        pushMatrix();
        pushStyle();
            float grid_len_x = 1.0f * grid_size * grid_x;
            float grid_len_y = 1.0f * grid_size * grid_y;
            // draw gridlines in X and highlight major gridlines
            for (int i = 0; i <= grid_y; ++i) {
                if (i % 10 == 0) {
                    stroke(255, 128);
                } else {
                    stroke(255, 32);
                }
                line(0, 0, i * grid_size, grid_len_x, 0, i * grid_size);
            }
            // draw gridlines in Y and highlight major gridlines
            for (int i = 0; i <= grid_x; ++i) {
                if (i % 10 == 0) {
                    stroke(255, 128);
                } else {
                    stroke(255, 32);
                }
                line(i * grid_size, 0, 0, i * grid_size, 0, grid_len_y);
            }
            textAlign(CENTER, CENTER);
            textSize(32);
            fill(255);
            rotateX(PI * 3/2);
            translate(grid_len_x / 2, -grid_len_y - (grid_size * 5), 0);
            text("North", 0, 0);
        popStyle();
        popMatrix();
    }
    // draws box at cell location
    void drawGridBox(int grid_x, int grid_y, color col, float grid_size, float grid_padding, float size_x, float size_y) {
        float t_x1 = grid_x + grid_padding;
        float t_x2 = grid_x + size_x - grid_padding;
        float t_y1 = grid_y + grid_padding;
        float t_y2 = grid_y + size_y - grid_padding;
        stroke(col);
        beginShape();
            vertex(t_x1 * grid_size, 0, t_y1 * grid_size);
            vertex(t_x2 * grid_size, 0, t_y1 * grid_size);
            vertex(t_x2 * grid_size, 0, t_y2 * grid_size);
            vertex(t_x1 * grid_size, 0, t_y2 * grid_size);
        endShape(CLOSE);
    }
    // goes through all buildings and updates list containing nearby buildings
    void findNearbyBuildings() {
        // checks distance from new buildings to all other buildings and store if within influence area
        for (Building new_bldg : m_new_buildings) {
            for (Building bldg: m_buildings) {
                if (bldg != new_bldg) {
                    new_bldg.evalDistToBuilding(bldg);
                }
            }
        }
        // check distance from existing buildings to new buildings and store if within influence area
        for (Building bldg: m_buildings) {
            for (Building new_bldg : m_new_buildings) {
                if (bldg != new_bldg) {
                    bldg.evalDistToBuilding(new_bldg);
                }
            }
        }
    }
    // find all cells adjacent to buildings; ignores first and last rows & columns. Returns as arraylist of x,y vector.
    ArrayList<int[]> findAdjacentCells() {
        ArrayList<int[]> t_all_adjacents = new ArrayList<int[]>();
        for (int i = 1; i < m_grid_x - 1; ++i) {
            for (int j = 1; j < m_grid_y - 1; ++j) {
                if (m_cell[i][j].getState() == true) {
                    m_cell[i][j].setAdjacent(false);
                } else {
                    int[] t_cell_ref = {i, j};
                    if (m_cell[i-1][j].getState() == true || m_cell[i+1][j].getState() == true || m_cell[i][j-1].getState() == true || m_cell[i][j+1].getState() == true) {
                        m_cell[i][j].setAdjacent(true);
                        t_all_adjacents.add(t_cell_ref);
                    } else {
                        m_cell[i][j].setAdjacent(false);
                        t_all_adjacents.remove(t_cell_ref);
                    }
                }
            }
        }
        return t_all_adjacents;
    }
    // get list of all valid positions containing an adjacent cell, but does not clash with existing building
    ArrayList<int[]> getValidPosList(ArrayList<int[]> all_adjacents, int[] size_xy) {
        ArrayList<int[]> t_valid_pos = new ArrayList<int[]>();
        int size_x = size_xy[0];
        int size_y = size_xy[1];
        // iterate through all groups of cells for given size over grid
        for (int i = 0; i <= (m_grid_x - size_x); ++i) {
            for (int j = 0; j <= (m_grid_y - size_y); ++j) {
                boolean overlaps_building = false;
                boolean contains_adjacent = false;
                // check that cell group does not contain an existing building and is adjacent to building
                for (int x = 0; x < size_x; ++x) {
                    for (int y = 0; y < size_y; ++y) {
                        if (m_cell[i+x][j+y].getState() == true) {
                            overlaps_building = true;
                        }
                        if (m_cell[i+x][j+y].getAdjacent() == true) {
                            contains_adjacent = true;
                        }
                    }
                }
                if (overlaps_building == false && contains_adjacent == true) {
                    int[] t_valid_cell_ref = {i, j};
                    t_valid_pos.add(t_valid_cell_ref);
                }
            }
        }
        return t_valid_pos;
    }
    // get position for additional buildings, returns x,y vector
    int[] getPos(ArrayList<int[]> valid_pos_xy) {
        int[] t_pos_xy = new int [2];
        // select random position from list of cells adjacent to buildings
        int t_al_index = (int)random(0, valid_pos_xy.size());
        t_pos_xy = valid_pos_xy.get(t_al_index);
        return t_pos_xy;
    }
    // Parent Selection Method 1; selects parent buildings at random
    Building selectRandomParent() {
        int t_random_index = (int)random(0, m_buildings.size());
        Building t_building = m_buildings.get(t_random_index);
        return t_building;
    }
    // Parent Selection Method 3; Select random nearby building within invluence area
    Building selectCloseParent(Building bldg) {
        Building t_building;
        // convert hashmap to arraylist of nearby building; select nearby building as parent if > 3 nearby buildings
        ArrayList<Building> t_nearby_buildings = new ArrayList<Building>(bldg.m_nearby_buildings.keySet());
        if (t_nearby_buildings.size() > 3) {
            int t_random_index = (int)random(0, t_nearby_buildings.size());
            t_building = t_nearby_buildings.get(t_random_index);
        } else {
            t_building = selectRandomParent();
        }
        return t_building;
    }
    // draws yellow box if cell is adjacent to a building;
    void showAdjacentPos() {
        pushStyle();
        for (int i = 0; i < m_grid_x; ++i) {
            for (int j = 0; j < m_grid_y; ++j) {
                if(m_cell[i][j].getAdjacent()) {
                    color col_yellow = color(255, 255, 0);
                    noFill();
                    drawGridBox(i, j, col_yellow, m_grid_size, 0.05f, 1.0f, 1.0f);
                }
            }
        }
        popStyle();
    }
    // draws green box if cell state is true;
    void showBuildingPos() {
        pushStyle();
        for (int i = 0; i < m_grid_x; ++i) {
            for (int j = 0; j < m_grid_y; ++j) {
                if(m_cell[i][j].getState()) {
                    color col_green = color(0, 255, 0);
                    noFill();
                    drawGridBox(i, j, col_green, m_grid_size, 0.05f, 1.0f, 1.0f);
                }
            }
        }
        popStyle();
    }
    // draws valid positions as blue box on grid
    void showValidPos(int size_x, int size_y) {
        pushStyle();
        int[] t_size_xy = {size_x, size_y};
        m_valid_groups = getValidPosList(m_all_adjacents, t_size_xy);
        // draws blue box if valid cell group
        if (m_valid_groups != null) {
            for (int i = 0; i < m_valid_groups.size(); ++i) {
                color col_blue = color(0, 0, 255);
                int[] t_pos_xy = m_valid_groups.get(i);
                noFill();
                drawGridBox(t_pos_xy[0], t_pos_xy[1], col_blue, m_grid_size, 0.1f, size_x, size_y);
            }
        }
        popStyle();
    }
    // changes cell state at new building or when building destroyed
    void updateCellState(Building add_building, boolean state) {
        int[][] t_grid_loc = add_building.getGridLoc();
        for (int i = 0; i < t_grid_loc.length; ++i) {
            int t_x = t_grid_loc[i][0];
            int t_y = t_grid_loc[i][1];
            if (t_x < m_grid_x && t_y < m_grid_y) {
                m_cell[t_x][t_y].setState(state);
            } else {
                println("position out of bounds: x = " + t_x + ", y = " + t_y);
            }
        }
    }
}
