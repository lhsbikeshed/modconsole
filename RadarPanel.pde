import java.util.Iterator;
import java.util.Map;

public class RadarPanel {
  PFont font;
  Object lock = new Object();


  float zoomLevel = 0.1f;

  //HashMap radarList = new HashMap();
  ArrayList<RadarObject> radarList = new ArrayList(0);

  public RadarPanel() {
    font = loadFont("HanzelExtendedNormal-48.vlw");
  }


  public void start() {
  }
  public void stop() {
  }


  public void draw() {
    background(0, 0, 0);
    zoomLevel = map(mouseY, 0, height, 0.01f, 1.0f);
    pushMatrix();
    translate(600, 500);
    scale(0.2);
    drawRadar();
    popMatrix();
  }





  public void drawRadar() {

    pushMatrix();
    // ortho();
    lights();
    ambientLight(255, 255, 255);

    drawAxis((int)((millis() % 1750.0f) / 200));


    strokeWeight(1);
    stroke(0, 0, 0);


    fill(255, 255, 0, 255);
    sphere(1);
    fill(0, 0, 255);
    scale(zoomLevel);
    synchronized(lock) {
      for (Iterator<RadarObject> it = radarList.iterator(); it.hasNext();) {

        RadarObject r = it.next();
        pushMatrix();


        stroke(0, 255, 0);
        //line to base
        line(-r.position.x, 0, r.position.z, -r.position.x, -r.position.y, r.position.z);
        //circle at base       
        pushMatrix();
        translate(-r.position.x, 0, r.position.z);
        rotateX(radians(-90));
        fill(0, 50, 0);
        strokeWeight(1);

        ellipse(0, 0, 20, 20);
        popMatrix();
        
        //sphere and text
        PVector newPos = r.lastPosition;
        
        newPos.x = lerp(r.lastPosition.x, r.position.x, (millis() - r.lastUpdateTime) / 250.0f );
        newPos.y = lerp(r.lastPosition.y, r.position.y, (millis() - r.lastUpdateTime) / 250.0f);
        newPos.z = lerp(r.lastPosition.z, r.position.z, (millis() - r.lastUpdateTime) / 250.0f);
       // translate(-r.position.x, -r.position.y, r.position.z);
        r.screenPos.x = screenX(-newPos.x,-newPos.y,newPos.z);
        r.screenPos.y = screenY(-newPos.x,-newPos.y,newPos.z);
        translate(-newPos.x,-newPos.y,newPos.z);    
        noStroke();
        int alpha = (int)lerp(255, 0, (millis() - r.lastUpdateTime) / 250.0f);
        color c = r.displayColor;
        fill (c);

        sphere(10);
        
        popMatrix();

        //workout what needs cleaning

        if (r.lastUpdateTime < millis() - 500.0f) {
          //its dead jim
          //removeList.add(new Integer(i));
          println("removing id: " + r.id);
          it.remove();
        }
      }
      popMatrix();
      for (Iterator<RadarObject> it = radarList.iterator(); it.hasNext();) {

        RadarObject r = it.next();
        fill(r.displayColor);
        textFont(font, 10);
        text(r.name, r.screenPos.x + 5, r.screenPos.y + 10);
        textFont(font, 5);
        text(r.statusText,r.screenPos.x + 5, r.screenPos.y + 30);
      }
    }
    
    //popMatrix();
    noLights();
  }
  public void drawAxis(int highlight) {
    translate(width/2, height/2);
    rotateX(radians(315)); //326
    rotateY(radians(225)); //216
    //x axis
    stroke(128, 0, 0);
    strokeWeight(1);
    line(-1000, 0, 0, 1000, 0, 0);
    line(1000, 0, -10, 1000, 0, 10);
    pushMatrix();
    rotateX(radians(-90));
    noFill();
    strokeWeight(1);
    drawRadarCircle(5, 200, highlight);

    for (int delay = 0; delay < 5; delay++) {

      float radius = ((millis()  + (delay*1000 )) / 5.0f) % 1000 ;
      stroke(0, 255, 0, map(radius, 0, 1000, 255, 0));
      ellipse(0, 0, radius, radius);
    }  



    popMatrix();

    //z axis
    stroke(0, 0, 128);
    line(0, 0, -1000, 0, 0, 1000);
    line(-10, 0, 1000, 10, 0, 1000);
    /* pushMatrix();
     rotateY(radians(-90));
     noFill();
     strokeWeight(1);
     drawRadarCircle(5, 200);
     popMatrix();
     */
    //y axis
    stroke(0, 128, 0);
    // line(0, 1000, 0, 0, -1000, 0);
    // line(-10, 1000, 0, 10, 1000, 0);
    /*
   pushMatrix();
     //rotateX(-90);
     noFill();
     strokeWeight(1);
     drawRadarCircle(5, 200);
     popMatrix();*/
  }

  void drawRadarCircle( int num, int sizing, int highlight) {
    int radius = sizing;
    for (int i = 0; i < num; i ++) {
      if (i == highlight) {
        stroke(0, 30, 0);
      } 
      else {
        stroke(0, 30, 0);
      }
      ellipse(0, 0, radius, radius);
      radius += sizing;
    }
    stroke(0, 255, 0);
  }

  public void serialEvent(String content) {
  }



  /* incoming osc message are forwarded to the oscEvent method. */
  public void oscMessage(OscMessage theOscMessage) {

    /* print the address pattern and the typetag of the received OscMessage */

    if (theOscMessage.checkAddrPattern("/radar/update")) {
      synchronized(lock) {
        //get the id
        boolean updated = false;
        int id = theOscMessage.get(0).intValue();
        RadarObject r = null;
        RadarObject temp;
        int updateId = -1;
        for (int b = 0; b < radarList.size(); b++) {

          temp = (RadarObject)radarList.get(b);

          if (temp.id == id) {
            r = temp;
            updated = true;
            updateId = b;
          }
        }
        if (r == null) {
          r = new RadarObject();
        }

        r.id = id;
        //println(r.id);
        r.lastUpdateTime = millis();
        r.name = theOscMessage.get(1).stringValue();
        r.lastPosition = r.position;


        r.position.x = theOscMessage.get(2).floatValue();

        r.position.y = theOscMessage.get(3).floatValue();
        r.position.z = theOscMessage.get(4).floatValue();

        String colour = theOscMessage.get(5).stringValue();
        String[] splitColour = colour.split(":");
        r.displayColor = color (  Float.parseFloat(splitColour[0]) * 255, 
        Float.parseFloat(splitColour[1]) * 255, 
        Float.parseFloat(splitColour[2]) * 255);
        r.lastUpdateTime = millis();

        r.statusText = theOscMessage.get(6).stringValue();
        if (updated) {
          radarList.set(updateId, r);
        } 
        else {
          radarList.add(r);
        }
      }
    }
  }
}



public class RadarObject { 

  public PVector position = new PVector();
  public PVector lastPosition = new PVector();
  public PVector screenPos = new PVector();
  public String name = "";
  public String statusText = "";
  public int id = 0;

  public float bearing = 0.0f;
  public float elevation = 0.0f;
  public float distance = 0.0f;

  public color displayColor = color(0, 255, 0);

  public long lastUpdateTime = 0;

  public RadarObject() {
  }
}

