// helper functions here

// checks if key press is held
void checkKeyHeld() {
    if (keyPressed) {
        switch (key) {
            case 'x': g_city.nextGen(); break;
        }
    }
}
// draws X, Y, Z axis as R, G, B respectively
void drawAxis(int len) {
    pushStyle();
        strokeWeight(2);
        stroke(255, 0, 0);
        line(-len * 0.25, 0, 0, len, 0, 0);
        stroke(0, 255, 0);
        line(0, -len * 0.25, 0, 0, len, 0);
        stroke(0, 0, 255);
        line(0, 0, -len * 0.25, 0, 0, len);
    popStyle();
}

// adds 2D text gui
void guiUpdate() {
    int my_top_padding = 150;
    String text0 = "Evolutionary City Generator";
    String text1 = "Buildings are continuously generated using a Genetic Algorithm.";
    String text2 = "Hold X to continuously generate new buildings. Press R to reset. Zoom and pan with middle mouse button.";
    pushStyle();
    pushMatrix();
        hint(DISABLE_DEPTH_TEST);
        noStroke();
        camera();
        noLights();
        // draw rectangle at top of screen in padding area
        fill(128, 128, 128, 192);
        rect(0, 0, width, my_top_padding);
        // update buttons
        g_btn_options.update();
        g_btn_inspector.update();
        g_btn_inspector.posOverride(width - 200);
        // show Title and description
        textAlign(CENTER, CENTER);
        fill(255);
        textSize(32);
        text(text0, width * 0.5, 20);
        textSize(16);
        text(text1, width * 0.5, 60);
        text(text2, width * 0.5, 80);
        // show output text on left
        outputText();
        // show inspector
        int t_inspector_mode = 0;
        if (g_building_selected != null) {
            t_inspector_mode = 1;
        } else {
            t_inspector_mode = 0;
        }
        if (g_btn_options.getButtonState()) {
            outputOptions();
        }
        if (g_btn_inspector.getButtonState()) {
            outputInspector(t_inspector_mode);
        }
        hint(ENABLE_DEPTH_TEST);
    popMatrix();
    popStyle();
}
// on key press
void keyPressed() {
    try {
        key = Character.toLowerCase(key);
        switch (key) {
            // PeasyCam not used
            // case 'c': g_cam.setState(g_state); break;
            // case 'p': getPeasyCamSettings(); break;
            case ' ': g_city.nextGen(); break;
            case 'c': initCam(); break;
            case 'r': reset(); break;
            // for debugging
            case 'f': printFitness(); break;
            case 'g': printGenes(); break;
            case 'b': printBias(); break;
            // for camera direction control
            case CODED:
                if (keyCode == RIGHT) {
                    cam_dir = (cam_dir +1) % 4;
                }
                if (keyCode == LEFT) {
                    cam_dir = (cam_dir -1 + 4) % 4;
                }
                // println("camera direction mode = " + cam_dir);
            break;
        }
    } catch (Exception e) {
        println("Exception: " + e);
    }
}
// on mouse click
void mouseClicked() {
    try {
        if (mouseButton == LEFT) {
            if (g_building_selected != null) {
                g_building_selected.m_selected = false;
                if (g_building_selected.m_father_bldg != null && g_building_selected.m_mother_bldg != null) {
                    g_building_selected.m_father_bldg.m_show_as_parent = false;
                    g_building_selected.m_mother_bldg.m_show_as_parent = false;
                }
            }

            g_building_selected = g_building_mouse_over;

            if (g_building_selected != null) {
                g_building_selected.m_selected = true;
                if (g_building_selected.m_father_bldg != null && g_building_selected.m_mother_bldg != null) {
                    g_building_selected.m_father_bldg.m_show_as_parent = true;
                    g_building_selected.m_mother_bldg.m_show_as_parent = true;
                }
            }
            // toggle buttons
            g_btn_options.onClick();
            g_btn_inspector.onClick();
        }
    } catch (Exception e) {
        println("Exception: " + e);
    }
}
// display output text on screen
void outputText() {
    String text0 = "Generation: " + g_city.m_generation;
    String text1 = "text1...";
    pushMatrix();
    pushStyle();
        textAlign(LEFT, CENTER);
        fill(255);
        textSize(32);
        text(text0, width * 0.01, 40);
        // text(text1, width * 0.01, 80);
    popStyle();
    popMatrix();
}
// display options window
void outputOptions() {
    int out_win_width = 300;
    int out_win_height = 650;
    int padding = 10;
    String instructions0 = "Controls:";
    String[] instructions = new String [6];
    instructions[0] = "Press Space Bar to generate new buildings.";
    instructions[1] = "Hold X for continuous building generation.";
    instructions[2] = "Press C to reset camera, press R to reset buildings";
    instructions[3] = "Use middle mouse button to pan and zoom. Left/Right Arrow to rotate camera.";
    instructions[4] = "Slider 1 controls rate of death; lower value increases deaths.";
    instructions[5] = "Slider 2 controls fitness function bias.";
    String about_sketch = "ABOUT SKETCH: Generates buildings using a genetic algorithm. New buildings " +
        "have to be next to existing. Buildings inherit properties from 2 nearby parents, with a chance " +
        "of mutation Fitness function is based on similarity to nearby buildings, within a specified " +
        "distance threshold.";
    pushMatrix();
    pushStyle();
        // draw window
        strokeWeight(2);
        stroke(255);
        fill(32, 128);
        rectMode(CORNER);
        rect(padding, 150, out_win_width - padding, out_win_height - padding, padding);
        // update and draw scrollbars
        g_slider_1.update();
        g_slider_2.update();
        // instructions for controls
        translate(20, 300);
        textAlign(LEFT, TOP);
        textSize(24);
        fill(255);
        text(instructions0, 0, 0, 250, 50);
        textSize(12);
        for (int i = 0; i < instructions.length; ++i) {
            translate(0, 40);
            text("•", 0, 0, 10, 50);
            text(instructions[i], 10, 0, 280, 40);
        }
        translate(0, 60);
        text(about_sketch, 0, 0, 280, 300);
    popStyle();
    popMatrix();

}
// display properties window
void outputInspector(int mode) {
    int out_win_width = 300;
    int out_win_height = 650;
    int padding = 10;
    pushMatrix();
    pushStyle();
        // draw window
        strokeWeight(2);
        stroke(255);
        if (mode == 0) {
            fill(32, 128);
        } else {
            fill(32);
        }
        rectMode(CORNER);
        translate(width - out_win_width, 150);
        rect(0, 0, out_win_width - padding, out_win_height - padding, padding);
        textAlign(LEFT, CENTER);
        translate(10, 20);
        if (mode == 0) {
            textBuildingCount();
        }
        if (mode == 1) {
            // Display selected building info
            textSize(32);
            fill(255);
            text("Selected Building: ", 0, 0);
            translate(0, 10);
            textProperties(g_building_selected);
            // Display parent buildings info
            textSize(32);
            fill(255);
            if (g_building_selected.m_father_bldg != null) {
                translate(0, 200);
                text("Father Building: ", 0, 0);
                translate(0, 10);
                textProperties(g_building_selected.m_father_bldg);
            }
            if (g_building_selected.m_mother_bldg != null) {
                translate(0, 200);
                text("Mother Building: ", 0, 0);
                translate(0, 10);
                textProperties(g_building_selected.m_mother_bldg);
            }
        }
    popStyle();
    popMatrix();
}
//
void textBuildingCount() {
    float line_indent = 20;
    float line_height = 20;
    String text0 = "No. of Buildings = " + g_city.m_num_buildings;
    String text1 = "No. of Buildings with: ";
    String text2 = "Gene 1: Usage";
    int num_gene1 = 6;
    String[] text3 = {"0: Residential", "1: Retail", "2: Office", "3: Industrial", "4: Leisure", "5: Park"};
    String[] text3_values = new String [num_gene1];
    for (int i = 0; i < num_gene1; ++i) {
        text3_values[i] = " = " + g_city.m_num_gene1[i];
        text3[i] += text3_values[i];
    }
    String text4 = "Gene 4: Shape";
    int num_gene4 = 8;
    int num_gene4_override = 5;
    String[] text5 = {"0: Cuboid", "1: Hexagon", "2: Cylinder", "3: Ellipse (extruded)", "4: Split level box", "5: Cuboid", "6: Cuboid", "7: Cuboid"};
    String[] text5_values = new String [num_gene4];
    for (int i = 0; i < num_gene4; ++i) {
        if (i >= num_gene4_override) {
            text5_values[0] = " = " + g_city.m_num_gene4[i];
        } else {
            text5_values[i] = " = " + g_city.m_num_gene4[i];
        }
        text5[i] += text5_values[i];
    }
    pushMatrix();
    pushStyle();
        textSize(24);
        fill(255);
        translate(0, 10);
        text(text0, line_indent * 0, 0);
        textSize(16);
        translate(0, line_height + 10);
        text(text1, line_indent * 1, 0);
        translate(0, line_height + 20);
        text(text2, line_indent * 2, 0);
        for (int i = 0; i < num_gene1; ++i) {
            translate(0, line_height);
            text(text3[i], line_indent * 3, 0);
        }
        translate(0, line_height + 20);
        text(text4, line_indent * 2, 0);
        for (int i = 0; i < num_gene4_override; ++i) {
            translate(0, line_height);
            text(text5[i], line_indent * 3, 0);
        }
    popStyle();
    popMatrix();

}
// output properties of selected building as text
void textProperties(Building sel_bldg) {
    float line_indent = 20;
    float line_height = 20;
    int[] t_genes = sel_bldg.m_geno.m_genes;
    String t_usage_string = sel_bldg.m_geno.m_usage_string;
    String text0 = "Index: " + sel_bldg.m_index;
    String text1 = "Genes = ";
    for (int t_gene : t_genes) {
        text1 += str(t_gene) + ", ";
    }
    String text2 = "Usage: " + t_usage_string;
    String text3 = "Position: X = " + sel_bldg.m_pheno.m_pos_xy[0] + ", Y = " + sel_bldg.m_pheno.m_pos_xy[1];
    String text4 = "Height = " + sel_bldg.m_pheno.m_height;
    String text5 = "Fitness = " + nf(sel_bldg.m_fitness_scaled, 0, 2);
    String text6 = "Alive: " + (sel_bldg.m_alive ? "Yes" : "No");
    String text7 = "No. of Nearby Buildings: " + sel_bldg.m_nearby_buildings.size();
    pushMatrix();
    pushStyle();
        textAlign(LEFT, CENTER);
        translate(20, 20);
        textSize(16);
        fill(255);
        text(text0, line_indent * 0, line_height * 0);
        text(text1, line_indent * 1, line_height * 1);
        text(text2, line_indent * 2, line_height * 2);
        text(text3, line_indent * 2, line_height * 3);
        text(text4, line_indent * 2, line_height * 4);
        text(text5, line_indent * 2, line_height * 5);
        text(text6, line_indent * 2, line_height * 6);
        text(text7, line_indent * 2, line_height * 7);
    popStyle();
    popMatrix();

}
// print fitness of all buildings
void printFitness() {
    ArrayList<Building> t_all_buildings = g_city.m_buildings;
    for (Building bldg : t_all_buildings) {
        println(bldg.m_index + ", " + bldg.m_fitness);
    }
}
// print genes of new buildings
void printGenes() {
    ArrayList<Building> t_new_buildings = g_city.m_new_buildings;
    for (Building bldg : t_new_buildings) {
        print("Building index: " + bldg.m_pheno.m_index + ", Genes = ");
        bldg.m_geno.printGenes();
    }
}
// print bias scale coefficients
void printBias() {
    println("m_chance_pow  =" + g_city.m_buildings.get(0).m_chance_pow);
    println("m_scale_a = " + g_city.m_buildings.get(0).m_scale_a);
    println("m_scale_b = " + g_city.m_buildings.get(0).m_scale_b);
}
