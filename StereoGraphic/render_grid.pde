void render_grid() {
  for (float phi = 0; phi < TWO_PI; phi += (TWO_PI / 360.0)) {
    //    beginShape(POINTS);
    for (float lambda = 0; lambda < TWO_PI; lambda += (TWO_PI / 18.0)) {
      stroke(angle_color(phi, lambda));
      point(proj.x(phi, lambda)+width/2, proj.y(phi, lambda)+height/2);
    }
    //    endShape();
  }
  for (float phi = 0; phi < TWO_PI; phi += TWO_PI / 18.0) {
    //    beginShape(POINTS);
    for (float lambda = 0; lambda < TWO_PI; lambda += TWO_PI / 360.0) {
      stroke(angle_color(phi, lambda));
      point(proj.x(phi, lambda)+width/2, proj.y(phi, lambda)+height/2);
    }
    //    endShape();
  }
}

