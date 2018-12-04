//-------- CAMERA ----------
class Camera {

  float posX, posY, posZ;
  PVector target = new PVector(0, 0, 0);

  Camera(float pX, float pY, float pZ, float tarX, float tarY, float tarZ) {
    //println("Camera");
    posX = pX;
    posY = pY;
    posZ = pZ;
    target.x = tarX;
    target.y = tarY;
    target.z = tarZ;
    camera(posX, posY, posZ, target.x, target.y, target.z, 0, 1, 0);
  }


  void update(float mX, float mY) {    
    //Get radius: offset between camera and target (RANGE: 30 to 200)
    float radius = (posX - target.x)*(posX - target.x) + (posY - target.y)*(posY - target.y) + (posZ - target.z)*(posZ - target.z);
    radius = sqrt(radius);
    //Set range for radius
    if (radius < 30) {
      radius = 30;
    }
    if (radius > 200) {
      radius = 200;
    }

    //println("radius is:" + radius);
    //Get Phi: depends on MouseX (RANGE MAP: 0 to 360)
    float phi = map(mX, 0, width-1, 0, 360);
    //println("phi is:" + phi);
    //Get Theta: depends on MouseY (RANGE MAP: 0 to 179)
    float theta = map(mY, 0, height-1, 0, 179);
    //println("theta is:" + theta);
    //Calculate derivedXYZ
    float derivedX = radius * cos(phi * (PI/180)) * sin(theta * (PI/180));
    //println("dX is:" + derivedX);
    float derivedY = radius * cos(theta * (PI/180));
    //println("dY is:" + derivedY);

    float derivedZ = radius * sin(phi * (PI/180)) * sin(theta * (PI/180));
    //println("dZ is:" + derivedZ);

    //Calculate new values for camera
    posX = target.x + derivedX; 
    posY = target.y + derivedY; 
    posZ = target.z + derivedZ;
    //println("posX is: " + posX + " posY is: " + posY + "posZ is: " + posZ);


    //Update Camera
    camera(posX, posY, posZ, target.x, target.y, target.z, 0, 1, 0);
  }

  void zoom (float val) {
    //println(val);
    if (val < 0) {
      view--;
      if(view < 10){
        view = 10;
      }
    } else {
      view++;
      if(view > 90){
        view = 90;
      }
    }
    perspective(radians(view), width/(float)height, 0.1, 1000);
  }
  
}
