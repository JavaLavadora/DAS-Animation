// VertexAnimation Project - Student Version
import java.io.*;
import java.util.*;
import java.io.FileNotFoundException;
import java.io.IOException;

Camera cam;
float view = 0;
boolean first = false;
/*========== Monsters ==========*/
Animation monsterAnim;
ShapeInterpolator monsterForward = new ShapeInterpolator();
ShapeInterpolator monsterReverse = new ShapeInterpolator();
ShapeInterpolator monsterSnap = new ShapeInterpolator();

/*========== Sphere ==========*/
Animation sphereAnim; // Load from file
Animation spherePos; // Create manually
ShapeInterpolator sphereForward = new ShapeInterpolator();
PositionInterpolator spherePosition = new PositionInterpolator();

// TODO: Create animations for interpolators
Animation cubeAnim;
Animation cubePos;
PositionInterpolator cubePosition = new PositionInterpolator();
ShapeInterpolator cubeForward = new ShapeInterpolator();
//ArrayList<PositionInterpolator> cubes = new ArrayList<PositionInterpolator>();
ArrayList<ShapeInterpolator> cubes = new ArrayList<ShapeInterpolator>();

void setup()
{
  pixelDensity(2);
  size(1200, 800, P3D);
 
  /*====== Load Animations ======*/
  monsterAnim = ReadAnimationFromFile("monster.txt");
  //sphereAnim = ReadAnimationFromFile("sphere.txt");

  monsterForward.SetAnimation(monsterAnim);
  monsterReverse.SetAnimation(monsterAnim);
  monsterSnap.SetAnimation(monsterAnim);  
  monsterSnap.SetFrameSnapping(true);

  //sphereForward.SetAnimation(sphereAnim);

  /*====== Create Animations For Cubes ======*/
  // When initializing animations, to offset them
  // you can "initialize" them by calling Update()
  // with a time value update. Each is 0.1 seconds
  // ahead of the previous one

  cubePos = new Animation();
  cubePos = cubeAnimation();
  for(int i = 0; i < 11; i++){
    ShapeInterpolator auxPosition = new ShapeInterpolator();
    cubes.add(i, auxPosition);
  }
  for(int i = 0; i < cubes.size(); i++){
    cubes.get(i).SetAnimation(cubePos);
    
    if(i % 2 != 0){ //Yellow cubes
      cubes.get(i).SetFrameSnapping(true); 
    }
    else{
      cubes.get(i).SetFrameSnapping(false); 
    }
    cubes.get(i).Update(i * 0.1);
  }
  //cubeAnim = generateCube();
  //cubeForward.SetAnimation(cubeAnim);
  
 
  /*====== Create Animations For Spheroid ======*/
  Animation spherePos = new Animation();
  //Create and set keyframes
  spherePos = customAnimation();
  spherePosition.SetAnimation(spherePos);
  //Animation  of sphere
  sphereAnim = ReadAnimationFromFile("sphere.txt");
  sphereForward.SetAnimation(sphereAnim);

}

void draw()
{
  lights();
  background(0);
  DrawGrid();

  float playbackSpeed = 0.015f;

  
  DrawGrid();
  // TODO: Implement your own camera
  if (!first) {
    cam = new Camera((float)(width/2), (height/2)-200, width/2, width/2, height/2, 0.0);
    first = true;
  }

  /*====== Draw Forward Monster ======*/

  pushMatrix();
  translate(-40, 0, 0);
  monsterForward.fillColor = color(128, 200, 54);
  monsterForward.Update(playbackSpeed);
  shape(monsterForward.GetShape());
  popMatrix();
  
  
  /*====== Draw Reverse Monster ======*/
  pushMatrix();
  translate(40, 0, 0);
  monsterReverse.fillColor = color(220, 80, 45);
  monsterReverse.Update(-playbackSpeed);
  shape(monsterReverse.currentShape);
  popMatrix();
  
  /*====== Draw Snapped Monster ======*/
  pushMatrix();
  translate(0, 0, -60);
  monsterSnap.fillColor = color(160, 120, 85);
  monsterSnap.Update(playbackSpeed);
  shape(monsterSnap.currentShape);
  popMatrix();
  
  /*====== Draw Spheroid ======*/
  spherePosition.Update(playbackSpeed);
  sphereForward.fillColor = color(39, 110, 190);
  sphereForward.Update(playbackSpeed);
  PVector pos = spherePosition.currentPosition;
  pushMatrix();
  translate(pos.x, pos.y, pos.z);
  shape(sphereForward.currentShape);
  popMatrix();
  
  /*====== TODO: Update and draw cubes ======*/
  // For each interpolator, update/draw
  float init = -100;
  for(int i = 0; i < cubes.size(); i++){
    float offset = init + i*20;

    if(i % 2 == 0){ //Red cubes: NO SNAPPING
      pushMatrix();
      translate(offset, 0, 0);
      cubes.get(i).fillColor = color(255, 0, 0);
      cubes.get(i).Update(playbackSpeed);
      shape(cubes.get(i).currentShape);
      popMatrix();
    }
    else{ //Yellow cubes: SNAPPING
      pushMatrix();
      translate(offset, 0, 0);
      cubes.get(i).fillColor = color(255, 255, 0);
      cubes.get(i).Update(playbackSpeed);
      shape(cubes.get(i).currentShape);
      popMatrix();
    }
  }

  
  
  cam.update(mouseX, mouseY);
}

