
import oscP5.*;
import netP5.*;
import java.awt.event.*;



public class JoyPanel {


  long lastUpdateTime = 0;
  long updateFreq = 100;

  boolean lastMouse = false;

  OscP5 oscP5;
  NetAddress myRemoteLocation;

  float rotZ = 0.0;
  float throt = 0;
  float zrot = 0;
  boolean leftDown, rightDown;

  boolean[] keyStates = new boolean[6];

  PVector translate = new PVector(0, 0, 0);

  PVector screenPos, screenSize;
  PFont font;
  public JoyPanel(int x, int y, int w, int h) {
    screenPos = new PVector(x, y);
    screenSize = new PVector(w, h);
    oscP5 = new OscP5(this, 12009);
    font = loadFont("HanzelExtendedNormal-48.vlw");

    myRemoteLocation = new NetAddress(serverIP, 19999);
  }




  void keyPressed(char key) {

    if (key == 'w') {
      throt += 0.1;
    } 
    else if (key == 's') {
      throt -= 0.1;
    } 
    else if (key == 'q') {
      leftDown = true;
    } 
    else if (key == 'e') {
      rightDown = true;
    } 
    else if (key == 'i') {
      translate.y = 1.0;
    }  
    else if (key == 'k') {
      translate.y = -1.0;
    }  
    else if (key == 'j') {
      translate.x = 1.0;
    }  
    else if (key == 'l') {
      translate.x = -1.0;
    }
  }

  void keyReleased(char key) {
    if (key == 'q') {
      leftDown = false;
    } 
    else if (key == 'e') {
      rightDown = false;
    } 
    else if (key == 'i') {
      translate.y = 0.0;
    }  
    else if (key == 'k') {
      translate.y = 0.0;
    }  
    else if (key == 'j') {
      translate.x = 0;
    }  
    else if (key == 'l') {
      translate.x = 0;
    }
  }

  void draw() {

    pushMatrix();
    translate(screenPos.x, screenPos.y);
    noFill();
    stroke(255, 255, 255);
    rect(0, 0, screenSize.x, screenSize.y);
    line(screenSize.x / 2, 0, screenSize.x / 2, screenSize.y);
    line(0, screenSize.x / 2, screenSize.x, screenSize.y / 2);

    textFont(font, 12);
    text(throt, 50, 50);

    if (lastUpdateTime + updateFreq < millis() ) {
      lastUpdateTime = millis();
      OscMessage myMessage = new OscMessage("/control/joystick/state");
      zrot = 0.0; 
      if (leftDown) { 
        zrot = 1.0f;
      }
      if (rightDown) { 
        zrot = -1.0f;
      }


      if (mousePressed && checkBounds(mouseX, mouseY)) {
        myMessage.add(map(mouseX -screenPos.x, 0, screenSize.x, -1.0, 1.0)); 
        myMessage.add(-map(mouseY - screenPos.y, 0, screenSize.y, -1.0, 1.0));
        myMessage.add(zrot);
        myMessage.add(-translate.x);
        myMessage.add(-translate.y);
        myMessage.add(throt);
        lastMouse = true;
        oscP5.send(myMessage, myRemoteLocation);
      } 
      else {
        if (lastMouse ) {
          myMessage.add(0); 
          myMessage.add(0);
          myMessage.add(0);
          myMessage.add(0);
          myMessage.add(0);
          myMessage.add(0);
          oscP5.send(myMessage, myRemoteLocation);
        }
        lastMouse = false;
      }
    }
    if (checkBounds(mouseX, mouseY)) {
      ellipse(mouseX - screenPos.x, mouseY - screenPos.y, 5, 5);
      stroke(255, 255, 255);
    }


    popMatrix();
  }

  private boolean checkBounds(int x, int y) {
    if (x - screenPos.x > 0 && x - screenPos.x < screenSize.x) {
      if (y - screenPos.y > 0 && y - screenPos.y < screenSize.y) {
        return true;
      }
    } 
    return false;
  }
}

