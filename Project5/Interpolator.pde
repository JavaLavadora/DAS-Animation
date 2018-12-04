abstract class Interpolator
{
  Animation animation;
  
  // Where we at in the animation?
  float currentTime = 0;
  
  // To interpolate, or not to interpolate... that is the question
  boolean snapping = false;
  
  void SetAnimation(Animation anim)
  {
    animation = anim;
  }
  
  void SetFrameSnapping(boolean snap)
  {
    snapping = snap;
  }
  
  void UpdateTime(float time)
  {
    // TODO: Update the current time
    currentTime = currentTime + time;
    
    // Check to see if the time is out of bounds (0 / Animation_Duration)
    // If so, adjust by an appropriate amount to loop correctly
    if(currentTime < 0){
      currentTime = currentTime + animation.GetDuration();
    }
    if(currentTime > animation.GetDuration()){
      //Loop the animation
      currentTime = currentTime - animation.GetDuration();
    }
    
  }
  
  // Implement this in derived classes
  // Each of those should call UpdateTime() and pass the time parameter
  // Call that function FIRST to ensure proper synching of animations
  abstract void Update(float time);
}

class ShapeInterpolator extends Interpolator
{
  // The result of the data calculations - either snapping or interpolating
  PShape currentShape;
  
  // Changing mesh colors
  color fillColor;
  
  PShape GetShape()
  {
    return currentShape;
  }
  
  void Update(float time)
  {
    // TODO: Create a new PShape by interpolating between two existing key frames
    // using linear interpolation
    UpdateTime(time);
    
    //Find the previous and next frames with respect to the current time
    KeyFrame prevFrame = new KeyFrame();
    KeyFrame nextFrame = new KeyFrame();
    
    boolean foundPrev = false;
    boolean foundNext = false;

    for(int i = 0; i < animation.keyFrames.size(); i++) {
        
      if(animation.keyFrames.get(i).time < currentTime){
        prevFrame = animation.keyFrames.get(i);

        foundPrev = true;
      }
      if(animation.keyFrames.get(i).time > currentTime && !foundNext){
        nextFrame = animation.keyFrames.get(i);
   
        foundNext = true;
      }
    }
    
    float timePrev = prevFrame.time;
    float timeNext = nextFrame.time;
    
    //We need to check the edge cases
    //No previous fram was foun -> we have to take the last one of the list

    if(!foundPrev){
      int last = animation.keyFrames.size() - 1;
      prevFrame = animation.keyFrames.get(last);
      //Set the time value to 0. It is the same since it is a loop
       timePrev= 0;
    }

    //Find the time ratio
    float timeRatio = (currentTime - timePrev)/(timeNext - timePrev);    
    
    
    ArrayList<PVector> toDrawNext = new ArrayList<PVector>();
    toDrawNext = nextFrame.points;
    ArrayList<PVector> toDrawPrev = new ArrayList<PVector>();
    toDrawPrev = prevFrame.points;
    
    currentShape = createShape();
    currentShape.beginShape(TRIANGLES);
    // You can set fill and stroke
    currentShape.fill(fillColor);
    currentShape.noStroke();
    //Now we have to calculate the next frame shape
    for(int i = 0; i < toDrawNext.size(); i++){

      if(snapping){
        currentShape.vertex(toDrawNext.get(i).x + width/2, toDrawNext.get(i).y + height/2, toDrawNext.get(i).z);
      }
      
      //We must apply linear interpolation
      //V = (V1 - V0) * timeRatio + V0
      else{
          float x = (toDrawNext.get(i).x - toDrawPrev.get(i).x) * timeRatio + toDrawPrev.get(i).x;
          float y = (toDrawNext.get(i).y - toDrawPrev.get(i).y) * timeRatio + toDrawPrev.get(i).y;
          float z = (toDrawNext.get(i).z - toDrawPrev.get(i).z) * timeRatio + toDrawPrev.get(i).z;
          currentShape.vertex(x + width/2, y + height/2, z);
          
      }
    }
    currentShape.endShape();
  
  }
  
}



class PositionInterpolator extends Interpolator
{
  PVector currentPosition;
  color fillColor;
  void Update(float time)
  {
    // The same type of process as the ShapeInterpolator class... except
    // this only operates on a single point 
    
    //Snapping between frames as understood in the statement
       
    UpdateTime(time);
    
    KeyFrame frame = new KeyFrame();

    
    
    for(int i = 0; i < animation.keyFrames.size(); i++){
      if(animation.keyFrames.get(i).time < currentTime){
        frame = animation.keyFrames.get(i);
      }
      if(currentTime < 1){
        frame = animation.keyFrames.get(3);
      }
    }
    
    currentPosition = frame.points.get(0);
   
    
  }
}
