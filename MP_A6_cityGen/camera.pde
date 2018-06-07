// custom camera by Ho-Wan To
// Drag middle mouse button to pan, mouse wheel controls zoom. Left and Right arrow keys to rotate camera direction.
float cam_min_height = 50;
float cam_max_height = 1600;
float center_x;
float center_z;
float x_offset;
float z_offset;
float cam_height;
int cam_dir;
float pan_x;
float pan_z;
int x_pan_dir;
int z_pan_dir;

// set min and max draw distance
void initCam() {
    float aspect = 1.0f * width / height;
    perspective(PI / 3.0, aspect, 0.1f, 10000.0f);
    cam_dir = 0;
    cam_height = 740;
    center_x = 550;
    center_z = 350;
}
// update custom camera
void updateCam() {
    switch(cam_dir) {
        case 0:
            x_offset = 0;
            z_offset = -200;
            center_x += pan_x;
            center_z += pan_z;
            break;
        case 1:
            x_offset = 200;
            z_offset = 0;
            center_x += -pan_z;
            center_z += pan_x;
            break;
        case 2:
            x_offset = 0;
            z_offset = 200;
            center_x += -pan_x;
            center_z += -pan_z;
            break;
        case 3:
            x_offset = -200;
            z_offset = 0;
            center_x += pan_z;
            center_z += -pan_x;
            break;
    }
    pan_x = 0;
    pan_z = 0;
    camera(center_x + x_offset, cam_height, center_z + z_offset, center_x, 0, center_z, 0, -1, 0);
}
void mouseDragged() {
    if (mouseButton == CENTER) {
        pan_x += -(mouseX - pmouseX);
        pan_z += (mouseY - pmouseY);
    }
}
void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    cam_height += e * 20;
    if (cam_height < cam_min_height) {
        cam_height = cam_min_height;
    } else if (cam_height > cam_max_height) {
        cam_height = cam_max_height;
    }
}

/* PeasyCam not used
PeasyCam g_cam;
CameraState g_state;

// Initialize Peasycam and rotate into correct orientation
void initPeasyCam() {
    g_cam = new PeasyCam(this, 400, 0, 300, 600);
    g_cam.setRotations(-PI * 0.6, 0, 0);
    g_cam.setResetOnDoubleClick(false);
    g_state = g_cam.getState();

}
// get PeasyCam position
void getPeasyCamSettings() {
    float[] rotations = g_cam.getRotations();
    float[] position = g_cam.getPosition();
    double distance = g_cam.getDistance();
    println(rotations);
    println(position);
    println(distance);
}
*/
