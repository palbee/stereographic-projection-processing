void render_map() {
  float phi = 0;
  float lambda = 0;
  //  stroke(255,255,255);
  for (int i=0; i < map_data.length; i++) {
    beginShape();
    for (int j=0; j < map_data[i].length- 1; j+=2) {
      phi = radians(map_data[i][j]);
      lambda = radians(-map_data[i][j+1]);
      stroke(angle_color(phi, lambda));      
      vertex(proj.x(phi, lambda)+width/2, proj.y(phi, lambda)+height/2);
    }  
    endShape(OPEN);
  }
}

