void render_spiral() {
  float phi = 0;
  float lambda = 0;
  stroke(255);  
  //  beginShape();
  while (lambda < TWO_PI) {
    stroke(angle_color(phi, lambda));
    point(proj.x(phi, lambda)+width/2, proj.y(phi, lambda)+height/2);
    phi += 0.01;
    lambda += 0.01;
  }
  //  endShape(OPEN);
}