void mouseWheel(MouseEvent event)
{
  float e = event.getCount();
  // Zoom the camera
   cam.zoom(e);
}

// Create and return an animation object
Animation ReadAnimationFromFile(String fileName)
{
  Animation animation = new Animation();

  // The BufferedReader class will let you read in the file data
  try
  {
    BufferedReader reader = createReader(fileName);
    
    //Read first line with number of frames
    int numKeyFrames = int(reader.readLine());
    //Read second line with number of vertices per object
    int numVertex = int(reader.readLine());

    String auxParse;
    
    for(int i = 0; i < numKeyFrames; i++){
      KeyFrame auxFrame = new KeyFrame();
      
      //Read time
      float time = float(reader.readLine());     
      
      //Store it in the keyframe
      auxFrame.time = time;
      
      for(int j = 0; j < numVertex; j++){
        PVector auxVertex = new PVector();
        String[] pieces = new String[3];
      
        //Read the vertex
        auxParse = reader.readLine();
               
        pieces = splitTokens(auxParse, " ");
        
        auxVertex.x = float(pieces[0]);
        auxVertex.y = float(pieces[1]);
        auxVertex.z = float(pieces[2]);

        //Store info in keyFrame
        auxFrame.points.add(auxVertex);
        
      }
      
      //Store the keyFrame in animation
      animation.keyFrames.add(i, auxFrame);
    }
    
  }
  catch(FileNotFoundException ex)
  {
    println("File not found: " + fileName);
  }
  catch (IOException ex)
  {
    ex.printStackTrace();
  }
 
  return animation;
}

void DrawGrid()
{
  // TODO: Draw the grid
  // Dimensions: 200x200 (-100 to +100 on X and Z)
  //Set grid
  for (int i = (width/2)-100; i <= (width/2)+100; i = i + 10) {
    if (i == width/2) {
      stroke(0, 0, 255);
    } else {
      stroke(255);
    }

    line(i, height/2, -100, i, height/2, 100);
  }

  for (int i = -100; i <= 100; i = i + 10) {

    if (i == 0) {
      stroke(255, 0, 0);
    } else {
      stroke(255);
    }

    line((width/2)-100, height/2, i, (width/2)+100, height/2, i);
  }
}

Animation customAnimation(){
  
  Animation animation = new Animation();
  
  KeyFrame frames[] = new KeyFrame[4];
  PVector vectorPoints[] = new PVector[4];
  
  for(int i = 0; i < 4; i++){
    frames[i] = new KeyFrame();
    vectorPoints[i] = new PVector();
  }
  
  vectorPoints[0].x = -100 ;
  vectorPoints[0].y = 0;
  vectorPoints[0].z = 100;
  frames[0].time = 1.0f;
  frames[0].points.add(vectorPoints[0]);
  
  vectorPoints[1].x = -100;
  vectorPoints[1].y = 0;
  vectorPoints[1].z = -100;
  frames[1].time = 2.0f;
  frames[1].points.add(vectorPoints[1]);
  
  vectorPoints[2].x = 100;
  vectorPoints[2].y = 0;
  vectorPoints[2].z = -100;
  frames[2].time = 3.0f;
  frames[2].points.add(vectorPoints[2]);
  
  vectorPoints[3].x = 100;
  vectorPoints[3].y = 0;
  vectorPoints[3].z = 100;
  frames[3].time = 4.0f;
  frames[3].points.add(vectorPoints[3]);
  

  for(int i = 0; i < 4; i++){
    animation.keyFrames.add(i, frames[i]);
  }
  
  
  return animation;
}

