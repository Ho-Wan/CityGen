// City Generator; by Ho-Wan To - evolutionary approach using a Genetic Algorithm in Processing.
// Created for Morphogenetic Programming Module: Final Assignment A6. Created April 2018.
// Hold X to continuously generate new buildings. Press R to reset. Zoom and pan with middle mouse button.

// Use Java HashMap to store distance to other buildings along with index
import java.util.Map;
// City class contains all buildings
City g_city;
// Scrollbars
Scrollbar g_slider_1, g_slider_2;
// Buttons
Button g_btn_options, g_btn_inspector;
boolean g_show_options, g_show_inspector;
// grid size
float g_grid_size = 10.0f;
int g_grid_x = 80;
int g_grid_y = 60;
// initial positions of buildings; corresponds to bottom left corner, starts from 0
int[][] g_init_pos = { {9, 44}, {24, 14}, {39, 44}, {54, 14}, {69, 44} };
// genotype of initial buildings, passed in to City
Genotype[] g_init_geno = new Genotype [g_init_pos.length];
int g_num_genes = 6;
// for mouse selection
Building g_building_selected = null;
Building g_building_mouse_over = null;
// seed
int g_random_seed = 0;
// assign initial genes
int[][] g_init_genes = {
    {0 , 0, 0, 0, 0, 0},
    {2 , 1, 1, 1, 1, 1},
    {3 , 2, 2, 2, 2, 2},
    {7 , 3, 3, 3, 3, 3},
    {10, 4, 4, 4, 4, 4},
};

void setup()
{
    size(1200, 800, P3D);
    initCam();
    reset();
}

void draw()
{
    background(128);
    updateCam();
    drawAxis(20);
    checkKeyHeld();

    g_city.update();

    guiUpdate();
}

void reset()
{
    randomSeed(g_random_seed);
    g_city = new City(g_grid_size, g_grid_x, g_grid_y, g_init_pos, g_init_genes);
    println("seed " + g_random_seed++);

    initGUI();
}

void initGUI()
{
    // initialize buttons
    g_btn_options = new Button(10, 100, 190, 40, false);
    g_btn_options.setButtonText("Options: ");
    g_btn_inspector = new Button(width - 200, 100, 190, 40, true);
    g_btn_inspector.setButtonText("Inspector: ");
    // initialize scrollbars
    g_slider_1 = new Scrollbar(50.0, 200.0, 200, 16, 4);
    g_slider_1.setMinMax(1, 11);
    g_slider_1.update();
    g_slider_1.setName("Death coefficient: ");
    // g_slider_1.m_value_scaled = 8;
    g_slider_2 = new Scrollbar(50.0, 250.0, 200, 16, 4);
    g_slider_2.setMinMax(-1, 1);
    g_slider_2.setName("Bias: ");
    // g_slider_2.m_value_scaled = 0;
}