Animation cubeAnimation(){
  
  Animation animation = new Animation();
  
  KeyFrame frames[] = new KeyFrame[4];
  
  
  for(int i = 0; i < 4; i++){
    frames[i] = new KeyFrame();
  }
  
  float offset = 0;
  PVector vectorPoints[] = new PVector[36];
  for(int i = 0; i < 4; i++){
    
    
    for(int j = 0; j < 36; j++){
      vectorPoints[j] = new PVector();
    }
    
    switch(i){
      case 0: offset = 0;
              break;
      case 1: offset = -100;
              break;
      case 2: offset = 0;
              break;   
              
      default: offset = 100;
    }

    //FRONT FACE
    vectorPoints[0] = new PVector(-5, 5, 5+offset);
    vectorPoints[1] = new PVector(5, 5, 5+offset);
    vectorPoints[2] = new PVector(-5, -5, 5+offset);
    vectorPoints[3] = new PVector(5, 5, 5+offset);
    vectorPoints[4] = new PVector(5, -5, 5+offset);
    vectorPoints[5] = new PVector(-5, -5, 5+offset);
    
    //FACE 2
    vectorPoints[6] = new PVector(-5, 5, -5+offset);
    vectorPoints[7] = new PVector(5, 5, -5+offset);
    vectorPoints[8] = new PVector(-5, -5, -5+offset);
    vectorPoints[9] = new PVector(5, 5, -5+offset);
    vectorPoints[10] = new PVector(5, -5, -5+offset);
    vectorPoints[11] = new PVector(-5, -5, -5+offset);    
        
    //FACE 3
    vectorPoints[12] = new PVector(-5, 5, -5+offset);
    vectorPoints[13] = new PVector(-5, 5, 5+offset);
    vectorPoints[14] = new PVector(-5, -5, -5+offset);
    vectorPoints[15] = new PVector(-5, 5, 5+offset);
    vectorPoints[16] = new PVector(-5, -5, 5+offset);
    vectorPoints[17] = new PVector(-5, -5, -5+offset);
    
    //FACE 4
    vectorPoints[18] = new PVector(5, 5, -5+offset);
    vectorPoints[19] = new PVector(5, 5, 5+offset);
    vectorPoints[20] = new PVector(5, -5, -5+offset);
    vectorPoints[21] = new PVector(5, 5, 5+offset);
    vectorPoints[22] = new PVector(5, -5, 5+offset);
    vectorPoints[23] = new PVector(5, -5, -5+offset);
    
    //FACE 5 BOTTOM
    vectorPoints[24] = new PVector(-5, 5, 5+offset);
    vectorPoints[25] = new PVector(-5, 5, -5+offset);
    vectorPoints[26] = new PVector(5, 5, -5+offset);
    vectorPoints[27] = new PVector(5, 5, -5+offset);
    vectorPoints[28] = new PVector(5, 5, 5+offset);
    vectorPoints[29] = new PVector(-5, 5, 5+offset);
      
    //FACE TOP
    vectorPoints[30] = new PVector(-5, -5, 5+offset);
    vectorPoints[31] = new PVector(-5, -5, -5+offset);
    vectorPoints[32] = new PVector(5, -5, -5+offset);
    vectorPoints[33] = new PVector(5, -5, -5+offset);
    vectorPoints[34] = new PVector(5, -5, 5+offset);
    vectorPoints[35] = new PVector(-5, -5, 5+offset);
   
    for(int k = 0; k < 36; k++){
      frames[i].points.add(vectorPoints[k]);
    }

    frames[i].time = i * 0.5f;
  }

  for(int i = 0; i < 4; i++){
    animation.keyFrames.add(i, frames[i]);
  }
  
  
  return animation;
}
